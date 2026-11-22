#!/usr/bin/env bash
# nagisafetch 一键安装脚本（CNB 源，国内直连，不依赖 GitHub）
# 用法: curl -fsSL https://cnb.cool/ibukifuuko/nagisafetch/-/git/raw/master/install-cn.sh | bash
set -euo pipefail

REPO="ibukifuuko/nagisafetch"
BRANCH="master"
BASE="https://cnb.cool/${REPO}/-/git/raw/${BRANCH}"

# 选下载工具
if command -v curl >/dev/null 2>&1; then
    fetch() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
    fetch() { wget -qO "$2" "$1"; }
else
    echo "错误：需要 curl 或 wget" >&2
    exit 1
fi

# 判断安装位置：Termux 装到 $PREFIX/bin，普通 Linux 装到 ~/.local/bin
# 同时校验 TERMUX_VERSION 和 $PREFIX 路径，避免普通 Linux 上的同名残留目录误判
if [ -n "${TERMUX_VERSION:-}" ] && [ "${PREFIX:-}" = "/data/data/com.termux/files/usr" ]; then
    DEST="${PREFIX}/bin"
    PLATFORM="Termux"
else
    DEST="${XDG_BIN_HOME:-${HOME}/.local/bin}"
    PLATFORM="Linux"
fi

mkdir -p "$DEST"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "==> 从 CNB 下载 nagisafetch (${PLATFORM})"
fetch "${BASE}/nagisafetch" "$TMP"
install -m 755 "$TMP" "${DEST}/nagisafetch"

echo "==> 验证安装"
"${DEST}/nagisafetch" --version

echo "==> 完成：${DEST}/nagisafetch"
case ":${PATH}:" in
    *":${DEST}:"*) ;;
    *) echo "提示：${DEST} 不在 PATH 中，在 shell 配置里加：export PATH=\"${DEST}:\$PATH\"" ;;
esac
