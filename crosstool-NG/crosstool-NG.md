## crosstool-NG

- Install

```sh
pacman -Sy --needed base-devel ncurses git gperftools bison flex texinfo help2man gawk libtool patch wget unzip rsync cpio

git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --prefix=${HOME}/.local
make
make install

# build
mkdir -p ~/rpi0-toolchain
cd ~/rpi0-toolchain
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
```

- New build

```sh
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/fmt.git
cd fmt
# modified PKGBUILD for crosstool-NG
CARCH="armv6h" makepkg -Ad --skipinteg
```