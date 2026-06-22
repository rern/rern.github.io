```sh
# toolchain build order: linux-api-headers->glibc->binutils->gcc
sed -i -E 's/^#*(MAKEFLAGS=).*/\1"-j4"/; s|^#*(BUILDDIR=).*|\1home/x/tmp|' /etc/makepkg.conf

cd
git clone https://github.com/archlinuxarm/PKGBUILDs.git
cp -r PKGBUILDs/core/binutils .
cd binutils

# modify PKGBUILD for cross-compile

CARCH="armv6h" makepkg -Ad --skipinteg

# reset makepkg.conf
sed -i -E 's/^(MAKEFLAGS=).*/\1"-j12"/; s/^(BUILDDIR)/#\1/' /etc/makepkg.conf
cd
rsudo rm -rf tmp
```
