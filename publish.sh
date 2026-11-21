#!/usr/bin/env bash
# nagisafetch 一键发布脚本
# 用法：
#   ./publish.sh github   # 发 GitHub（需先 gh auth login）
#   ./publish.sh aur      # 发 AUR（需先配好 AUR SSH 密钥，且 GitHub release 已存在）
set -euo pipefail

USER="ibukifuuko-arch"
REPO="nagisafetch"
VER="1.0.2"
DIR="$(cd "$(dirname "$0")" && pwd)"
TAR="/workspace/nagisafetch-release.tar.gz"

github() {
  echo "==> 校验 gh 登录"
  gh auth status >/dev/null 2>&1 || { echo "请先运行 gh auth login"; exit 1; }

  echo "==> 初始化本地 git"
  cd "$DIR"
  git init -q
  git config user.name "伊吹风子"
  git config user.email "fuko@mcpcnav.cn"
  git add LICENSE PKGBUILD .SRCINFO README.md nagisafetch
  git commit -q -m "nagisafetch v$VER: initial release" || true

  echo "==> 创建 GitHub 仓库并推送"
  gh repo create "$USER/$REPO" --public --source=. --remote=origin --push 2>/dev/null || \
    git push -u origin HEAD:master

  echo "==> 打 tag 并推 release（源码包自动生成）"
  git tag -a "v$VER" -m "v$VER" 2>/dev/null || true
  git push origin "v$VER" 2>/dev/null || true
  gh release create "v$VER" --title "v$VER" --generate-notes 2>/dev/null || true

  echo "==> 重新算 sha256（PKGBUILD 用）"
  sleep 3
  SUM=$(curl -fsSL "https://github.com/$USER/$REPO/archive/refs/tags/v$VER.tar.gz" | sha256sum | awk '{print $1}')
  echo "sha256sum: $SUM"
  echo "把 PKGBUILD 里的 sha256sums=('SKIP') 改成 sha256sums=('$SUM')"
  echo "然后改 .SRCINFO 里对应的 sha256sums = $SUM"
}

aur() {
  echo "==> 依赖检查"
  command -v makepkg >/dev/null || { echo "缺 makepkg: pacman -S base-devel"; exit 1; }
  ssh -T aur@aur.archlinux.org 2>&1 | grep -qi "interactive shell" || \
    { echo "AUR SSH 没配好，先把公钥传到 https://aur.archlinux.org/account/"; exit 1; }

  echo "==> clone AUR 仓库"
  WORK=/tmp/aur-nagisafetch
  rm -rf "$WORK"
  git clone ssh://aur@aur.archlinux.org/$REPO.git "$WORK" 2>/dev/null || \
    git init -q "$WORK"
  cp "$DIR/PKGBUILD" "$DIR/.SRCINFO" "$DIR/LICENSE" "$DIR/README.md" "$WORK/"

  echo "==> 生成 .SRCINFO 并提交"
  cd "$WORK"
  makepkg --printsrcinfo > .SRCINFO
  git add PKGBUILD .SRCINFO LICENSE README.md
  git config user.name "伊吹风子"
  git config user.email "fuko@mcpcnav.cn"
  git commit -q -m "nagisafetch v$VER: initial release"
  git push origin master

  echo "==> AUR 发布完成: https://aur.archlinux.org/packages/$REPO"
}

case "${1:-}" in
  github) github ;;
  aur)    aur ;;
  *) echo "用法: $0 {github|aur}"; exit 1 ;;
esac
