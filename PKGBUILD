# Maintainer: 伊吹风子 <fuko@mcpcnav.cn>
pkgname=nagisafetch
pkgver=1.0.3
pkgrel=1
pkgdesc="Zero-dependency, themeable system information tool written in Python"
arch=('any')
url="https://github.com/ibukifuuko-arch/nagisafetch"
license=('MIT')
depends=('python')
source=("$pkgname-$pkgver.tar.gz::https://github.com/ibukifuuko-arch/nagisafetch/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('58c02073d64bf1abb8e43efaa8d8bf8a8d65d5cc1e58f28b3a222b07c5880508')

package() {
    cd "$srcdir/nagisafetch-$pkgver"
    install -Dm755 nagisafetch "$pkgdir/usr/bin/nagisafetch"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
}
