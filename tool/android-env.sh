#!/bin/sh
# Android 构建前补齐 JAVA_HOME / ANDROID_HOME。
#
# 背景：用 setx / 系统属性写入的用户变量，对「已经打开的终端」不生效；
# 从 WSL 调用 Windows 侧 flutter 时，这些变量也不会自动跨界。
# 这里做一次探测：探测不到就保持原样，由 justfile 打印中文安装提示。

on_windows() {
  case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

has_java() {
  [ -n "${1:-}" ] || return 1
  [ -x "$1/bin/java" ] || [ -f "$1/bin/java.exe" ]
}

# 构建工具链里的 Gradle 是 Windows 程序，必须拿 Windows 风格路径
to_windows_path() {
  if on_windows; then
    printf '%s' "$1"
  elif command -v wslpath >/dev/null 2>&1; then
    wslpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

# 按「本项目文档推荐的安装位置」依次查找 JDK
detect_jdk() {
  if on_windows; then
    for dir in \
      "$USERPROFILE"/jdks/* \
      "$LOCALAPPDATA"/Programs/Eclipse\ Adoptium/* \
      "$PROGRAMFILES"/Android/Android\ Studio/jbr \
      "$PROGRAMFILES"/Java/*; do
      has_java "$dir" && { to_windows_path "$dir"; return 0; }
    done
  else
    for dir in \
      /mnt/c/Users/*/jdks/* \
      "/mnt/c/Program Files/Android/Android Studio/jbr"; do
      has_java "$dir" && { to_windows_path "$dir"; return 0; }
    done
  fi
  return 1
}

if ! has_java "${JAVA_HOME:-}"; then
  detected="$(detect_jdk)" || detected=""
  [ -n "$detected" ] && JAVA_HOME="$detected"
fi
[ -n "${JAVA_HOME:-}" ] && export JAVA_HOME

if [ -z "${ANDROID_HOME:-}" ]; then
  if on_windows && [ -d "$LOCALAPPDATA/Android/Sdk" ]; then
    ANDROID_HOME="$LOCALAPPDATA/Android/Sdk"
  else
    for sdk in /mnt/c/Users/*/AppData/Local/Android/Sdk; do
      [ -d "$sdk" ] && { ANDROID_HOME="$(to_windows_path "$sdk")"; break; }
    done
  fi
fi
[ -n "${ANDROID_HOME:-}" ] && export ANDROID_HOME
[ -n "${ANDROID_HOME:-}" ] && export ANDROID_SDK_ROOT="$ANDROID_HOME"

# WSL 里仅 export 不会传给 cmd.exe，要用 WSLENV 声明共享哪些变量
if ! on_windows && [ -n "${WSL_DISTRO_NAME:-}" ]; then
  WSLENV="JAVA_HOME:ANDROID_HOME:ANDROID_SDK_ROOT:${WSLENV:-}"
  export WSLENV
fi
