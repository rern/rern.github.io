### `python-upnpp`
- `Makefile`: `make` > `make install` to `/usr/lib/python3.11/site-packages/upnpp`
- `PKGBUILD`: `makepkg -R` create `python-upnpp` package (`-R` run function `package` only)
```sh
pacman -Sy --needed automake libnpupnp python-devtools python-setuptools swig

su alarm
cd
git clone https://framagit.org/medoc92/libupnpp-bindings.git libupnpp-bindings
cd libupnpp-bindings
./autogen.sh
./configure --prefix=/usr
make

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

### armv6h
```sh
su alarm
cd
mkdir -p python-upnpp
cd python-upnpp
wget https://github.com/rern/rern.github.io/raw/main/PKGBUILD/python-upnpp/armv6h/PKGBUILD
makepkg -R
```
