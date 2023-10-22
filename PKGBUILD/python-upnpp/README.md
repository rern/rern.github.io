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

su
make install

su alarm
cd
mkdir -p python-upnpp/src/upnpp
pythonver=$( ls /usr/lib | grep ^python | tail -1 )
cp /usr/lib/$pythonver/site-packages/upnpp/* /home/alarm/python-upnpp/src/upnpp
cd /home/alarm/python-upnpp
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
