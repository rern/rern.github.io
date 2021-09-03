#!/bin/bash

pkgname=$1

case $pkgname in

audio_spectrum_oled )       depends='alsa-lib fftw i2c-tools'
bluez-alsa-git )            depends='bluez bluez-libs bluez-utils git libfdk-aac python-docutils sbc';;
cava )                      depends=fftw;;
fakepkg )                   depends=gzip;;
hfsprogs )                  depends=libbsd;;
github-desktop )            depends='gconf git gnome-keyring libsecret libxss nspr nss unzip';;
gconf )                     depends='polkit dbus-glib intltool gtk-doc gobject-introspection gnome-common';;
libmatchbox )               depends='pango libpng libjpeg xsettings-client libxext';;
matchbox-window-manager )   depends='libmatchbox startup-notification libpng libsm libxcursor';;
mpdscribble )               depends='boost libmpdclient libsoup meson ninja';;
nginx-mainline-pushstream ) depends='geoip mailcap';;
p7zip-gui )                 depends='p7zip yasm wxgtk2';;
python-raspberry-gpio )     depends=python-distribute;;
rpi-imager )                depends='libarchive qt5-base qt5-declarative qt5-quickcontrols2 qt5-svg qt5-tools';;
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
