### `python-upnpp`

- **RPi Zero only** - setup swap partition (on PC)
	- Gparted > Resize > Create 4GB linux-swap partition
 	- Dolphin > Click to mount `ROOT`
	```sh
	fstab=/run/media/x/ROOT/etc/fstab
	swap=$( sed -n '1 {s/01 .* vfat/03  swap   swap/; p}' $fstab )
	echo "$swap" >> $fstab
	```

- `Makefile`: `make` > `make install` to `/usr/lib/python3.11/site-packages/upnpp`
```sh
pacman -Sy --needed automake libnpupnp python-setuptools swig

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
