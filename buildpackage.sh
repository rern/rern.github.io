#!/bin/bash

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                    Build Packages


" 9 58
sleep 1

declare -A packages=(
	[alsaequal]=caps
	[audio_spectrum_oled]='alsa-lib fftw i2c-tools'
	[bluez-alsa-git]='bluez bluez-libs bluez-utils git libfdk-aac python-docutils sbc'
	[cava]=fftw
	[fakepkg]=gzip
	[hfsprogs]=libbsd
	[matchbox-window-manager]='dbus-glib gnome-common gobject-introspection gtk-doc intltool
								libjpeg libmatchbox libpng libsm libxcursor libxext
								pango polkit startup-notification xsettings-client'
	[mpdscribble]='boost libmpdclient libsoup meson ninja'
	[nginx-mainline-pushstream]='geoip mailcap'
	[p7zip-gui]='p7zip yasm wxgtk2'
	[python-raspberry-gpio]=python-distribute
	[snapcast]='boost cmake git'
	[upmpdcli]='aspell-en expat id3lib jsoncpp libmicrohttpd libmpdclient libnpupnp libupnpp
				python python-requests python-setuptools python-bottle python-mutagen python-waitress
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

[[ $? != 0 ]] && exit

[[ ! -e /usr/bin/distccd ]] && bash <( curl -L https://github.com/rern/rern.github.io/raw/master/distcc-install-master.sh )

[[ ! -e /usr/bin/fakeroot ]] && pkgdepends='base-devel '
pkgname=${pkgs[$pkg]}
pkgdepends+=${packages[$pkgname]}

clear
echo -e "\e[46m  \e[0m Install depends ...\n"

pacman -Sy --noconfirm --needed $pkgdepends

currentdir=$PWD

buildPackage() {
	[[ $1 != -i ]] && name=$1 || name=$2
	cd /home/alarm
	curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | bsdtar xf -
	chown -R alarm:alarm $name
	cd $name
	if [[ $name == bluez-alsa-git ]]; then
		sed -i -e 's/^\(pkgname=bluez-alsa\)-git/\1/
' -e '/--enable-ofono\|--enable-debug/ s/#//
' PKGBUILD
	elif [[ $name == libmatchbox ]]; then
		sed -i 's/libjpeg>=7/libjpeg/' PKGBUILD
	fi
	if [[ -n $pkgver ]]; then
		sed -i "s/^pkgver.*/pkgver=$pkgver; s/^pkgrel.*/pkgrel=$pkgrel/" PKGBUILD
		sudo -u alarm makepkg -fA --skipinteg
	else
		sudo -u alarm makepkg -fA $skipinteg
	fi
		
	if [[ -z $( ls $name*.xz 2> /dev/null ) ]]; then
		echo -e "\n\e[46m  \e[0m Build $pkgname failed."
		exit
	fi
	
	mv -f $name*.xz "$currentdir"
	cd "$currentdir"
	[[ $1 == -i ]] && pacman -U --noconfirm $name*
}
dialog "${optbox[@]}" --yesno "
Default version?
" 0 0
if [[ $? != 0 ]]; then
	pkgver=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 pkgver:
" 0 0 )
	pkgrel=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 pkgrel:
" 0 0 )
else
	dialog "${optbox[@]}" --yesno "
 Skip integrity check?
" 0 0
	[[ $? == 0 ]] && skipinteg=1
fi
if [[ $pkgname == matchbox-window-manager ]]; then
	buildPackage -i gconf
	buildPackage -i libmatchbox
elif [[ $pkgname == upmpdcli ]]; then
	buildPackage -i libnpupnp
	buildPackage -i libupnpp
fi

buildPackage $pkgname

echo -e "\n\e[46m  \e[0m Package: $( ls $pkgname*.xz )\n"
