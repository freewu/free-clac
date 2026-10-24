#!/usr/bin/env python3
"""从根目录的 logo.png 生成各平台应用图标。

用法：
    python3 tool/generate_icons.py            # 生成（覆盖）全部图标
    python3 tool/generate_icons.py --check    # 只检查是否存在，不写入

覆盖平台：
    web/      favicon.png + icons/Icon-*.png（含 maskable）
    windows/  windows/runner/resources/app_icon.ico（多尺寸）
    android/  mipmap-*/ic_launcher.png（旧版）+ 自适应图标前景 + anydpi-v26 XML

设计约定：
    * 保留 logo 本身的透明背景（橙色描边图形，深浅底色都能看清）；
    * maskable / 自适应图标需要满幅，因此垫一层深色底并留出安全区（图形约占 72%）；
    * 生成脚本只依赖 Pillow，无需联网、不引入额外依赖。
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
LOGO = ROOT / "logo.png"

# 图标底色（与 app 深色主题背景一致），仅用于 maskable / 自适应图标
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

# maskable / 自适应图标：图形占画布的比例（四周留白，避免被裁切）
SAFE_ZONE = 0.72

# 自适应图标 XML：AAPT2 要求根节点声明 android 命名空间，否则打包直接失败
ANDROID_ADAPTIVE = (
    "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml",
    "android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml",
)


def load_logo() -> Image.Image:
    if not LOGO.exists():
        sys.exit(f"✗ 找不到 {LOGO.relative_to(ROOT)}，请把应用 logo 放在项目根目录")
    logo = Image.open(LOGO).convert("RGBA")
    if logo.width != logo.height:
        side = min(logo.width, logo.height)
        left = (logo.width - side) // 2
        top = (logo.height - side) // 2
        logo = logo.crop((left, top, left + side, top + side))
    return logo


def resize(logo: Image.Image, size: int) -> Image.Image:
    return logo.resize((size, size), Image.LANCZOS)


def with_backdrop(logo: Image.Image, size: int) -> Image.Image:
    """满幅图标：深色底 + 居中缩放的 logo（用于 maskable / 自适应）。"""
    canvas = Image.new("RGBA", (size, size), BACKDROP)
    inner = max(1, round(size * SAFE_ZONE))
    canvas.alpha_composite(resize(logo, inner), ((size - inner) // 2,) * 2)
    return canvas


def save_png(image: Image.Image, path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format="PNG", optimize=True)
    return path


def build_web(logo: Image.Image) -> list[Path]:
    written = [save_png(resize(logo, 32), ROOT / "web/favicon.png")]
    for name, (size, maskable) in WEB_ICONS.items():
        image = with_backdrop(logo, size) if maskable else resize(logo, size)
        written.append(save_png(image, ROOT / "web/icons" / name))
    return written


def build_windows(logo: Image.Image) -> list[Path]:
    path = ROOT / "windows/runner/resources/app_icon.ico"
    path.parent.mkdir(parents=True, exist_ok=True)
    biggest = max(WINDOWS_ICO_SIZES)
    frames = [resize(logo, size) for size in WINDOWS_ICO_SIZES]
    # ICO 里最大的一帧作为基准图，Pillow 会按 sizes 生成多尺寸目录项
    frames[-1].save(path, format="ICO", sizes=[(s, s) for s in WINDOWS_ICO_SIZES])
    assert biggest == WINDOWS_ICO_SIZES[-1]
    return [path]


def build_android(logo: Image.Image) -> list[Path]:
    written: list[Path] = []
    res = ROOT / "android/app/src/main/res"
    for folder, legacy in ANDROID_LEGACY.items():
        target = res / folder
        written.append(save_png(resize(logo, legacy), target / "ic_launcher.png"))
        written.append(
            save_png(resize(logo, legacy), target / "ic_launcher_round.png")
        )
        written.append(
            save_png(
                with_backdrop(logo, round(legacy * 108 / 48)),
                target / "ic_launcher_foreground.png",
            )
        )

    colors = res / "values/colors.xml"
    colors.parent.mkdir(parents=True, exist_ok=True)
    colors.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<resources>\n"
        '    <color name="ic_launcher_background">#0B0F14</color>\n'
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


def main() -> None:
    _force_utf8_stdout()
    parser = argparse.ArgumentParser(description="从 logo.png 生成各平台应用图标")
    parser.add_argument(
        "--check",
        action="store_true",
        help="只检查目标文件是否齐全，不写入磁盘",
    )
    args = parser.parse_args()

    logo = load_logo()

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

    written = build_web(logo) + build_windows(logo) + build_android(logo)
    print(f"✓ 已根据 logo.png 生成 {len(written)} 个图标文件")
    for path in written:
        print(f"  · {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
