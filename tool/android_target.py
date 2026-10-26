"""从 flutter 的输出里挑出要用的 Android 目标，供 justfile 使用。

用法::

    flutter devices --machine | python tool/android_target.py device
    flutter emulators         | python tool/android_target.py emulator

输出目标的 id（最后一行），没有可用目标时输出空行并返回退出码 1。
`--selftest` 跑一组内置断言，供 `just check` 调用。
"""

import json
import sys


def pick_device(text: str) -> str:
    """从 `flutter devices --machine` 的 JSON 里取第一个 Android 设备 id。"""
    start = text.find("[")
    if start < 0:
        return ""
    try:
        devices = json.loads(text[start:])
    except json.JSONDecodeError:
        return ""
    for device in devices:
        platform = str(device.get("targetPlatform", ""))
        if platform.startswith("android"):
            return str(device.get("id", ""))
    return ""


def pick_emulator(text: str) -> str:
    """从 `flutter emulators` 的表格里取第一个 Android AVD 的 id。

    每行形如 ``free_clac_api36 • free clac api36 • Google • android``。
    """
    for line in text.splitlines():
        if "•" not in line:
            continue
        parts = [part.strip() for part in line.split("•")]
        if len(parts) >= 2 and parts[-1].lower().endswith("android"):
            return parts[0]
    return ""


def selftest() -> int:
    """跑一组内置断言，避免解析逻辑改动后静默失效。"""
    devices = (
        "Flutter assets will be downloaded\n"
        '[{"id": "emulator-5554", "targetPlatform": "android-x64"},'
        ' {"id": "windows", "targetPlatform": "windows-x64"}]'
    )
    assert pick_device(devices) == "emulator-5554"
    assert pick_device('[{"id": "windows", "targetPlatform": "windows-x64"}]') == ""
    assert pick_device("") == ""
    assert pick_device("not json") == ""

    emulators = (
        "1 available emulator:\n\n"
        "Id              • Name            • Manufacturer • Platform\n\n"
        "free_clac_api36 • free clac api36 • Google       • android\n"
    )
    assert pick_emulator(emulators) == "free_clac_api36"
    assert pick_emulator("No emulators available") == ""
    assert pick_emulator("pixel • Pixel 7 • Google • android\n") == "pixel"
    print("✓ android_target 自检通过")
    return 0


def main(argv: list[str]) -> int:
    if len(argv) > 1 and argv[1] == "--selftest":
        return selftest()
    mode = argv[1] if len(argv) > 1 else "device"
    text = sys.stdin.read()
    target = pick_emulator(text) if mode == "emulator" else pick_device(text)
    if not target:
        return 1
    print(target)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
