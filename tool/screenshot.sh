#!/usr/bin/env bash
# 用无头 Chrome 重新生成 README 与官网（docs/index.html）里的界面截图。
#
# 用法：
#   bash tool/screenshot.sh [端口] [语言...]
#   bash tool/screenshot.sh              # 五种语言全部重跑
#   bash tool/screenshot.sh 8765 zh-Hans en
#
# 产物落在 docs/screenshots/<语言>/<名字>.png，同一个语言的官网截图
# 与界面语言一致（?lang= 深链），方便官网按语言切换整组图片。
set -euo pipefail

PORT="${1:-8765}"
shift || true
if [[ $# -gt 0 ]]; then
  LANGS=("$@")
else
  LANGS=(zh-Hans zh-Hant en ja es)
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/docs/screenshots"
URL="http://127.0.0.1:$PORT"

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

is_msys() {
  [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]
}

# Chrome 可执行文件
if is_msys; then
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
  elif is_msys; then
    cygpath -w "$1"
  else
    echo "$1"
  fi
}

# Chrome 的 --user-data-dir 不能放在 \\wsl.localhost 这类网络路径上，
# WSL 里改用 Windows 的临时目录（其余情况用本机 /tmp 即可）。
if is_wsl; then
  WIN_TEMP="$(cmd.exe /c "echo %TEMP%" | tr -d '\r\n')"
  PROFILE_ROOT="$(wslpath -u "$WIN_TEMP")/free-clac-shots-$$"
else
  PROFILE_ROOT="$(mktemp -d)"
fi
mkdir -p "$PROFILE_ROOT"

[[ -d "$ROOT/build/web" ]] || { echo "缺少 build/web，请先执行 just build-web"; exit 1; }

SERVER_PID=""
SERVER_WIN=""
SERVER_OURS=""

stop_server() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    SERVER_PID=""
  fi
  if [[ -n "$SERVER_WIN" ]]; then
    # WSL 里服务器是 Windows 侧的 python，按端口找出 PID 再 taskkill
    local pid
    pid="$({ cmd.exe /c netstat -ano 2>/dev/null | tr -d '\r' |
      awk -v port=":$PORT" '$1 == "TCP" && $2 ~ port"$" && $4 == "LISTENING" {print $5; exit}'; } || true)"
    if [[ -n "$pid" ]]; then
      timeout 10 /mnt/c/Windows/System32/taskkill.exe /F /PID "$pid" \
        >/dev/null 2>&1 || true
    fi
    SERVER_WIN=""
  fi
}

cleanup() {
  stop_server
  rm -rf "$PROFILE_ROOT"
}
trap cleanup EXIT

# 探测静态服务器是否已经在跑：WSL 里跑的是 Windows 侧进程，得用 Windows 的 curl
server_ready() {
  if is_wsl; then
    cmd.exe /c "curl -fsS -m 5 -o NUL http://127.0.0.1:$PORT/index.html" \
      >/dev/null 2>&1
  else
    curl -fsS -m 5 "$URL/index.html" >/dev/null 2>&1
  fi
}

wait_server() {
  for _ in $(seq 1 40); do
    server_ready && return 0
    sleep 0.5
  done
  return 1
}

start_server() {
  if is_wsl; then
    # WSL（NAT 模式）里的服务器 Windows 侧连不上：把静态服务器起在 Windows 上，
    # 这样无头 Chrome 访问的是它自己的 127.0.0.1。
    # 只绑 IPv4，双栈监听在跑了很多次截图后容易卡住。
    # 必须 setsid + disown：直接 `(cmd.exe &)` 的话退出时 bash 会一直等这个子进程。
    WIN_BUILD="$(wslpath -w "$ROOT/build/web")"
    setsid nohup cmd.exe /c \
      "cd /d $WIN_BUILD && python -m http.server $PORT --bind 127.0.0.1" \
      >/dev/null 2>&1 </dev/null &
    disown || true
    SERVER_WIN="1"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "$PORT" --directory "$ROOT/build/web" \
      --bind 127.0.0.1 >/dev/null 2>&1 &
    SERVER_PID=$!
  else
    python -m http.server "$PORT" --directory "$ROOT/build/web" \
      --bind 127.0.0.1 >/dev/null 2>&1 &
    SERVER_PID=$!
  fi
  wait_server || { echo "静态服务器启动失败（端口 $PORT）"; exit 1; }
  SERVER_OURS="1"
}

if server_ready; then
  echo "复用已在运行的服务器：$URL"
else
  start_server
  echo "静态服务器：$URL"
fi


shoot() {
  local lang="$1" name="$2" size="$3" path="$4"
  local url="$URL/$path"
  case "$path" in
    *\?*) url="$url&lang=$lang" ;;
    *) url="$url?lang=$lang" ;;
  esac
  local dir="$OUT/$lang"
  local file="$dir/$name.png"
  mkdir -p "$dir"
  echo "› $lang/$name.png ($size)"
  local attempt bytes
  for attempt in 1 2; do
    timeout 90 "$CHROME" \
      --headless=new --no-sandbox --hide-scrollbars \
      --no-first-run --no-default-browser-check \
      --user-data-dir="$(win_path "$PROFILE_ROOT/$lang-$name-$attempt")" \
      --window-size="$size" --virtual-time-budget=60000 \
      --screenshot="$(win_path "$file")" \
      "$url" >/dev/null 2>&1 || true
    bytes="$(stat -c %s "$file" 2>/dev/null || echo 0)"
    (( bytes >= 15000 )) && break
    # 跑多了以后静态服务器偶尔会卡住（端口还在，但不再响应）：重启后再试一次
    echo "  … 截图异常（${bytes} 字节），重启静态服务器后重试"
    stop_server
    start_server
  done
  if (( bytes < 15000 )); then
    echo "  ✗ 截图失败（${bytes} 字节）"
    return 1
  fi
  echo "  ✓ ${bytes} 字节"
}

# 主要的几页：深浅两套配色各留一张，官网「主题」一节并排展示
shoot_pages() {
  local lang="$1"
  shoot "$lang" calculator       1440,900  "index.html"
  shoot "$lang" calculator-light 1440,900  "index.html?theme=light"
  shoot "$lang" plot             1440,900  "index.html?page=plot"
  shoot "$lang" plot-light       1440,900  "index.html?page=plot&theme=light"
  shoot "$lang" heart            1440,900  "index.html?page=plot&preset=0"
  shoot "$lang" implicit         1440,900  "index.html?page=plot&preset=6"
  shoot "$lang" tools            1440,900  "index.html?page=tools"
  shoot "$lang" settings         1440,2220 "index.html?page=settings"
  shoot "$lang" mobile           414,896   "index.html"
}

# 工具页截图；养老金 / 退休年龄 / 个税只在简繁中文界面出现，其余语言没有这三项
shoot_tools() {
  local lang="$1"
  shoot "$lang" bmi         1440,900 "index.html?page=tools&tool=bmi"
  shoot "$lang" bmr         1440,900 "index.html?page=tools&tool=bmr"
  shoot "$lang" compound    1440,900 "index.html?page=tools&tool=compound"
  shoot "$lang" hourly      1440,900 "index.html?page=tools&tool=hourly"
  shoot "$lang" distance    1440,900 "index.html?page=tools&tool=distance"
  shoot "$lang" area        1440,900 "index.html?page=tools&tool=area"
  shoot "$lang" volume      1440,900 "index.html?page=tools&tool=volume"
  shoot "$lang" weight      1440,900 "index.html?page=tools&tool=weight"
  shoot "$lang" temperature 1440,900 "index.html?page=tools&tool=temperature"
  shoot "$lang" energy      1440,900 "index.html?page=tools&tool=energy"
  shoot "$lang" pressure    1440,900 "index.html?page=tools&tool=pressure"
  shoot "$lang" speed       1440,900 "index.html?page=tools&tool=speed"
  shoot "$lang" interest    1440,900 "index.html?page=tools&tool=interest"
  shoot "$lang" loan        1440,900 "index.html?page=tools&tool=loan&method=equalPrincipal"
  case "$lang" in
    zh-Hans | zh-Hant)
      shoot "$lang" pension    1440,1000 "index.html?page=tools&tool=pension"
      shoot "$lang" retirement 1440,700  "index.html?page=tools&tool=retirement"
      shoot "$lang" tax        1440,980  "index.html?page=tools&tool=tax"
      ;;
  esac
}

failed=0
for lang in "${LANGS[@]}"; do
  echo "── $lang"
  # 每种语言重新起一次服务器：连续跑上百次截图后 python 的 http.server 偶尔会卡住
  if [[ -n "$SERVER_OURS" ]]; then
    stop_server
    start_server
  fi
  shoot_pages "$lang" || failed=1
  shoot_tools "$lang" || failed=1
done

(( failed == 0 )) || { echo "✗ 有截图失败，检查上面的日志"; exit 1; }
echo "✓ 截图已更新：docs/screenshots/<语言>/"
