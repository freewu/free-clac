# free-clac —— Flutter 高级科学计算器（表达式计算 + 函数绘图）
#
#   常用：just test · just analyze · just run · just build-web
#   列表：直接执行 just（不带参数）
#   说明：在 WSL 中会自动通过 cmd.exe 调用 Windows 侧的 flutter / dart

set shell := ["bash", "-uc"]
# Windows 上用 Git Bash 的 sh（勿用 bash：PATH 里的 bash.exe 通常是 WSL 的，
# 那样会以 Linux 路径执行 flutter 的 shell 脚本而报 $'\r' 错误）
set windows-shell := ["sh", "-uc"]

# 项目根目录与本地预览端口
root := justfile_directory()
port := "8765"

# ---------------------------------------------------------------- 运行环境
# WSL 里 flutter 是 Windows 程序，需要经 cmd.exe 执行；这里把两种平台统一成
# 一个可直接在 bash 中使用的命令。
wsl := if os() == "linux" {
  `grep -qi microsoft /proc/version 2>/dev/null && echo 1 || echo 0`
} else {
  "0"
}
# 在 WSL 中把当前目录换算成 Windows 路径后再调用可执行文件
flutter := if wsl == "1" {
  '_fl() { cmd.exe /c "cd /d $(wslpath -w "$PWD") && flutter $*"; }; _fl'
} else {
  "flutter"
}
dart := if wsl == "1" {
  '_dt() { cmd.exe /c "cd /d $(wslpath -w "$PWD") && dart $*"; }; _dt'
} else {
  "dart"
}
python := if os() == "windows" { "python" } else { "python3" }
# 辅助脚本解释器：Windows 下用 Git Bash 的 sh（bash.exe 会被解析成 WSL 的 bash）
sh := if os() == "windows" { "sh" } else { "bash" }
chrome := if os() == "windows" {
  '"C:/Program Files/Google/Chrome/Application/chrome.exe"'
} else if path_exists("/mnt/c/Program Files/Google/Chrome/Application/chrome.exe") == "true" {
  '"/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"'
} else {
  "google-chrome"
}

# ---------------------------------------------------------------- 默认
# 列出全部命令
default:
    @just --list

# ---------------------------------------------------------------- 开发
# 拉取依赖（flutter pub get）
[group('开发')]
deps:
    @{{flutter}} pub get

# 升级依赖（flutter pub upgrade）
[group('开发')]
upgrade:
    @{{flutter}} pub upgrade

# 运行应用，可附加参数：just run -d chrome
[group('开发')]
run *args:
    @{{flutter}} run {{args}}

# 在 Chrome 中调试 Web 版
[group('开发')]
web:
    @{{flutter}} run -d chrome

# 在 Windows 桌面上调试
[group('开发')]
windows:
    @{{flutter}} run -d windows

# 在 Android 设备 / 模拟器上调试
[group('开发')]
android:
    @{{flutter}} run -d android

# 列出可用设备
[group('开发')]
devices:
    @{{flutter}} devices

# 查看环境诊断
[group('开发')]
doctor:
    @{{flutter}} doctor

# ---------------------------------------------------------------- 质量
# 静态分析（flutter analyze）
[group('质量')]
analyze:
    @{{flutter}} analyze

# 格式化源码（dart format）
[group('质量')]
fmt:
    @{{dart}} format lib test

# 检查格式（CI 用，不修改文件）
[group('质量')]
fmt-check:
    @{{dart}} format --output=none --set-exit-if-changed lib test

# 全部测试，可按名称过滤：just test 历史
[group('质量')]
test filter="":
    @{{flutter}} test {{ if filter == "" { "" } else { "--name '" + filter + "'" } }}

# 计算引擎单元测试
[group('质量')]
test-core:
    @{{flutter}} test test/core_test.dart

# 绘图（视口 / 采样器 / 控制器）测试
[group('质量')]
test-plot:
    @{{flutter}} test test/plot_test.dart

# 布局与交互 Widget 测试
[group('质量')]
test-widget:
    @{{flutter}} test test/widget_test.dart

# 生成覆盖率数据（coverage/lcov.info）
[group('质量')]
cover:
    @{{flutter}} test --coverage
    @echo "覆盖率报告：coverage/lcov.info"

# 提交前检查：格式 + 分析 + 测试
[group('质量')]
check: fmt-check analyze test
    @echo "✓ 检查全部通过"

# ---------------------------------------------------------------- 构建
# 构建 Web 产物到 build/web
[group('构建')]
build-web:
    @{{flutter}} build web --release

# 构建离线可用的 Web 产物（CanvasKit 与字体从本地加载，不依赖 CDN）
# 用途：内网演示、离线截图；体积略大，对外部署用 build-web 即可
[group('构建')]
build-web-offline:
    @{{flutter}} build web --release --no-web-resources-cdn

# 构建 Android APK（缺少 Android SDK / JDK 时给出安装提示）
[group('构建')]
build-apk:
    #!/usr/bin/env sh
    log="$(mktemp)"
    status="$(mktemp)"
    # 用子 shell 记录真实退出码：tee 会吞掉管道的状态
    { {{flutter}} build apk --release 2>&1; echo $? > "$status"; } | tee "$log"
    code="$(cat "$status")"
    rm -f "$status"
    if [ "$code" -eq 0 ]; then
      rm -f "$log"
      echo "✓ APK 输出：build/app/outputs/flutter-apk/app-release.apk"
      exit 0
    fi
    if grep -qE "No Android SDK found|Unable to locate Android SDK|ANDROID_HOME" "$log"; then
      echo ""
      echo "✗ 没有检测到 Android SDK，构建无法继续。"
      echo ""
      echo "  安装步骤："
      echo "   1) 安装 Android Studio（自带 SDK 与 JDK），或用 commandline-tools 单独安装"
      echo "   2) 在 SDK Manager 里安装 Android 14 (API 34) 平台 + Build-Tools + Platform-Tools"
      echo "   3) 设置环境变量并重开终端："
      echo '        ANDROID_HOME = %LOCALAPPDATA%\Android\Sdk'
      echo '        JAVA_HOME    = <JDK 17+ 目录>'
      echo "   4) 接受许可：flutter doctor --android-licenses"
      echo "   5) 验证：flutter doctor -v （Android toolchain 一项应为 ✓）"
      echo ""
      echo "  详见 README「Android 构建」一节。"
    elif grep -qE "requires Java|JAVA_HOME|Unsupported class file" "$log"; then
      echo ""
      echo "✗ 没有找到可用的 JDK。"
      echo "  安装 JDK 17+（Android Studio 自带的 JBR 也可以），设置 JAVA_HOME 后重开终端。"
    fi
    rm -f "$log"
    exit 1

# 构建 Windows 桌面版
[group('构建')]
build-windows:
    @{{flutter}} build windows --release

# 构建 Web + APK
[group('构建')]
build: build-web build-apk

# CI 流水线：依赖 → 检查 → 构建
[group('构建')]
ci: deps check build-web
    @echo "✓ CI 完成"

# ---------------------------------------------------------------- 工具
# 本地预览构建产物（默认 http://localhost:8765）
[group('工具')]
preview port=port: build-web
    @test -d build/web || { echo "缺少 build/web，请先执行 just build-web"; exit 1; }
    @echo "预览：http://localhost:{{port}}"
    @{{python}} -m http.server {{port}} --directory build/web

# 根据 logo.png 重新生成各平台应用图标（Web / Windows / Android，需 python3 + Pillow）
[group('工具')]
icons:
    @{{python}} tool/generate_icons.py

# 检查图标是否齐全（CI 可用）
[group('工具')]
icons-check:
    @{{python}} tool/generate_icons.py --check

# 重新生成 README 截图（docs/screenshots，离线构建以免 CDN 不可达时白屏）
[group('工具')]
shots: build-web-offline
    @{{sh}} tool/screenshot.sh "{{port}}"

# 清理构建产物
[group('工具')]
[confirm('确定清理 build/、.dart_tool/、coverage/ 吗？')]
clean:
    @{{flutter}} clean
    @rm -rf build .dart_tool coverage
    @echo "✓ 已清理"

# 重新下载引擎产物（Windows 报 flutter_windows.dll.pdb notFound 时用）
[group('工具')]
precache:
    @{{flutter}} precache --windows --force

# 查看可升级的依赖
[group('工具')]
outdated:
    @{{flutter}} pub outdated
