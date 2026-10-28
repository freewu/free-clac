#!/usr/bin/env bash
# 用无头 Chrome 重新生成 README 中的界面截图。
# 用法：bash tool/screenshot.sh [端口]
set -euo pipefail

PORT="${1:-8765}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/docs/screenshots"
URL="http://localhost:$PORT"

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

# Chrome 可执行文件
if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
  CHROME="C:/Program Files/Google/Chrome/Application/chrome.exe"
elif [[ -x "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" ]]; then
  CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
else
  CHROME="$(command -v google-chrome || command -v chromium || echo "")"
fi
[[ -n "$CHROME" ]] || { echo "未找到 Chrome，可手动截图到 docs/screenshots/"; exit 1; }

# Windows 版 Chrome 需要 Windows 风格的文件路径
win_path() {
  if is_wsl; then
    wslpath -w "$1"
  elif [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
    cygpath -w "$1"
  else
    echo "$1"
  fi
}

[[ -d "$ROOT/build/web" ]] || { echo "缺少 build/web，请先执行 just build-web"; exit 1; }
mkdir -p "$OUT"

TMP_PROFILE="$(mktemp -d)"
# Windows 版 Chrome 无法使用 WSL 临时路径，需要换算
PROFILE_DIR="$(win_path "$TMP_PROFILE")"
SERVER_PID=""
cleanup() {
  [[ -n "$SERVER_PID" ]] && kill "$SERVER_PID" 2>/dev/null || true
  rm -rf "$TMP_PROFILE"
}
trap cleanup EXIT

# 复用已有服务器，否则临时起一个（仅本机）
if ! curl -fsS "$URL/index.html" >/dev/null 2>&1; then
  if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$PORT" --directory "$ROOT/build/web" >/dev/null 2>&1 &
  else
    python -m http.server "$PORT" --directory "$ROOT/build/web" >/dev/null 2>&1 &
  fi
  SERVER_PID=$!
  for _ in $(seq 1 40); do
    curl -fsS "$URL/index.html" >/dev/null 2>&1 && break
    sleep 0.5
  done
  curl -fsS "$URL/index.html" >/dev/null 2>&1 || { echo "静态服务器启动失败"; exit 1; }
  echo "静态服务器：$URL (pid $SERVER_PID)"
fi

shoot() {
  local name="$1" size="$2" path="$3"
  echo "› $name.png ($size)"
  timeout 90 "$CHROME" \
    --headless=new --no-sandbox --hide-scrollbars \
    --no-first-run --no-default-browser-check \
    --user-data-dir="$PROFILE_DIR/$name" \
    --window-size="$size" --virtual-time-budget=60000 \
    --screenshot="$(win_path "$OUT/$name.png")" \
    "$URL/$path" >/dev/null 2>&1 || true
  local bytes
  bytes=$(stat -c %s "$OUT/$name.png" 2>/dev/null || echo 0)
  if (( bytes < 20000 )); then
    echo "  ✗ 截图异常（${bytes} 字节），请重试"
    return 1
  fi
  echo "  ✓ ${bytes} 字节"
}

shoot calculator 1440,900 "index.html"
shoot plot       1440,900 "index.html?page=plot"
shoot heart      1440,900 "index.html?page=plot&preset=0"
shoot implicit   1440,900 "index.html?page=plot&preset=6"
shoot tools      1440,900 "index.html?page=tools"
shoot bmi        1440,900 "index.html?page=tools&tool=bmi"
shoot compound   1440,900 "index.html?page=tools&tool=compound"
shoot distance   1440,900 "index.html?page=tools&tool=distance"
shoot area       1440,900 "index.html?page=tools&tool=area"
shoot weight     1440,900 "index.html?page=tools&tool=weight"
shoot volume     1440,900 "index.html?page=tools&tool=volume"
shoot temperature 1440,900 "index.html?page=tools&tool=temperature"
shoot speed      1440,900 "index.html?page=tools&tool=speed"
shoot interest   1440,900 "index.html?page=tools&tool=interest"
shoot loan       1440,900 "index.html?page=tools&tool=loan&method=equalPrincipal"
shoot pension    1440,1000 "index.html?page=tools&tool=pension"
shoot tax        1440,980 "index.html?page=tools&tool=tax"
shoot settings   1440,1000 "index.html?page=settings"
shoot mobile     414,896  "index.html"
ls -la "$OUT"
