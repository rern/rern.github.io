## Crosstool-NG

```sh
pacman -Sy --needed base-devel ncurses git gperftools bison flex texinfo help2man gawk libtool patch wget unzip rsync cpio

git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
./bootstrap
./configure --prefix=${HOME}/.local
make
make install

export PATH="${HOME}/.local/bin:$PATH"

mkdir -p ~/rpi-zero-toolchain
cd ~/rpi-zero-toolchain
ct-ng armv6-unknown-linux-gnueabihf

ct-ng menuconfig
# Paths and misc options
#   Try features marked as EXPERIMENTAL: [*] Enable
#   Extra host compiler flags: -fno-char8_t

# Target options
#   Emit assembly for CPU: arm1176jzf-s
#   Use specific FPU: vfp
#   Floating point: hardware (FPU)

# Toolchain options
#   Tuple's vendor string: rpi

# Operating System
#   Verrsion of linux: 6.0.12

# C compiler
#   Version of gcc: Look for 15.2.0
#   C++: [*] Enable

ct-ng build.$(nproc) # .n threads

echo 'export PATH="${HOME}/x-tools/armv6-rpi-linux-gnueabihf/bin:${PATH}"' >> ~/.bashrc

# test run
export PATH="${HOME}/x-tools/armv6-rpi-linux-gnueabihf/bin:${PATH}"

armv6-rpi-linux-gnueabihf-gcc -v
#Using built-in specs.
#...
#gcc version 15.2.0 (crosstool-NG 1.28.0)

cat << EOF > test.c # test c code
#include <stdio.h>
int main() {
    printf("Hello Raspberry Pi Zero!\\n");
    return 0;
}
EOF

armv6-rpi-linux-gnueabihf-gcc test.c -o test_rpi # compile
file test_rpi # verify
# test_rpi: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV) ...


```