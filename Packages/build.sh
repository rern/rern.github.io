#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                    Build Packages
" 9 58
sleep 1

pkg=$( dialog "${optbox[@]}" --output-fd 1 --menu "
 \Z1Package\Z0:
" 0 0 0 \
	1 audio_spectrum_oled \
	2 bluez-alsa-git \
	3 cava \
	4 fakepkg \
	5 hfsprogs \
	6 github-desktop \
	7 gconf \
	8 libmatchbox \
	9 matchbox-window-manager \
	10 mpdscribble \
	11 nginx-mainline-pushstream \
	12 p7zip-gui \
	13 python-raspberry-gpio \
	14 rpi-imager \
	15 snapcast \
	16 libnpupnp \
	17 libupnpp \
	18 upmpdcli )

case $pkg in
	1 ) audio_spectrum_oled
	2 ) bluez-alsa-git
	3 ) cava
	4 ) fakepkg
	5 ) hfsprogs
	6 ) github-desktop
	7 ) gconf
	8 ) libmatchbox
	9 ) matchbox-window-manager
	10 ) mpdscribble
	11 ) nginx-mainline-pushstream
	12 ) p7zip-gui
	13 ) python-raspberry-gpio
	14 ) rpi-imager
	15 ) snapcast
	16 ) libnpupnp
	17 ) libupnpp
	18 ) upmpdcli
esac


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
