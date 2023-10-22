### `python-upnpp`
- `Makefile`: `make` > `make install` to `/usr/lib/python3.11/site-packages/upnpp`
```sh
if [[ -e /boot/kernel.img ]]; then
	# setup swap partition
	wget http://mirror.archlinuxarm.org/aarch64/extra/python-devtools-0.12.2-1-any.pkg.tar.xz
	pacman -U python-devtools
	pacman -Sy --needed automake libnpupnp python-setuptools swig
else
	pacman -Sy --needed automake libnpupnp python-devtools python-setuptools swig
fi

su alarm
cd
git clone https://framagit.org/medoc92/libupnpp-bindings.git libupnpp-bindings
cd libupnpp-bindings
./autogen.sh
./configure --prefix=/usr
make
```

- `PKGBUILD`: `makepkg -R` create `python-upnpp` package (`-R` run function `package` only)
```sh
cd
mkdir=libupnpp-bindings/python
srcdir=python-upnpp/src/upnpp
mkdir -p $srcdir
cp $mkdir/_upnpp.la $srcdir
cp $mkdir/.libs/_upnpp.so $srcdir
cp $mkdir/upnpp/__init__.py $srcdir
cp $mkdir/upnpp/upnpp.py $srcdir

cd python-upnpp
wget https://github.com/rern/rern.github.io/raw/main/PKGBUILD/python-upnpp/PKGBUILD
makepkg -R
```
