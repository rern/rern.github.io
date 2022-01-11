#!/bin/bash

! grep -q rpi <<< $( uname -a ) && echo Not Raspberry Pi && exit

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                    Build Packages


" 9 58
sleep 1

clientip=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 Distcc client IP:
" 0 0 '192.168.1.' )
clientpwd=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 Distcc client Password:
" 0 0 )
case $( uname -m ) in
	armv6l )  arch=armv6h;;
	armv7l )  arch=armv7h;;
	aarch64 ) arch=armv8;;
esac
echo -e "\e[46m  \e[0m Start Distcc client ...\n"
sshpass -p $clientpwd ssh -qo StrictHostKeyChecking=no root@$clientip \
			"systemctl stop distccd-arm*; systemctl start distccd-$arch"

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
	[nginx-mainline-pushstream]='geoip mailcap'
	[p7zip-gui]='p7zip yasm wxgtk2'
	[python-rpi-gpio]=python-distribute
	[snapcast]='boost cmake'
	[upmpdcli]='aspell-en expat id3lib jsoncpp libmicrohttpd libmpdclient
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

[[ ! -e /usr/bin/distccd ]] && curl -L https://github.com/rern/rern.github.io/raw/master/distcc-install-master.sh | bash -s $clientip

pkgdepends='base-devel '
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
	ver=$( grep ^pkgver PKGBUILD | cut -d= -f2 )
	rel=$( grep ^pkgrel PKGBUILD | cut -d= -f2 )
	pkgver=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 pkgver:
" 0 0 $ver )
	[[ -n $rel ]] && pkgrel=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 pkgrel:
" 0 0 $rel )
	if [[ $ver != $pkgver || $rel != $pkgrel ]]; then
		sed -i "s/^pkgver.*/pkgver=$pkgver/" PKGBUILD
		[[ -n $pkgrel ]] && sed -i "s/^pkgrel.*/pkgrel=$pkgrel/" PKGBUILD
		skipinteg=--skipinteg
	else
		dialog --defaultno "${optbox[@]}" --yesno "
		
 Skip integrity check?
 
" 0 0
		[[ $? == 0 ]] && skipinteg=--skipinteg
	fi
	
	echo -e "\e[46m  \e[0m Start build ...\n"
	sudo -u alarm makepkg -fA $skipinteg
	
	if [[ -z $( ls $name*.xz 2> /dev/null ) ]]; then
		echo -e "\n\e[46m  \e[0m Build $pkgname failed."
		exit
	fi
	
	mv -f $name*.xz "$currentdir"
	cd "$currentdir"
	[[ $1 == -i ]] && pacman -U --noconfirm $name*
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
