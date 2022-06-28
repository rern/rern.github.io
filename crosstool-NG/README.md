crosstool-NG
---

For armv6h Distcc

**Build**
```sh
# build crosstool-ng binary on armv6h
su $USER
cd
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$VERSION.tar.xz | bsdtar xf -
cd crosstool-ng-$VERSION
./configure --prefix=/usr
make
make install

# configure
mkdir build
cd build
# load custom config and set all packages to latest versions if any (glibc 2.35 might failed)
wget https://github.com/rern/rern.github.io/raw/main/crosstool-NG/xtools-dotconfig-v6 -O .config
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
