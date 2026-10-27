#!/usr/bin/env python3
"""把 Flutter Web 引擎的默认回退字体下载到 web/fonts/，供离线构建使用。

CanvasKit 渲染文字时，如果某个字形没有任何已加载字体可以覆盖，引擎会去
`https://fonts.gstatic.com/s/` 下载对应的 Noto 分片（Roboto 用于拉丁字形、
Noto Sans SC 用于汉字）。内网 / 离线环境拿不到这些文件，文字就会变成方块。

本脚本从本地 Flutter SDK 里读出引擎实际使用的字体清单，把需要的文件按
原来的相对路径（如 `roboto/v32/xxx.woff2`）下载到 `web/fonts/`，配合
`web/flutter_bootstrap.js` 里的 `fontFallbackBaseUrl: 'fonts/'` 即可完全离线。

用法：
    python3 tool/web_fonts.py            # 下载缺失的字体（已存在则跳过）
    python3 tool/web_fonts.py --check    # 只检查是否齐全，缺失时退出码 1
    python3 tool/web_fonts.py --selftest # 不联网的自检
"""

from __future__ import annotations

import argparse
import concurrent.futures
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "web" / "fonts"

# 依次尝试的下载源：官方 gstatic 优先，国内镜像兜底
MIRRORS = [
    "https://fonts.gstatic.com/s/",
    "https://gstatic.loli.net/s/",
]

# 中文界面需要覆盖的字形：拉丁（Roboto）、简体中文、符号 / 数学 / 表情
FAMILIES = (
    "roboto",
    "notosanssc",
    "notosanssymbols",
    "notosanssymbols2",
    "notosansmath",
    "notosans",
)

ENGINE_DIR = Path("bin/cache/flutter_web_sdk/lib/_engine/engine")

_NOTO_RE = re.compile(r"NotoFont\(\s*'([^']*)'\s*,\s*'([^']*)'\s*,?\s*\)")
_ROBOTO_RE = re.compile(
    r"_robotoUrl\s*=\s*\n?\s*'\$\{configuration\.fontFallbackBaseUrl\}([^']+)'"
)


def _force_utf8_stdout() -> None:
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")  # type: ignore[attr-defined]
        except (AttributeError, ValueError):
            pass


def _is_sdk(path: Path) -> bool:
    return (path / ENGINE_DIR).is_dir()


def flutter_root() -> Path:
    """定位 Flutter SDK：FLUTTER_ROOT > PATH 里的 flutter / dart > 常见安装位置。"""
    env = os.environ.get("FLUTTER_ROOT")
    if env:
        candidate = Path(env)
        for path in (candidate, candidate / "bin" / ".."):
            if _is_sdk(path):
                return path.resolve()
        raise SystemExit(f"✗ FLUTTER_ROOT={env} 不像 Flutter SDK 目录")

    from shutil import which

    exe = which("flutter")
    if exe:
        # Windows 上 flutter 位于 <sdk>/bin/flutter(.bat)
        candidate = Path(exe).resolve().parent.parent
        if _is_sdk(candidate):
            return candidate

    candidates = [
        Path("C:/flutter"),
        Path("/mnt/c/flutter"),
        Path.home() / "flutter",
        Path.home() / "development" / "flutter",
    ]
    for candidate in candidates:
        if _is_sdk(candidate):
            return candidate.resolve()

    raise SystemExit(
        "✗ 找不到 Flutter SDK，请设置 FLUTTER_ROOT，例如：\n"
        "    export FLUTTER_ROOT=C:/flutter",
    )


def parse_fonts(data_source: str, roboto_source: str) -> list[str]:
    """从引擎源码里取出需要的字体相对路径（去重、保持稳定顺序）。"""
    urls: list[str] = []
    for _name, url in _NOTO_RE.findall(data_source):
        if url.split("/", 1)[0] in FAMILIES and url not in urls:
            urls.append(url)
    match = _ROBOTO_RE.search(roboto_source)
    if match is not None and match.group(1) not in urls:
        urls.append(match.group(1))
    return [url for url in urls if url.split("/", 1)[0] in FAMILIES]


def plan_files() -> list[str]:
    root = flutter_root()
    engine = root / ENGINE_DIR
    urls = parse_fonts(
        (engine / "font_fallback_data.dart").read_text(encoding="utf-8"),
        (engine / "canvaskit" / "fonts.dart").read_text(encoding="utf-8"),
    )
    if not urls:
        raise SystemExit("✗ 没能从 Flutter SDK 里解析出字体清单，请检查 SDK 版本")
    return urls


def missing_files(urls: list[str]) -> list[str]:
    return [url for url in urls if not (OUT_DIR / url).is_file()]


def download(relative: str) -> str:
    target = OUT_DIR / relative
    if target.is_file():
        return "skip"
    target.parent.mkdir(parents=True, exist_ok=True)
    last_error = ""
    for base in MIRRORS:
        try:
            with urllib.request.urlopen(base + relative, timeout=30) as response:
                data = response.read()
        except (urllib.error.URLError, TimeoutError) as error:  # 网络问题
            last_error = f"{base}: {error}"
            continue
        if not data:
            last_error = f"{base}: 空响应"
            continue
        target.write_bytes(data)
        return "ok"
    raise SystemExit(f"✗ 下载失败 {relative}\n  最后一次错误 {last_error}")


def selftest() -> int:
    data_source = """
  NotoFont(
    'Noto Sans SC 0',
    'notosanssc/v37/aaa.4.woff2',
  ),
  NotoFont(
    'Noto Sans JP 0',
    'notosansjp/v52/bbb.0.woff2',
  ),
  NotoFont(
    'Noto Sans Symbols',
    'notosanssymbols/v43/ccc.woff2',
  ),
  NotoFont(
    'Noto Sans Symbols',
    'notosanssymbols/v43/ccc.woff2',
  ),
"""
    roboto_source = (
        "String _robotoUrl =\n"
        "    '${configuration.fontFallbackBaseUrl}roboto/v32/ddd.woff2';"
    )
    urls = parse_fonts(data_source, roboto_source)
    assert urls == [
        "notosanssc/v37/aaa.4.woff2",
        "notosanssymbols/v43/ccc.woff2",
        "roboto/v32/ddd.woff2",
    ], urls
    assert parse_fonts("", "") == []
    assert _is_sdk(Path("/nonexistent")) is False
    print("✓ web_fonts 自检通过")
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="下载 Flutter Web 离线字体")
    parser.add_argument("--check", action="store_true", help="只检查是否齐全")
    parser.add_argument("--selftest", action="store_true", help="运行自检")
    args = parser.parse_args(argv)

    _force_utf8_stdout()
    if args.selftest:
        return selftest()

    urls = plan_files()
    if args.check:
        missing = missing_files(urls)
        if missing:
            print(f"✗ web/fonts 缺少 {len(missing)}/{len(urls)} 个文件")
            print("  执行 just web-fonts 下载后再构建")
            return 1
        print(f"✓ web/fonts 齐全（{len(urls)} 个文件）")
        return 0

    missing = missing_files(urls)
    if not missing:
        print(f"✓ web/fonts 已是最新（{len(urls)} 个文件）")
        return 0

    print(f"下载 {len(missing)} 个字体文件（共 {len(urls)} 个）…")
    done = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        for status in pool.map(download, missing):
            if status == "ok":
                done += 1
    total = sum((OUT_DIR / url).stat().st_size for url in urls)
    print(f"✓ 下载完成 {done} 个，web/fonts 共 {total / 1024 / 1024:.1f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
