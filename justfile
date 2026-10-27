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
  '_fl() { WSLENV="JAVA_HOME:ANDROID_HOME:ANDROID_SDK_ROOT:${WSLENV:-}" cmd.exe /c "cd /d $(wslpath -w "$PWD") && flutter $*"; }; _fl'
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

# 在 Chrome 中调试 Web 版（CanvasKit 用本地副本，断网也能调试）
[group('开发')]
web: web-fonts
    @{{flutter}} run -d chrome --no-web-resources-cdn

# 在 Windows 桌面上调试
[group('开发')]
windows:
    @{{flutter}} run -d windows

# 在 Android 设备 / 模拟器上调试（自动选中第一个 Android 目标）
[group('开发')]
android:
    @. tool/android-env.sh; \
      id=$({{flutter}} devices --machine | {{python}} tool/android_target.py device); \
      [ -n "$id" ] || { \
        echo "✗ 没有检测到 Android 设备或模拟器。"; \
        echo "  · 真机：设置里打开「开发者选项 → USB 调试」，插入后允许本机调试"; \
        echo "  · 模拟器：先 just emulator 启动一个 AVD，再回来运行 just android"; \
        exit 1; }; \
      echo "  目标设备：$id"; \
      {{flutter}} run -d "$id"

# 启动 Android 模拟器（默认第一个 AVD）
[group('开发')]
emulator avd="":
    @. tool/android-env.sh; \
      id={{avd}}; \
      [ -n "$id" ] || id=$({{flutter}} emulators | {{python}} tool/android_target.py emulator); \
      [ -n "$id" ] || { \
        echo "✗ 没有可用的 AVD。"; \
        echo "  查看已有模拟器：{{flutter}} emulators"; \
        echo "  新建一个：avdmanager create avd -n <名字> -k <镜像名>"; \
        echo "  镜像名示例：system-images;android-36;google_apis;x86_64"; \
        exit 1; }; \
      echo "  启动模拟器：$id"; \
      {{flutter}} emulators --launch "$id"

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
    @{{dart}} format lib test integration_test

# 检查格式（CI 用，不修改文件）
[group('质量')]
fmt-check:
    @{{dart}} format --output=none --set-exit-if-changed lib test integration_test

# 在 Android 设备 / 模拟器上验证导出写进相册（需先连上设备）
[group('质量')]
test-android:
    @. tool/android-env.sh; \
      id=$({{flutter}} devices --machine | {{python}} tool/android_target.py device); \
      [ -n "$id" ] || { \
        echo "✗ 没有检测到 Android 设备或模拟器。"; \
        echo "  · 真机：插上后允许本机调试，或先用 just emulator 启动模拟器"; \
        exit 1; }; \
      echo "  目标设备：$id"; \
      {{flutter}} test integration_test/android_save_test.dart -d "$id"

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
check: fmt-check analyze test tool-check
    @echo "✓ 检查全部通过"

# ---------------------------------------------------------------- 构建
# 构建 Web 产物到 build/web
#
# 完全自包含：CanvasKit 与 Flutter 运行时用 SDK 自带副本
# （--no-web-resources-cdn），Roboto / Noto 回退字体放在 web/fonts/，
# 内网或断网环境也不会白屏、中文不会变成方块。
# 想要体积更小、可直连 gstatic 的部署，用 build-web-cdn。
[group('构建')]
build-web: web-fonts
    @{{flutter}} build web --release --no-web-resources-cdn
    @grep -q '"useLocalCanvasKit":true' build/web/flutter_bootstrap.js \
      || { echo "✗ CanvasKit 仍在用 CDN，请检查 --no-web-resources-cdn"; exit 1; }
    @rm -rf build/web/fonts && mkdir -p build/web/fonts && cp -R web/fonts/. build/web/fonts/
    @{{python}} tool/web_fonts.py --check
    @test -f build/web/fonts/roboto/v32/KFOmCnqEu92Fr1Me4GZLCzYlKw.woff2 \
      || { echo "✗ 离线字体没有拷进 build/web/fonts"; exit 1; }
    @echo "✓ Web 产物自包含：CanvasKit 与字体都在本地"

# 构建使用 Google CDN 的 Web 产物（体积小，需要能访问 gstatic）
[group('构建')]
build-web-cdn:
    @{{flutter}} build web --release

# 旧名字，等价于 build-web（保留以兼容脚本）
[group('构建')]
build-web-offline: build-web

# 下载 Web 离线字体到 web/fonts/（Roboto + Noto Sans SC 等，约 3 MB）
# 由 tool/web_fonts.py 从本地 Flutter SDK 里读出引擎字体清单后下载
[group('构建')]
web-fonts:
    @{{python}} tool/web_fonts.py

# 构建 Android APK（缺少 Android SDK / JDK 时给出安装提示）
#
# 这里刻意不用 shebang 配方：just 在 Windows 上会用 cygpath 翻译 shebang 的
# 解释器路径，而 Git for Windows 默认只把 cmd/ 和 bin/ 放进 PATH，
# 缺少 cygpath 时直接报 “could not find `cygpath`”。
# 普通配方 + 行连接（\）在 PowerShell 与 WSL 下行为一致。
[group('构建')]
build-apk:
    @. tool/android-env.sh; \
      log=$(mktemp) && status=$(mktemp) && \
      { {{flutter}} build apk --release 2>&1; echo $? > "$status"; } | tee "$log" && \
      code=$(cat "$status") && rm -f "$status" && \
      if [ "$code" -eq 0 ]; then \
        rm -f "$log"; \
        echo "✓ APK 输出：build/app/outputs/flutter-apk/app-release.apk"; \
        exit 0; \
      fi; \
      if grep -qE "No Android SDK found|Unable to locate Android SDK|ANDROID_HOME" "$log"; then \
        echo ""; \
        echo "✗ 没有检测到 Android SDK，构建无法继续。"; \
        echo ""; \
        echo "  安装步骤："; \
        echo "   1) 安装 Android Studio（自带 SDK 与 JDK），或用 commandline-tools 单独安装"; \
        echo "   2) 在 SDK Manager 里安装 Android 14 (API 34) 平台 + Build-Tools + Platform-Tools"; \
        echo "   3) 设置环境变量并重开终端："; \
        echo '        ANDROID_HOME = %LOCALAPPDATA%\Android\Sdk'; \
        echo '        JAVA_HOME    = <JDK 17+ 目录>'; \
        echo "   4) 接受许可：flutter doctor --android-licenses"; \
        echo "   5) 验证：flutter doctor -v （Android toolchain 一项应为 ✓）"; \
        echo ""; \
        echo "  详见 README「Android 构建」一节。"; \
      elif grep -qE "requires Java|JAVA_HOME|Unsupported class file" "$log"; then \
        echo ""; \
        echo "✗ 没有找到可用的 JDK。"; \
        echo "  安装 JDK 17+（Android Studio 自带的 JBR 也可以），并设置 JAVA_HOME。"; \
        echo "  如果刚设过变量，说明当前终端还没刷新：请新开一个终端再试。"; \
        echo "  PowerShell 临时生效（不重开终端）：\$env:JAVA_HOME='C:\\path\\to\\jdk-21'"; \
      fi; \
      rm -f "$log"; exit 1

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

# 自检 justfile 用到的 Python 辅助脚本（CI 可用）
[group('工具')]
tool-check:
    @{{python}} tool/generate_icons.py --selftest
    @{{python}} tool/android_target.py --selftest
    @{{python}} tool/web_fonts.py --selftest

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
