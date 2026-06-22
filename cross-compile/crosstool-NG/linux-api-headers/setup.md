```sh
# toolchain build order: linux-api-headers->glibc->binutils->gcc
cd
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/linux-api-headers.git
cd linux-api-headers

# modify PKGBUILD for cross-compile

CARCH="armv6h" makepkg -Ad --skipinteg
```
