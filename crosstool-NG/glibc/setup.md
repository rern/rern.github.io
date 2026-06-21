```sh
git clone https://github.com/archlinuxarm/PKGBUILDs.git
cp -r core/glibc ~/
cd ~/glibc

# modify PKGBUILD for cross-compile

CARCH="armv6h" makepkg -Ad --skipinteg
```
