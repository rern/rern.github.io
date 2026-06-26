```sh
# toolchain build order: linux-api-headers->glibc->binutils->gcc

cd
git clone https://github.com/archlinuxarm/PKGBUILDs.git
cp -r PKGBUILDs/core/gcc .
cd gcc

# modify PKGBUILD for cross-compile

CARCH="armv6h" makepkg -Ad --skipinteg
```
