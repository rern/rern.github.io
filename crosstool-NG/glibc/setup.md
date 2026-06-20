```sh
git clone https://github.com/archlinuxarm/PKGBUILDs.git
cp glibc

# modify PKGBUILD for cross-compile

makepkg --config makepkg.conf -Ad --skipinteg

```
