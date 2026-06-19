```sh
# build glibc first
cd ~/rpi0-gcc
curl -LO https://github.com/rern/rern.github.io/raw/refs/heads/main/Crosstool-NG/glibc/PKGBUILD

ct-ng armv6-unknown-linux-gnueabihf

makepkg -A -d --nodeps --skipinteg

```
