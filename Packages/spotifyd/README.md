### A spotify daemon
Source: [Spotifyd](https://github.com/Spotifyd/spotifyd)
```sh
pacman -Syu
pacman -S --needed base-devel cargo

# needs rust 1.47 (otherwise runtime error: librespot_tremor::tremor_sys::ov_callbacks)
wget http://tardis.tiny-vps.com/aarm/packages/r/rust/rust-1%3A1.47.0-4-aarch64.pkg.tar.xz
pacman -U rust*

# setup distcc
systemctl start distccd

su alarm

cd
mkdir spotifyd
cd spotifyd
cat << 'EOF' > PKGBUILD
# Maintainer: Frederik Schwan <freswa at archlinux dot org>
# Contributor: Bert Peters <bert@bertptrs.nl>
# Contributor: Varakh <varakh@varakh.de>
# Contributor: Florian Klink <flokli@flokli.de>

pkgbase=spotifyd
pkgname=('spotifyd')
pkgver=0.3.0
pkgrel=1
pkgdesc='Leightweigt spotify streaming daemon with spotify connect support'
arch=('x86_64')
url='https://github.com/Spotifyd/spotifyd'
license=('GPL3')
depends=('alsa-lib' 'libogg' 'libpulse' 'dbus')
# change to rust when https://github.com/librespot-org/librespot-tremor/pull/1 got merged
makedepends=('rustup')
source=("https://github.com/Spotifyd/spotifyd/archive/v${pkgver}/${pkgname}-${pkgver}.tar.gz")
b2sums=('79bc74d6dc2e9acca439a9b5e5e1c6f6be143ea6fd376386f1649626f51473d56c0147057eba5dcdb5b97496733bafcdb9956f8a2bc824c61c13b61740359398')

build() {
  cd spotifyd-${pkgver}
  cargo build --release --locked
}

 check() {
  cd spotifyd-${pkgver}
  cargo test --release --locked --target-dir=target
 }

package() {
  cd spotifyd-${pkgver}
  cargo install --locked --root "${pkgdir}"/usr --path "${srcdir}"/${pkgbase}-${pkgver}
  rm "${pkgdir}"/usr/{.crates.toml,.crates2.json}
  install -Dm644 -t "${pkgdir}"/usr/lib/systemd/user/ "${srcdir}"/${pkgbase}-${pkgver}/contrib/spotifyd.service
}
EOF

makepkg -A
```