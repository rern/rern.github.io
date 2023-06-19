crosstool-NG
---
**`armv7h` `aarch64`**
- [distccd-alarm](https://aur.archlinux.org/pkgbase/distccd-alarm)
```sh
su $USER
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/distccd-alarm.tar.gz | bsdtar xf -
cd distccd-alarm
makepkg
```

**`armv6h`**
- [distccd-alarm-armv6h-10.2.0](https://github.com/rern/rern.github.io/tree/main/crosstool-NG/distccd-alarm-armv6h)
- Latest version
```sh
# build crosstool-ng binary on armv6h
pacman -Sy --needed bison byacc flex help2man patch unzip
su $USER
cd
# VERSION: http://crosstool-ng.org/download/crosstool-ng
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$VERSION.tar.xz | bsdtar xf -
cd crosstool-ng-$VERSION
./configure --prefix=/usr
make
sudo make install

# configure
mkdir build
cd build
# load custom config and set all packages to latest versions if any (glibc 2.35 might failed)
wget https://archlinuxarm.org/builder/xtools/10.2.0/xtools-dotconfig-v6 -O .config
ct-ng oldconfig

# build toolchain
ct-ng build

# set symlinks
dir=x-tools6h/arm-unknown-linux-gnueabihf/bin
chmod +w $dir
dircurrent=$PWD
cd $dir
files=( $( ls ) )
for file in ${files[@]}; do
    ln -s $file{,#arm-unknown-linux-gnueabihf-}
done
cd $dircurrent
chmod -w $dir
```

**Tarball for AUR package**
```sh
bsdtar cjpf x-tools6h-$DATE.tar.xz x-tools6h
```
