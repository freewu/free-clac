#!/usr/bin/env bash
# 用无头 Chrome 重新生成 README 与官网（docs/index.html）里的界面截图。
#
# 用法：
#   bash tool/screenshot.sh [端口] [语言...]
#   bash tool/screenshot.sh              # 五种语言全部重跑
#   bash tool/screenshot.sh 8765 zh-Hans en
#
# 产物落在 docs/screenshots/<语言>/，两套：
#   <名字>.png        桌面尺寸（1440 宽），给 README 用；
#                     只有简体全套，其它语言只出 calculator.png 当语言示例
#   <名字>-phone.png  手机尺寸（390×844，2 倍图），官网全部用它
# 同一语言的截图都带 ?lang= 深链，与界面语言一致，官网切语言就换整组图片。
set -euo pipefail

PORT="${1:-8765}"
shift || true
if [[ $# -gt 0 ]]; then
  LANGS=("$@")
else
  LANGS=(zh-Hans zh-Hant en ja es)
fi

# 手机视口：iPhone 15 的 CSS 尺寸，2 倍图（780×1688）在网页上才够清晰
PHONE_SIZE="390,844"
PHONE_SCALE="2"

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
  local lang="$1" name="$2" size="$3" path="$4" scale="${5:-1}"
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
    local dpr=""
    if (( scale > 1 )); then
      dpr="--force-device-scale-factor=$scale"
    fi
    timeout 90 "$CHROME" \
      --headless=new --no-sandbox --hide-scrollbars \
      --no-first-run --no-default-browser-check \
      --user-data-dir="$(win_path "$PROFILE_ROOT/$lang-$name-$attempt")" \
      --window-size="$size" --virtual-time-budget=60000 $dpr \
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

# 桌面截图：README 用。简体全套，其它语言只留 calculator.png 当语言示例
# （官网已经全换成手机截图，别的语言出桌面图没人用）
shoot_pages_desktop() {
  local lang="$1"
  if [[ "$lang" != zh-Hans ]]; then
    shoot "$lang" calculator 1440,900 "index.html"
    return
  fi
  shoot "$lang" calculator       1440,900  "index.html"
  shoot "$lang" calculator-light 1440,900  "index.html?theme=light"
  shoot "$lang" plot             1440,900  "index.html?page=plot"
  shoot "$lang" plot-light       1440,900  "index.html?page=plot&theme=light"
  shoot "$lang" heart            1440,900  "index.html?page=plot&preset=0"
  shoot "$lang" implicit         1440,900  "index.html?page=plot&preset=6"
  shoot "$lang" tools            1440,900  "index.html?page=tools"
  shoot "$lang" settings         1440,2220 "index.html?page=settings"
}

# 手机截图：官网（docs/）全部用这一套
shoot_pages_phone() {
  local lang="$1"
  local size="$PHONE_SIZE" scale="$PHONE_SCALE"
  shoot "$lang" calculator-phone       "$size" "index.html"                    "$scale"
  shoot "$lang" calculator-light-phone "$size" "index.html?theme=light"         "$scale"
  shoot "$lang" plot-phone             "$size" "index.html?page=plot"           "$scale"
  shoot "$lang" plot-light-phone       "$size" "index.html?page=plot&theme=light" "$scale"
  shoot "$lang" heart-phone            "$size" "index.html?page=plot&preset=0"  "$scale"
  shoot "$lang" implicit-phone         "$size" "index.html?page=plot&preset=6"  "$scale"
  shoot "$lang" tools-phone            "$size" "index.html?page=tools"          "$scale"
  shoot "$lang" settings-phone         "$size" "index.html?page=settings"       "$scale"
}

# 工具页的桌面截图：只有 README 要，所以只出简体
shoot_tools_desktop() {
  local lang="$1"
  [[ "$lang" == zh-Hans ]] || return 0
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
  shoot "$lang" pension    1440,1000 "index.html?page=tools&tool=pension"
  shoot "$lang" retirement 1440,700  "index.html?page=tools&tool=retirement"
  shoot "$lang" tax        1440,980  "index.html?page=tools&tool=tax"
}

# 工具页的手机截图：官网工具卡片用，五种语言都要
# 养老金 / 退休年龄 / 个税只在中国内地口径下提供，只在简繁中文界面出现
shoot_tools_phone() {
  local lang="$1" size="$PHONE_SIZE" scale="$PHONE_SCALE"
  local tool
  for tool in bmi bmr compound hourly distance area volume weight \
    temperature energy pressure speed interest; do
    shoot "$lang" "$tool-phone" "$size" "index.html?page=tools&tool=$tool" "$scale"
  done
  shoot "$lang" loan-phone "$size" \
    "index.html?page=tools&tool=loan&method=equalPrincipal" "$scale"
  case "$lang" in
    zh-Hans | zh-Hant)
      for tool in pension retirement tax; do
        shoot "$lang" "$tool-phone" "$size" "index.html?page=tools&tool=$tool" "$scale"
      done
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
  shoot_pages_desktop "$lang" || failed=1
  shoot_tools_desktop "$lang" || failed=1
  shoot_pages_phone "$lang" || failed=1
  shoot_tools_phone "$lang" || failed=1
done

(( failed == 0 )) || { echo "✗ 有截图失败，检查上面的日志"; exit 1; }
echo "✓ 截图已更新：docs/screenshots/<语言>/（<名字>.png 桌面 + <名字>-phone.png 手机）"
