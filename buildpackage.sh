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
	[matchbox-window-manager]='dbus-glib gnome-common gobject-introspection gtk-doc intltool \
								libjpeg libmatchbox libpng libsm libxcursor libxext \
								pango polkit startup-notification xsettings-client'
	[mpdscribble]='boost libmpdclient libsoup meson ninja'
	[nginx-mainline-pushstream]='geoip mailcap'
	[p7zip-gui]='p7zip yasm wxgtk2'
	[python-raspberry-gpio]=python-distribute
	[snapcast]='boost cmake git'
	[upmpdcli]='aspell-en expat id3lib jsoncpp libmicrohttpd libmpdclient libnpupnp libupnpp \
				python python-requests python-setuptools python-bottle python-mutagen python-waitress \
				recoll sqlite'
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

clear
echo -e "\e[46m  \e[0m Install depends ...\n"

[[ ! -e /usr/bin/fakeroot ]] && depends="$base-devel depends"

pacman -S --noconfirm --needed $depends

currentdir=$PWD

buildPackage() {
	[[ $1 != -i ]] && pkgname=$1 || pkgname=$2
	cd /home/alarm
	curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$pkgname.tar.gz | bsdtar xf -
	chown -R alarm:alarm $pkgname
	cd $pkgname
	sudo -u alarm makepkg -fA
	mv -f $pkgname*.xz "$currentdir"
	cd "$currentdir"
	[[ $1 == -i ]] && pacman -U --noconfirm $pkgname*
}

if [[ $pkgname == matchbox-window-manager ]]; then
	buildPackage -i gconf
	buildPackage -i libmatchbox
elif [[ $pkgname == upmpdcli ]]; then
	buildPackage -i libnpupnp
	buildPackage -i libupnpp
fi

buildPackage $pkgname

echo -e "\n\e[46m  \e[0m Package: $( ls $pkgname*.xz )\n"
