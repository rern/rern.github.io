```sh
mkdir -p rpi0-glibc rpi0-gcc

git clone https://github.com/archlinuxarm/PKGBUILDs.git
cp PKGBUILDs/core/glibc/* rpi0-glibc
cp PKGBUILDs/core/gcc/* rpi0-gcc

cd ~/rpi0-glibc
for f in makepkg.conf PKGBUILD; do
    wget https://github.com/rern/rern.github.io/raw/refs/heads/main/Crosstool-NG/glibc/$f
done
cp makepkg.conf ~/rpi0-gcc

ct-ng armv6-unknown-linux-gnueabihf

CC="armv6-rpi-linux-gnueabihf-gcc" \
CXX="armv6-rpi-linux-gnueabihf-g++" \
AR="armv6-rpi-linux-gnueabihf-ar" \
RANLIB="armv6-rpi-linux-gnueabihf-ranlib" \
makepkg --config makepkg.conf -Acs --skipinteg

cd ~/rpi0-gcc
wget https://github.com/rern/rern.github.io/raw/refs/heads/main/Crosstool-NG/glibc/PKGBUILD

ct-ng armv6-unknown-linux-gnueabihf

CC="armv6-rpi-linux-gnueabihf-gcc" \
CXX="armv6-rpi-linux-gnueabihf-g++" \
AR="armv6-rpi-linux-gnueabihf-ar" \
RANLIB="armv6-rpi-linux-gnueabihf-ranlib" \
makepkg --config makepkg.conf -Acs --skipinteg

# once error - download_prerequisites
cd src/gcc
./contrib/download_prerequisites
cd ../..

```