```sh
# build glibc first
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/gcc.git
cd gcc

ct-ng menuconfig
# Paths and misc options
#   Try features marked as EXPERIMENTAL: [*] Enable
# Toolchain options
#   Toolchain type: Canadian

# modify PKGBUILD for cross-compile

CARCH="armv6h" makepkg -Ad --skipinteg
```
