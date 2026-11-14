#!/usr/bin/env python3
"""版本号与发布说明：给 `.github/workflows/release.yml` 和本地 `just bump` 共用。

用法：
    python3 tool/release.py version                  # 打印 1.0.0+1
    python3 tool/release.py bump 1.1.0               # 改 pubspec.yaml（构建号自动 +1）
    python3 tool/release.py bump 1.1.0 --build 9     # 指定构建号
    python3 tool/release.py notes --version 1.1.0    # 打印发布说明（Markdown）
    python3 tool/release.py notes --version 1.1.0 --out RELEASE_NOTES.md
    python3 tool/release.py --selftest               # 自检（不跑 git、不写文件）

发布说明的取值顺序：
    1. `--notes` 里手写的正文（工作流手动触发时可以填）；
    2. CHANGELOG.md 里 `## [版本号]` 这一节（维护了就用它）；
    3. 上一个 `v*` 标签以来的提交记录（本仓库的提交信息就是一条摘要 + 若干条正文，
       直接摊成 Markdown 列表读起来不错）。
最后统一拼上「下载」表格与构建信息。
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBSPEC = ROOT / "pubspec.yaml"
CHANGELOG = ROOT / "CHANGELOG.md"

# 一次发布最多摊多少条提交，免得连续大改时发布页刷出一屏
MAX_COMMITS = 50
# 单条提交的正文最多保留多少行
MAX_BODY_LINES = 8

VERSION_LINE = re.compile(r"^version:\s*(\S+)\s*$", re.MULTILINE)


# ── 纯函数部分（自检只测这里） ───────────────────────────────────────


def parse_version(pubspec_text: str) -> tuple[str, str]:
    """从 pubspec.yaml 里取出版本名与构建号："1.0.0+1" → ("1.0.0", "1")。"""
    match = VERSION_LINE.search(pubspec_text)
    if not match:
        raise ValueError("pubspec.yaml 里找不到 `version:` 行")
    raw = match.group(1)
    name, _, build = raw.partition("+")
    return name.strip(), (build.strip() or "1")


def bump_version(pubspec_text: str, name: str, build: str | None = None) -> str:
    """改写 version 行；不传构建号时在原构建号上 +1。"""
    old_name, old_build = parse_version(pubspec_text)
    next_build = build if build is not None else str(int(old_build) + 1)
    if not re.fullmatch(r"\d+\.\d+\.\d+", name):
        raise ValueError(f"版本号格式不对：{name}（应该像 1.2.0）")
    if not next_build.isdigit():
        raise ValueError(f"构建号必须是整数：{next_build}")
    assert old_name  # 只为表明这里用到了旧值，避免 linter 报警
    return VERSION_LINE.sub(f"version: {name}+{next_build}", pubspec_text, count=1)


def changelog_section(text: str, version: str) -> str | None:
    """取 CHANGELOG 里某一版的内容：`## [1.2.0]` 到下一个二级标题之前。"""
    pattern = re.compile(
        r"^##\s*\[?" + re.escape(version) + r"\]?[^\n]*\n(.*?)(?=^##\s|\Z)",
        re.MULTILINE | re.DOTALL,
    )
    match = pattern.search(text)
    if not match:
        return None
    body = match.group(1).strip("\n")
    return body or None


def format_commit(subject: str, body: str, short_sha: str) -> str:
    """一条提交 → 一段 Markdown：摘要加粗，正文缩进成子列表。"""
    lines = [line.rstrip() for line in (body or "").splitlines()]
    # 正文里空行、签名、fixup 之类不往发布页上放
    keep: list[str] = []
    for line in lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.lower().startswith(("co-authored-by:", "signed-off-by:")):
            continue
        keep.append(stripped)
    keep = keep[:MAX_BODY_LINES]
    out = [f"- **{subject.strip()}**（`{short_sha}`）"]
    out.extend(f"  {line}" for line in keep)
    return "\n".join(out)


def commits_to_notes(log: str) -> str:
    """`git log` 的输出（用 --format=%H%x1f%s%x1f%b%x1e 分隔）→ Markdown 列表。"""
    chunks = [chunk for chunk in log.split("\x1e") if chunk.strip()]
    rendered: list[str] = []
    for chunk in chunks[:MAX_COMMITS]:
        sha, _, rest = chunk.partition("\x1f")
        subject, _, body = rest.partition("\x1f")
        rendered.append(format_commit(subject, body, sha.strip()[:7]))
    return "\n".join(rendered)


def compose(
    version: str,
    notes: str,
    *,
    apk_name: str,
    ipa_name: str,
    web_name: str = "",
    sha: str = "",
    date: str = "",
) -> str:
    """拼出最终的发布正文：更新内容 + 下载表 + 构建信息。"""
    body = notes.strip() or "本版本没有单独的更新说明，详见提交记录。"
    rows = [
        ("Android", f"`{apk_name}`", "直接安装（调试密钥签名，用于自用与测试）"),
        ("iOS", f"`{ipa_name}`", "未签名，需用 Sideloadly / AltStore 自签后安装"),
    ]
    if web_name:
        rows.append(("Web", f"`{web_name}`", "解压后用任意静态服务器打开"))

    table = ["| 平台 | 文件 | 说明 |", "| --- | --- | --- |"]
    table.extend(f"| {platform} | {file} | {note} |" for platform, file, note in rows)

    footer = []
    if sha:
        footer.append(f"构建自提交 `{sha[:7]}`" + (f"，{date}" if date else ""))
    if footer:
        footer.append("")
        footer.append(
            "> 计算引擎、绘图与全部工具都在本地运行，安装包不含统计与联网代码。"
        )

    return "\n".join(
        [
            "## 更新内容",
            "",
            body,
            "",
            "## 下载",
            "",
            *table,
            "",
            *(footer or []),
        ]
    ).strip() + "\n"


# ── 读仓库（只有 CLI 会用到） ────────────────────────────────────────


def _force_utf8_stdout() -> None:
    """Windows 控制台默认 GBK，直接 print(✓) 会抛 UnicodeEncodeError。"""
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is not None:
            reconfigure(encoding="utf-8", errors="replace")


def git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if result.returncode != 0:
        raise SystemExit(f"✗ git {' '.join(args)} 失败：{result.stderr.strip()}")
    return result.stdout


def try_git(*args: str) -> str:
    """失败不致命（比如仓库里还没有任何标签）。"""
    try:
        return git(*args)
    except SystemExit:
        return ""


def previous_tag(version: str) -> str:
    """比目标版本旧、且最新的那个 v* 标签；没有就返回空串（= 从头开始数）。"""
    tags = [line.strip() for line in try_git("tag", "--list", "v*").splitlines()]
    tags = [tag for tag in tags if tag.strip()]
    if not tags:
        return ""
    # 版本号排序交给 git，省得自己处理 1.10 与 1.9 的大小
    ordered = try_git("tag", "--list", "v*", "--sort=-v:refname").split()
    for tag in ordered:
        if tag != f"v{version}":
            return tag
    return ""


def notes_from_git(version: str, since: str | None) -> str:
    base = since if since is not None else previous_tag(version)
    args = [
        "log",
        f"--max-count={MAX_COMMITS}",
        "--format=%H%x1f%s%x1f%b%x1e",
    ]
    if base:
        args.append(f"{base}..HEAD")
    return commits_to_notes(git(*args))


def build_notes(version: str, since: str | None, note: str) -> str:
    if note.strip():
        return note
    if CHANGELOG.exists():
        section = changelog_section(CHANGELOG.read_text(encoding="utf-8"), version)
        if section:
            return section
    return notes_from_git(version, since)


def selftest() -> None:
    pubspec = "name: demo\nversion: 1.2.3+7\ndependencies:\n  flutter:\n    sdk: flutter\n"
    assert parse_version(pubspec) == ("1.2.3", "7")
    assert parse_version("version: 2.0.0\n") == ("2.0.0", "1")

    bumped = bump_version(pubspec, "1.3.0")
    assert "version: 1.3.0+8" in bumped
    assert bumped.replace("version: 1.3.0+8", "version: 1.2.3+7") == pubspec
    assert "version: 1.3.0+9" in bump_version(pubspec, "1.3.0", build="9")

    for bad in ("1.3", "v1.3.0", "1.3.0-rc1"):
        try:
            bump_version(pubspec, bad)
        except ValueError:
            pass
        else:  # pragma: no cover - 断言失败就该报错
            raise AssertionError(f"应该拒绝版本号 {bad}")
    try:
        bump_version(pubspec, "1.3.0", build="x")
    except ValueError:
        pass
    else:  # pragma: no cover
        raise AssertionError("应该拒绝非整数构建号")

    changelog = (
        "# 更新日志\n\n"
        "## [1.3.0] 2026-05-01\n\n- 新增官网\n- 修掉卡顿\n\n"
        "## [1.2.0] 2026-04-01\n\n- 旧版本的内容\n"
    )
    assert changelog_section(changelog, "1.3.0") == "- 新增官网\n- 修掉卡顿"
    assert changelog_section(changelog, "1.2.0") == "- 旧版本的内容"
    assert changelog_section(changelog, "9.9.9") is None
    # 空小节不能被当成有效内容
    assert changelog_section("## [1.3.0]\n\n## [1.2.0]\n- x\n", "1.3.0") is None

    log = (
        "abc1234\x1f新增官网 docs/\x1f- 深色 / 浅色\n- 五种语言\n\n"
        "Co-authored-by: nobody <n@example.com>\x1e"
        "def5678\x1f修掉卡顿\x1f\x1e"
    )
    notes = commits_to_notes(log)
    assert "- **新增官网 docs/**（`abc1234`）" in notes
    assert "  - 深色 / 浅色" in notes
    assert "Co-authored-by" not in notes
    assert "- **修掉卡顿**（`def5678`）" in notes
    assert notes.count("\n- ") == 1, notes

    # 正文超过上限要截断，别把发布页撑爆
    long_body = "\n".join(f"第{i}行" for i in range(20))
    clipped = format_commit("标题", long_body, "0123456")
    assert clipped.count("\n  ") == MAX_BODY_LINES, clipped
    assert commits_to_notes("") == ""

    note_body = compose(
        "1.3.0",
        "加了官网",
        apk_name="free-clac-1.3.0.apk",
        ipa_name="free-clac-1.3.0.ipa",
        sha="abcdef1234567890",
        date="2026-05-01",
    )
    assert note_body.startswith("## 更新内容\n\n加了官网")
    assert "| Android | `free-clac-1.3.0.apk` |" in note_body
    assert "| iOS | `free-clac-1.3.0.ipa` |" in note_body
    assert "`abcdef1`" in note_body and "2026-05-01" in note_body
    # 没有说明时要有兜底文案，不能出现空的「更新内容」
    assert "没有单独的更新说明" in compose(
        "1.3.0", "", apk_name="a.apk", ipa_name="a.ipa"
    )
    assert compose("1.3.0", "x", apk_name="a.apk", ipa_name="a.ipa", web_name="w.zip").count(
        "| Web |"
    ) == 1

    print("✓ release 自检通过")


# ── CLI ─────────────────────────────────────────────────────────────


def main() -> None:
    _force_utf8_stdout()
    parser = argparse.ArgumentParser(description="版本号与发布说明")
    parser.add_argument("--selftest", action="store_true", help="自检，不读写仓库文件")
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("version", help="打印 pubspec.yaml 里的版本号")

    bump = sub.add_parser("bump", help="改 pubspec.yaml 的版本号")
    bump.add_argument("version", help="新版本号，如 1.3.0")
    bump.add_argument("--build", help="构建号，默认在原值上 +1")
    bump.add_argument("--dry-run", action="store_true", help="只打印结果，不写文件")

    notes = sub.add_parser("notes", help="生成发布说明")
    notes.add_argument("--version", help="版本号，默认取 pubspec.yaml")
    notes.add_argument("--since", help="从这里之后的提交取更新内容，默认上一个 v* 标签")
    notes.add_argument("--notes", default="", help="手写的更新内容，优先级最高")
    notes.add_argument("--out", help="写到文件（不传就打印到标准输出）")

    args = parser.parse_args()

    if args.selftest:
        selftest()
        return

    if args.command == "version":
        name, build = parse_version(PUBSPEC.read_text(encoding="utf-8"))
        print(f"{name}+{build}")
        return

    if args.command == "bump":
        text = PUBSPEC.read_text(encoding="utf-8")
        updated = bump_version(text, args.version, args.build)
        name, build = parse_version(updated)
        if args.dry_run:
            print(updated, end="")
            return
        PUBSPEC.write_text(updated, encoding="utf-8")
        print(f"✓ pubspec.yaml 版本已改为 {name}+{build}")
        print("  下一步：git commit -am \"发布 v" + name + "\" && git push")
        return

    if args.command == "notes":
        name = args.version
        if not name:
            name, _ = parse_version(PUBSPEC.read_text(encoding="utf-8"))
        body = compose(
            name,
            build_notes(name, args.since, args.notes),
            apk_name=f"free-clac-{name}.apk",
            ipa_name=f"free-clac-{name}.ipa",
            sha=try_git("rev-parse", "HEAD").strip(),
            date=try_git("log", "-1", "--date=short", "--format=%ad").strip(),
        )
        if args.out:
            Path(args.out).write_text(body, encoding="utf-8")
            print(f"✓ 发布说明已写入 {args.out}")
        else:
            print(body, end="")
        return

    parser.print_help()


if __name__ == "__main__":
    main()
