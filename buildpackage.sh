#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                    Build Packages


" 9 58
sleep 1

declare -A packages=(
	[audio_spectrum_oled]='alsa-lib fftw i2c-tools'
	[bluez-alsa-git]='bluez bluez-libs bluez-utils git libfdk-aac python-docutils sbc'
	[cava]=fftw
	[fakepkg]=gzip
	[hfsprogs]=libbsd
	[gconf]='polkit dbus-glib intltool gtk-doc gobject-introspection gnome-common'
	[libmatchbox]='pango libpng libjpeg xsettings-client libxext'
	[matchbox-window-manager]='libmatchbox startup-notification libpng libsm libxcursor'
	[mpdscribble]='boost libmpdclient libsoup meson ninja'
	[nginx-mainline-pushstream]='geoip mailcap'
	[p7zip-gui]='p7zip yasm wxgtk2'
	[python-raspberry-gpio]=python-distribute
	[snapcast]='boost cmake git'
	[libnpupnp]='expat libmicrohttpd'
	[libupnpp]='libnpupnp expat'
	[upmpdcli]='aspell-en id3lib jsoncpp libmicrohttpd libmpdclient libupnpp python python-requests python-setuptools python-bottle python-mutagen python-waitress recoll sqlite'
)
pkgs=( $( echo "${!packages[@]}" | tr ' ' '\n' | sort ) )
pkgsL=${#pkgs[@]}
for (( i=0; i < $pkgsL; i++ )); do
menu+="
$i ${pkgs[$i]}"
done

pkg=$( dialog "${optbox[@]}" --output-fd 1 --menu "
 \Z1Package\Z0:
" 0 0 0 $menu )

pkgname=${pkgs[$pkg]}
depends=${packages[$pkgname]}

pacman -S --noconfirm --needed $depends

currentdir=$PWD

cd /home/alarm
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$pkgname.tar.gz | bsdtar xf -
chown -R alarm:alarm $pkgname
cd $pkgname
sudo -u alarm makepkg -A

mv -f $pkgname* "$currentdir"
cd "$currentdir"
echo Package:
ls $pkgname*
