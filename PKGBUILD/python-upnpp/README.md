```sh
su alarm
pacman -Sy --needed automake libnpupnp python-devtools swig
git clone https://framagit.org/medoc92/libupnpp-bindings.git libupnpp-bindings
cd libupnpp-bindings
./autogen.sh
./configure --prefix=/usr
make

su
make install
su alarm
mkdir -p /home/alarm/python-upnpp/src/upnpp
cp /usr/lib/python3.11/site-packages/upnpp/* /home/alarm/python-upnpp/src/upnpp

wget https://github.com/rern/rern.github.io/raw/main/PKGBUILD/python-upnpp/PKGBUILD -p /home/alarm/python-upnpp
makepkg -R
```