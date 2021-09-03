#!/bin/bash

pkgname=$1

case $pkgname in
	
p7zip-gui )                 depends='p7zip yasm wxgtk2';;
bluez-alsa-git )            depends='bluez bluez-libs bluez-utils git libfdk-aac python-docutils sbc';;
cava )                      depends=fftw;;
hfsprogs )                  depends=libbsd;;
gconf )                     depends='polkit dbus-glib intltool gtk-doc gobject-introspection gnome-common';;
libmatchbox )               depends='pango libpng libjpeg xsettings-client libxext';;
matchbox-window-manager )   depends='libmatchbox startup-notification libpng libsm libxcursor';;
mpdscribble )               depends='boost libmpdclient libsoup meson ninja';;
nginx-mainline-pushstream ) depends='geoip mailcap';;
snapcast )                  depends='boost cmake git';;
libnpupnp )                 depends='expat libmicrohttpd';;
libupnpp )                  depends='libnpupnp expat';;
upmpdcli )                  depends='aspell-en id3lib jsoncpp libmicrohttpd libmpdclient libupnpp \
                                      python python-requests python-setuptools python-bottle python-mutagen python-waitress recoll sqlite';;

esac

pacman -S --noconfirm --needed $depends
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$pkgname.tar.gz | bsdtar xf -
cd $pkgname
makepkg -A
