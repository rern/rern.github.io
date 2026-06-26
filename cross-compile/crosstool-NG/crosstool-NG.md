## crosstool-NG

- Install

```sh
pacman -Sy --needed base-devel bison cpio flex git gperftools help2man libtool ncurses patch rsync texinfo unzip

cd
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --prefix=${HOME}/.local
make
make install

# build
cd
mkdir -p toolchain
cd toolchain
ct-ng armv6-unknown-linux-gnueabihf # for armv6: ct-ng list-samples | grep armv6
ct-ng menuconfig
# Paths and misc options
#   Try features marked as EXPERIMENTAL: [*] Enable
#   Extra host compiler flags: -fno-char8_t
# Esc-Esc to save and exit

ct-ng build.$(nproc) # ct-ng build.12 - lower if frozen

echo 'export PATH=$PATH:/home/x/x-tools/armv6-rpi-linux-gnueabihf/bin' >> ~/.bashrc
# open new terminal to load new $PATH

# test run
armv6-rpi-linux-gnueabihf-gcc -v
# Using built-in specs.
# ...
# gcc version 15.2.0 (crosstool-NG 1.28.0)

cat << EOF > test.c # test c code
#include <stdio.h>
int main() {
    printf("Hello Raspberry Pi Zero!\\n");
    return 0;
}
EOF

armv6-rpi-linux-gnueabihf-gcc test.c -o test # compile

file test # verify
# test_rpi: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV) ...

scp test root@192.168.1.90:/root
# run test on rpi0

cd
rm -rf crosstool-ng toolchain

# install compiled package
sudo pacman --sysroot /home/x/x-sysroot -U PACKAGE-armv6h.pkg.tar.zst
```