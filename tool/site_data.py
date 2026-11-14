#!/usr/bin/env python3
"""把 App 的工具元数据导出成官网（docs/）用的 JS 数据文件。

官网工具区里的名称、卖点、说明、强调色必须和 App 界面完全一致，所以这里
直接读源码，生成 `docs/assets/tools-data.js`：

    lib/ui/tools/tool_catalog.dart         工具顺序（kTools）
    lib/ui/tools/<tool>/defined.dart       工具 id、AppColors 配色、可用语言
    lib/ui/tools/<tool>/<tool>_lang.dart   五种语言的名称 / 卖点 / 说明
    lib/theme/app_theme.dart               深色与浅色两套配色的取色表

用法：
    python3 tool/site_data.py             # 重新生成 docs/assets/tools-data.js
    python3 tool/site_data.py --check     # 只检查是否过期（CI 用）
    python3 tool/site_data.py --selftest  # 自检解析逻辑，不读写磁盘
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOLS_DIR = ROOT / "lib/ui/tools"
CATALOG = TOOLS_DIR / "tool_catalog.dart"
THEME = ROOT / "lib/theme/app_theme.dart"
TARGET = ROOT / "docs/assets/tools-data.js"

# Dart 枚举名 → 语言代码（与官网 docs/assets/site.js 的键一致）
LANGUAGES = {
    "zhHans": "zh-Hans",
    "zhHant": "zh-Hant",
    "en": "en",
    "ja": "ja",
    "es": "es",
}


def parse_argument_list(source: str, start: int) -> list[str]:
    """从 `ToolText(` 之后的第一个字符开始，切出三段字符串字面量。

    Dart 里长文案常写成相邻字面量拼接（`'abc ' 'def'`），这里按逗号分段，
    每段内部把字面量直接连起来。
    """
    parts: list[str] = []
    current = ""
    i = start
    while i < len(source):
        char = source[i]
        if char == "'":
            i += 1
            while i < len(source):
                inner = source[i]
                if inner == "\\":
                    current += source[i + 1]
                    i += 2
                    continue
                if inner == "'":
                    i += 1
                    break
                current += inner
                i += 1
            continue
        if char == "," or char == ")":
            if current.strip():
                parts.append(current.strip())
            current = ""
            if char == ")":
                return parts
            i += 1
            continue
        i += 1
    return parts


def parse_tool_text(source: str) -> dict[str, dict[str, str]]:
    """解析一份 `<tool>_lang.dart`，返回 {语言代码: {name, tagline, desc}}。"""
    text: dict[str, dict[str, str]] = {}
    for enum_name, code in LANGUAGES.items():
        match = re.search(rf"AppLanguage\.{enum_name}: ToolText\(", source)
        if match is None:
            continue
        parts = parse_argument_list(source, match.end())
        if len(parts) != 3:
            raise ValueError(f"{enum_name} 的 ToolText 参数不是三段：{parts}")
        text[code] = {"name": parts[0], "tagline": parts[1], "desc": parts[2]}
    return text


def parse_palettes(source: str) -> dict[str, dict[str, str]]:
    """解析 kDarkPalette / kLightPalette，返回 {名称: {dark, light}}。"""
    palettes: dict[str, dict[str, str]] = {}
    for key, code in (("kDarkPalette", "dark"), ("kLightPalette", "light")):
        match = re.search(rf"{key} = AppPalette\((.*?)\n\);", source, re.S)
        if match is None:
            raise ValueError(f"没找到 {key}")
        for name, value in re.findall(
            r"^\s{2}(\w+): Color\(0x[Ff]{2}([0-9A-Fa-f]{6})\)", match.group(1), re.M
        ):
            palettes.setdefault(name, {})[code] = f"#{value.upper()}"
    return palettes


def parse_tool_order(catalog: str) -> list[str]:
    """按 kTools 里的顺序取出工具变量名（bmiTool → bmi）。"""
    return re.findall(r"^\s{2}(\w+)Tool,\s*$", catalog, re.M)


def parse_defined(source: str) -> dict[str, object]:
    """解析一个 defined.dart：id、配色、可用语言。"""
    tool_id = re.search(r"id: '([\w-]+)'", source)
    color = re.search(r"color: AppColors\.(\w+)", source)
    if tool_id is None or color is None:
        raise ValueError("defined.dart 缺少 id 或 color")
    only = re.search(r"availableIn: const \{([^}]*)\}", source)
    languages = None
    if only is not None:
        languages = [
            LANGUAGES[name]
            for name in re.findall(r"AppLanguage\.(\w+)", only.group(1))
            if name in LANGUAGES
        ]
    return {
        "id": tool_id.group(1),
        "color": color.group(1),
        "only": languages,
    }


def collect() -> list[dict[str, object]]:
    catalog = CATALOG.read_text(encoding="utf-8")
    palettes = parse_palettes(THEME.read_text(encoding="utf-8"))
    tools: list[dict[str, object]] = []
    for variable in parse_tool_order(catalog):
        folder = TOOLS_DIR / variable
        defined = parse_defined((folder / "defined.dart").read_text(encoding="utf-8"))
        lang_file = folder / f"{variable}_lang.dart"
        text = parse_tool_text(lang_file.read_text(encoding="utf-8"))
        missing = [code for code in LANGUAGES.values() if code not in text]
        if missing:
            raise ValueError(f"{variable} 缺少语言：{missing}")
        color = defined["color"]
        assert isinstance(color, str)
        if color not in palettes:
            raise ValueError(f"配色表里没有 AppColors.{color}")
        tools.append(
            {
                "id": defined["id"],
                "color": palettes[color],
                "only": defined["only"],
                "text": text,
            }
        )
    return tools


HEADER = """\
// 本文件由 tool/site_data.py 自动生成，请不要手工修改。
// 改了 lib/ui/tools/ 里的语言包或配色后，跑 `just site-data` 重新生成。
// 官网工具区的文案必须和 App 界面一致，所以统一从源码导出。
"""


def render(tools: list[dict[str, object]]) -> str:
    body = json.dumps(tools, ensure_ascii=False, indent=2)
    return f"{HEADER}window.FREE_CLAC_TOOLS = {body};\n"


def selftest() -> None:
    sample = """
const Map<AppLanguage, ToolText> kDemoLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '演示',
    '一句话',
    '前半段 '
        '后半段',
  ),
  AppLanguage.en: ToolText('Demo', 'One line', 'First half second half'),
};
"""
    text = parse_tool_text(sample)
    assert text["zh-Hans"] == {
        "name": "演示",
        "tagline": "一句话",
        "desc": "前半段 后半段",
    }, text["zh-Hans"]
    assert text["en"]["desc"] == "First half second half"
    assert "ja" not in text

    palette = """
const AppPalette kDarkPalette = AppPalette(
  brightness: Brightness.dark,
  primary: Color(0xFF4F9CFF),
);

const AppPalette kLightPalette = AppPalette(
  brightness: Brightness.light,
  primary: Color(0xFF1F6FEB),
);
"""
    parsed = parse_palettes(palette)
    assert parsed["primary"] == {"dark": "#4F9CFF", "light": "#1F6FEB"}, parsed

    order = parse_tool_order(
        "List<ToolInfo> get kTools => List.unmodifiable(<ToolInfo>[\n"
        "  bmiTool,\n  loanTool,\n]);\n"
    )
    assert order == ["bmi", "loan"], order

    defined = parse_defined(
        "ToolInfo get bmiTool => ToolInfo(\n"
        "  id: 'bmi',\n  color: AppColors.tertiary,\n"
        "  availableIn: const {AppLanguage.zhHans, AppLanguage.zhHant},\n);\n"
    )
    assert defined == {
        "id": "bmi",
        "color": "tertiary",
        "only": ["zh-Hans", "zh-Hant"],
    }, defined
    print("✓ site_data 自检通过")


def _force_utf8_stdout() -> None:
    """Windows 控制台默认 GBK，直接 print(✓) 会抛 UnicodeEncodeError。"""
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")


def main() -> None:
    _force_utf8_stdout()
    parser = argparse.ArgumentParser(description="导出官网用的工具数据")
    parser.add_argument(
        "--check", action="store_true", help="只检查 docs/assets/tools-data.js 是否最新"
    )
    parser.add_argument(
        "--selftest", action="store_true", help="用内置样例自检解析逻辑"
    )
    args = parser.parse_args()

    if args.selftest:
        selftest()
        return

    rendered = render(collect())
    if args.check:
        current = TARGET.read_text(encoding="utf-8") if TARGET.exists() else ""
        if current != rendered:
            print("✗ docs/assets/tools-data.js 已过期，请执行 just site-data")
            sys.exit(1)
        print("✓ 官网工具数据是最新的")
        return

    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(rendered, encoding="utf-8")
    print(f"✓ 已生成 {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
