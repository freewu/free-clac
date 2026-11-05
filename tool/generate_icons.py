#!/usr/bin/env python3
"""从根目录的 logo.jpg / logo-android.jpg 生成各平台应用图标。

用法：
    python3 tool/generate_icons.py            # 生成（覆盖）全部图标
    python3 tool/generate_icons.py --check    # 只检查是否存在，不写入

源图两份，按平台取用：
    logo.jpg                Web / Windows
    logo-android.jpg        Android（已按自适应图标构图，四周不留白，整张铺满）

覆盖平台：
    web/      favicon.png + icons/Icon-*.png（含 maskable）
    windows/  windows/runner/resources/app_icon.ico（多尺寸）
    android/  mipmap-*/ic_launcher.png（旧版）+ 自适应图标前景 + anydpi-v26 XML

设计约定：
    * 源图可以是带透明底的 PNG，也可以是不透明的 JPG，两种都支持：
      - 透明底：保留透明背景（蓝色描边图形，深浅底色都能看清），先裁掉 logo 自带的
        留白、再按统一比例补回（[LOGO_FILL]），换一版留白不同的 logo 图标还是一样大；
      - 不透明底（如 logo.jpg 整张图自带深色背景）：原图就是一张完整的方形画面，
        不裁剪、不缩放构图，整张按原比例缩放到各平台尺寸；
    * 会被系统蒙版裁切的图层不能乱铺：
      - Web maskable：整张缩进 80% 安全区，外圈用源图底色补；
      - Android 自适应前景：用 logo-android.jpg（本来就是满幅构图）直接铺满；
        若把通用 logo 塞进来（透明底图形），则垫底色缩进 72dp 安全区，
        因为 108dp 画布里只有中间 72dp 一定可见；
    * 底色（maskable 外圈 / 自适应图标的 background）取源图四周一圈像素的平均色；
    * 生成脚本只依赖 Pillow，无需联网、不引入额外依赖。
"""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # 直接跑脚本时也别只丢一个 ModuleNotFoundError
    sys.exit(
        "✗ 缺少 Pillow，无法生成图标：\n"
        "  Windows：python -m pip install pillow\n"
        "  WSL：    sudo apt install python3-pil\n"
        "  或用 `just icons`（会自动挑一个装了 Pillow 的 Python）"
    )

ROOT = Path(__file__).resolve().parent.parent
# Web / Windows 用桌面版 logo
LOGO = ROOT / "logo.jpg"
# Android 用手机版 logo：已经按自适应图标构图（满幅、四周不留白），可以直接铺满
LOGO_ANDROID = ROOT / "logo-android.jpg"

# 透明底 logo 的满幅图标底色（与 app 深色主题背景一致）
BACKDROP = (11, 15, 20, 255)

# Android mipmap 目录 → 旧版图标尺寸、自适应前景尺寸
ANDROID_LEGACY = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
# 自适应图标前景画布为 108dp，图形放在中心 72dp 安全区内
ANDROID_FOREGROUND_SCALE = 72 / 108

WEB_ICONS = {
    "Icon-192.png": (192, False),
    "Icon-512.png": (512, False),
    "Icon-maskable-192.png": (192, True),
    "Icon-maskable-512.png": (512, True),
}

WINDOWS_ICO_SIZES = (16, 24, 32, 48, 64, 128, 256)

# 自适应图标（Android 8+）：108dp 画布里只有中间 72dp 一定可见，外面会被启动器蒙版裁掉，
# 所以整张图只铺到 72%，保证任何蒙版下画面都是完整的
SAFE_ZONE = 0.72

# maskable（Web PWA）：可见区是中间 80%，整张图铺到 80% 即可
MASKABLE_SAFE_ZONE = 0.80

# 普通图标里图形占画布的比例：logo 自带多少留白都统一成这个值
LOGO_FILL = 0.92

# 自适应图标 XML：AAPT2 要求根节点声明 android 命名空间，否则打包直接失败
ANDROID_ADAPTIVE = (
    "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml",
    "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml",
)


@dataclass(frozen=True)
class Logo:
    """归一化后的图标源图。

    image    正方形、可直接缩放到各平台尺寸；
    opaque   源图没有透明背景（JPG 那种）：原图整张用，不裁边、不补白；
    backdrop 自适应图标 background 用的底色（不透明图取源图四周平均色，
             透明底沿用 [BACKDROP]）。
    """

    image: Image.Image
    opaque: bool
    backdrop: tuple[int, int, int]


def trim_transparent(logo: Image.Image) -> Image.Image:
    """裁掉四周的全透明留白，让图形贴住边界。"""
    bbox = logo.getbbox()
    return logo.crop(bbox) if bbox else logo


def pad_to_fill(image: Image.Image, fill: float = LOGO_FILL) -> Image.Image:
    """居中补透明留白，使图形占正方形画布的 fill 比例。"""
    side = max(1, round(max(image.width, image.height) / fill))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    offset = ((side - image.width) // 2, (side - image.height) // 2)
    canvas.alpha_composite(image, offset)
    return canvas


def border_average(logo: Image.Image) -> tuple[int, int, int]:
    """取四周一圈像素的平均色，当不透明图标的底色。"""
    width, height = logo.size
    step_x, step_y = max(1, width // 64), max(1, height // 64)
    ring = [logo.getpixel((x, 0)) for x in range(0, width, step_x)]
    ring += [logo.getpixel((x, height - 1)) for x in range(0, width, step_x)]
    ring += [logo.getpixel((0, y)) for y in range(0, height, step_y)]
    ring += [logo.getpixel((width - 1, y)) for y in range(0, height, step_y)]
    count = len(ring)
    return (
        sum(pixel[0] for pixel in ring) // count,
        sum(pixel[1] for pixel in ring) // count,
        sum(pixel[2] for pixel in ring) // count,
    )


def normalize(source: Image.Image) -> Logo:
    """把任意源图归一化成正方形图标底图（纯函数，便于自检）。"""
    logo = source.convert("RGBA")
    if logo.width != logo.height:
        side = min(logo.width, logo.height)
        left = (logo.width - side) // 2
        top = (logo.height - side) // 2
        logo = logo.crop((left, top, left + side, top + side))
    # JPG 没有 alpha 通道，转 RGBA 后整张都是不透明的
    if logo.getchannel("A").getextrema()[0] == 255:
        # 不透明图：原图就是完整画面，不裁剪，整张缩放到各平台尺寸
        return Logo(image=logo, opaque=True, backdrop=border_average(logo))
    # 透明底 logo：不同版本留白多少不一样，先裁边再统一补白，图标大小才一致
    return Logo(
        image=pad_to_fill(trim_transparent(logo)),
        opaque=False,
        backdrop=BACKDROP[:3],
    )


def load_logo(path: Path = LOGO) -> Logo:
    if not path.exists():
        sys.exit(f"✗ 找不到 {path.relative_to(ROOT)}，请把应用 logo 放在项目根目录")
    with Image.open(path) as source:
        return normalize(source)


def resize(logo: Image.Image, size: int) -> Image.Image:
    return logo.resize((size, size), Image.LANCZOS)


def with_backdrop(
    logo: Image.Image,
    size: int,
    backdrop: tuple[int, int, int, int] = BACKDROP,
    fill: float = SAFE_ZONE,
) -> Image.Image:
    """满幅图标：垫一层底色 + 居中缩放到安全区内的 logo。

    系统蒙版（启动器 / PWA）会裁掉外圈，画面只有落在安全区里才不会被切，
    所以这里一律缩进去，而不是把图铺满整张画布。
    """
    canvas = Image.new("RGBA", (size, size), backdrop)
    inner = max(1, round(size * fill))
    canvas.alpha_composite(resize(logo, inner), ((size - inner) // 2,) * 2)
    return canvas


def masked(logo: Logo, size: int, fill: float = SAFE_ZONE) -> Image.Image:
    """maskable / 自适应图标：整张图缩进安全区，外圈用源图自己的底色补。"""
    backdrop = (*logo.backdrop, 255) if logo.opaque else BACKDROP
    return with_backdrop(logo.image, size, backdrop, fill)


def save_png(image: Image.Image, path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    return path


def build_web(logo: Logo) -> list[Path]:
    written = [save_png(resize(logo.image, 32), ROOT / "web/favicon.png")]
    for name, (size, maskable) in WEB_ICONS.items():
        image = (
            masked(logo, size, MASKABLE_SAFE_ZONE)
            if maskable
            else resize(logo.image, size)
        )
        written.append(save_png(image, ROOT / "web/icons" / name))
    return written


def build_windows(logo: Logo) -> list[Path]:
    path = ROOT / "windows/runner/resources/app_icon.ico"
    path.parent.mkdir(parents=True, exist_ok=True)
    biggest = max(WINDOWS_ICO_SIZES)
    frames = [resize(logo.image, size) for size in WINDOWS_ICO_SIZES]
    # ICO 里最大的一帧作为基准图，Pillow 会按 sizes 生成多尺寸目录项
    frames[-1].save(path, format="ICO", sizes=[(s, s) for s in WINDOWS_ICO_SIZES])
    assert biggest == WINDOWS_ICO_SIZES[-1]
    return [path]


def adaptive_foreground(logo: Logo, size: int) -> Image.Image:
    """自适应图标前景（108dp）。

    logo-android.jpg 这种不透明、四周不留白的源图是专门按 Android 构图的，
    整张铺满即可（外圈本来就是要被蒙版裁掉的部分）；透明底的通用 logo 图形
    只占中间，得缩进 72dp 安全区，否则会被启动器裁边。
    """
    if logo.opaque:
        return resize(logo.image, size)
    return masked(logo, size)


def build_android(logo: Logo) -> list[Path]:
    written: list[Path] = []
    res = ROOT / "android/app/src/main/res"
    for folder, legacy in ANDROID_LEGACY.items():
        target = res / folder
        written.append(save_png(resize(logo.image, legacy), target / "ic_launcher.png"))
        written.append(
            save_png(resize(logo.image, legacy), target / "ic_launcher_round.png")
        )
        written.append(
            save_png(
                adaptive_foreground(logo, round(legacy * 108 / 48)),
                target / "ic_launcher_foreground.png",
            )
        )

    colors = res / "values/colors.xml"
    colors.parent.mkdir(parents=True, exist_ok=True)
    red, green, blue = logo.backdrop[:3]
    colors.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        f'    <color name="ic_launcher_background">#{red:02X}{green:02X}{blue:02X}'
        "</color>\n"
        "</resources>\n",
        encoding="utf-8",
    )
    written.append(colors)

    adaptive = ROOT / ANDROID_ADAPTIVE[0]
    adaptive.parent.mkdir(parents=True, exist_ok=True)
    adaptive.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android='
        '"http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        "</adaptive-icon>\n",
        encoding="utf-8",
    )
    written.append(adaptive)

    round_icon = ROOT / ANDROID_ADAPTIVE[1]
    round_icon.write_text(adaptive.read_text(encoding="utf-8"), encoding="utf-8")
    written.append(round_icon)
    return written


def _force_utf8_stdout() -> None:
    """Windows 控制台默认 GBK，直接 print(✓) 会抛 UnicodeEncodeError。"""
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")


def selftest() -> None:
    """自检裁边 / 补白 / 缩放 / 满幅底图，不读写磁盘上的真实图标。"""
    # 100x100 画布上放一个 50x50 的不透明方块（模拟带留白的 logo）
    source = Image.new("RGBA", (100, 100), (0, 0, 0, 0))
    source.paste((18, 150, 219, 255), (25, 25, 75, 75))

    trimmed = trim_transparent(source)
    assert trimmed.size == (50, 50), trimmed.size

    padded = pad_to_fill(trimmed)
    assert padded.width == padded.height, padded.size
    box = padded.getbbox()
    assert box is not None, box
    fill = (box[2] - box[0]) / padded.width
    assert 0.91 <= fill <= 0.93, fill
    assert box[0] == padded.width - box[2], (box, padded.size)  # 左右留白一致

    # 全透明图不能崩
    assert trim_transparent(Image.new("RGBA", (10, 10), (0, 0, 0, 0))).size == (10, 10)

    assert resize(trimmed, 32).size == (32, 32)

    backdrop = with_backdrop(trimmed, 108)
    assert backdrop.size == (108, 108)
    assert backdrop.getpixel((0, 0)) == BACKDROP
    # 满幅底图整张都不透明，所以按底色扫中间一行来判断图形的实际宽度
    middle = [x for x in range(108) if backdrop.getpixel((x, 54)) != BACKDROP]
    assert middle, "图形没有画到画布上"
    width = middle[-1] - middle[0] + 1
    assert 0.70 <= width / 108 <= 0.74, width  # 落在安全区内

    assert set(WEB_ICONS) == {
        "Icon-192.png",
        "Icon-512.png",
        "Icon-maskable-192.png",
        "Icon-maskable-512.png",
    }
    assert ANDROID_FOREGROUND_SCALE == 72 / 108

    # 透明底 logo：裁边补白，满幅时垫底色
    transparent = normalize(source)
    assert not transparent.opaque
    assert transparent.backdrop == BACKDROP[:3]

    # 不透明底（JPG）：不裁边不补白，满幅图标整张铺满、底色取边框平均色
    photo = Image.new("RGB", (80, 80), (20, 44, 110))
    photo.paste((240, 240, 240), (24, 24, 56, 56))
    opaque = normalize(photo)
    assert opaque.opaque
    # 不透明源图不裁剪：尺寸原样保留
    assert opaque.image.size == (80, 80), opaque.image.size
    assert opaque.backdrop == (20, 44, 110), opaque.backdrop

    # 满幅图标：整张图缩进安全区（72%），外圈用源图底色补，蒙版裁掉外圈也不丢画面
    bleed = masked(opaque, 108)
    assert bleed.size == (108, 108)
    for corner in ((0, 0), (107, 0), (0, 107), (107, 107)):
        assert bleed.getpixel(corner) == (20, 44, 110, 255), (corner, bleed.getpixel(corner))
    assert bleed.getpixel((54, 54))[:3] == (240, 240, 240), bleed.getpixel((54, 54))
    # 图形（源图 80 里的 32）现在只占画布 32 / 80 * 72%
    run = [x for x in range(108) if bleed.getpixel((x, 54))[0] > 200]
    share = (run[-1] - run[0] + 1) / 108
    assert 0.27 <= share <= 0.30, share
    # maskable 用 80% 安全区，图形占 32 / 80 * 80% = 32%
    wide = masked(opaque, 100, MASKABLE_SAFE_ZONE)
    run = [x for x in range(100) if wide.getpixel((x, 50))[0] > 200]
    assert 0.30 <= (run[-1] - run[0] + 1) / 100 <= 0.34, run

    # 自适应前景：Android 专用源图本来满幅，整张铺满不缩；通用透明底 logo 缩进安全区
    foreground = adaptive_foreground(opaque, 108)
    for corner in ((0, 0), (107, 0), (0, 107), (107, 107)):
        assert foreground.getpixel(corner)[:3] == (20, 44, 110), foreground.getpixel(corner)
    run = [x for x in range(108) if foreground.getpixel((x, 54))[0] > 200]
    share = (run[-1] - run[0] + 1) / 108
    assert 0.38 <= share <= 0.42, share  # 32 / 80，铺满画布
    sprite = adaptive_foreground(transparent, 108)
    run = [x for x in range(108) if sprite.getpixel((x, 54)) != BACKDROP]
    assert 0.70 <= (run[-1] - run[0] + 1) / 108 <= 0.74, run

    print("✓ generate_icons 自检通过")


def main() -> None:
    _force_utf8_stdout()
    parser = argparse.ArgumentParser(
        description="从 logo.jpg / logo-android.jpg 生成各平台应用图标"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="只检查目标文件是否齐全，不写入磁盘",
    )
    parser.add_argument(
        "--selftest",
        action="store_true",
        help="用内存里的合成图自检裁边 / 补白 / 缩放逻辑",
    )
    args = parser.parse_args()

    if args.selftest:
        selftest()
        return

    logo = load_logo(LOGO)
    android_logo = load_logo(LOGO_ANDROID)

    if args.check:
        expected = [
            ROOT / "web/favicon.png",
            *(ROOT / "web/icons" / name for name in WEB_ICONS),
            ROOT / "windows/runner/resources/app_icon.ico",
            *(
                ROOT / "android/app/src/main/res" / folder / name
                for folder in ANDROID_LEGACY
                for name in ("ic_launcher.png", "ic_launcher_foreground.png")
            ),
            *(ROOT / name for name in ANDROID_ADAPTIVE),
        ]
        missing = [str(path.relative_to(ROOT)) for path in expected if not path.exists()]
        if missing:
            print("✗ 缺少图标文件：")
            for path in missing:
                print(f"  - {path}")
            sys.exit(1)
        broken = [
            name
            for name in ANDROID_ADAPTIVE
            if "xmlns:android" not in (ROOT / name).read_text(encoding="utf-8")
        ]
        if broken:
            print("✗ 自适应图标缺少 xmlns:android，aapt2 会编译失败：")
            for name in broken:
                print(f"  - {name}")
            sys.exit(1)
        print(f"✓ 图标齐全（{len(expected)} 个文件）")
        return

    written = (
        build_web(logo) + build_windows(logo) + build_android(android_logo)
    )
    print(
        f"✓ 已根据 {LOGO.name}（Web / Windows）与 {LOGO_ANDROID.name}"
        f"（Android）生成 {len(written)} 个图标文件"
    )
    for path in written:
        print(f"  · {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
