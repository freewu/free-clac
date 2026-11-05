#!/bin/sh
# 用「装了 Pillow 的 Python」执行图标脚本。
#
# Windows 侧默认的 python 常常没装 Pillow，`just icons` 会直接 ModuleNotFoundError；
# 而 WSL 里的 python3 一般都有。所以这里按顺序挑解释器：
#
#   $PYTHON_ICONS → python3 → py -3 → python → WSL 里的 python3
#
# 全都不行才退出，并提示怎么装依赖。

set -eu

usage() {
    echo "用法：tool/with_pillow.sh <python 脚本> [参数...]" >&2
    echo "      tool/with_pillow.sh --selftest" >&2
    exit 2
}

# 解释器命令（可能是 "py -3" 这种带参数的）能 import PIL 就执行并接管进程
run_with() {
    interpreter=$1
    shift
    # shellcheck disable=SC2086
    $interpreter -c "import PIL" >/dev/null 2>&1 || return 1
    echo "· 使用 $interpreter 执行图标脚本" >&2
    # shellcheck disable=SC2086
    exec $interpreter "$@"
}

# 把 Git Bash 的 /e/xxx 换成 WSL 认得的 /mnt/e/xxx
wsl_path() {
    cygpath -u "$1" | sed -e 's|^/\([a-zA-Z]\)/|/mnt/\1/|'
}

hint() {
    cat >&2 <<'EOF'
✗ 没找到装了 Pillow 的 Python，图标脚本跑不起来。
  Windows：python -m pip install pillow
  WSL：    sudo apt install python3-pil
  也可以指定解释器：PYTHON_ICONS=python3.12 just icons
EOF
    exit 1
}

selftest() {
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    # 假解释器：第一行决定有没有 Pillow，失败返回 1，成功回显自己的名字
    fake() {
        printf '#!/bin/sh\n%s\necho "%s:$*"\n' "$2" "$1" >"$tmp/$1"
        chmod +x "$tmp/$1"
    }
    fake python3 "exit 1"
    fake py 'echo "py:$*" >/dev/null'
    fake python 'echo "python:$*" >/dev/null'

    # python3 没有 Pillow，应自动落到 "py -3"
    out=$(PATH="$tmp:$PATH" sh "$0" demo.py --flag 2>/dev/null)
    assert_eq() {
        [ "$1" = "$2" ] || {
            echo "✗ $3：期望 $2，实际 $1" >&2
            exit 1
        }
    }
    assert_eq "$out" "py:-3 demo.py --flag" "跳过没有 Pillow 的 python3"

    # 三个都有 Pillow 时优先用 python3
    fake python3 'echo "python3:$*" >/dev/null'
    out=$(PATH="$tmp:$PATH" sh "$0" demo.py 2>/dev/null)
    assert_eq "$out" "python3:demo.py" "优先 python3"

    # 全都没有 Pillow：给出安装提示并以非 0 退出
    fake python3 "exit 1"
    fake py "exit 1"
    fake python "exit 1"
    if PATH="$tmp:$PATH" sh "$0" demo.py >/dev/null 2>"$tmp/err"; then
        echo "✗ 全都缺 Pillow 时不该成功退出" >&2
        exit 1
    fi
    grep -q Pillow "$tmp/err" || {
        echo "✗ 缺 Pillow 时没有给出安装提示" >&2
        exit 1
    }

    echo "✓ with_pillow 自检通过"
}

if [ "${1:-}" = "--selftest" ]; then
    selftest
    exit 0
fi

[ "$#" -ge 1 ] || usage
target=$1
shift

for candidate in "${PYTHON_ICONS:-}" python3 "py -3" python; do
    [ -n "$candidate" ] || continue
    run_with $candidate "$target" "$@" || :
done

# Windows 上没有可用的 Pillow 时，退回 WSL 里的 python3
if command -v wsl.exe >/dev/null 2>&1 && command -v cygpath >/dev/null 2>&1; then
    wsl_target=$(wsl_path "$target")
    if MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
        wsl.exe -e python3 -c "import PIL" >/dev/null 2>&1; then
        echo "· 本机 Python 都没有 Pillow，改用 WSL 的 python3 执行图标脚本" >&2
        MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' \
            wsl.exe -e python3 "$wsl_target" "$@"
        exit $?
    fi
fi

hint
