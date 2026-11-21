# Maintainer: 伊吹风子 <fuko@mcpcnav.cn>
pkgname=nagisafetch
pkgver=1.0.2
pkgrel=1
pkgdesc="Zero-dependency, themeable system information tool written in Python"
arch=('any')
url="https://github.com/ibukifuuko-arch/nagisafetch"
license=('MIT')
depends=('python')
source=("$pkgname-$pkgver.tar.gz::https://github.com/ibukifuuko-arch/nagisafetch/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
    cd "$srcdir/nagisafetch-$pkgver"
    install -Dm755 nagisafetch "$pkgdir/usr/bin/nagisafetch"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
}
