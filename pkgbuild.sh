#!/bin/bash

[[ ! $( uname -a ) =~ .*(aarch|armv).* ]] && echo This is not a Raspberry Pi. && exit

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                    Build Packages


" 9 58
sleep 1

clientip=$( dialog "${optbox[@]}" --output-fd 1 --cancel-label Skip --inputbox "
 \Z1Distcc\Z0 client IP:
" 0 0 '192.168.1.' )
if [[ $? == 0 ]]; then
	clientpwd=$( dialog "${optbox[@]}" --output-fd 1 --nocancel --inputbox "
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
	if [[ $? == 0 ]]; then
		sed -i -e 's/\(BUILDENV=(\)!distcc/\1distcc/
' -e 's/^\(DISTCC_HOSTS="\).*/D\1'$ip':3634/8"/
' /etc/makepkg.conf
	else
		sed -i 's/\(BUILDENV=(\)distcc/\1!distcc/' /etc/makepkg.conf
	fi
else
	nodistcc=1
	sed -i 's/\(BUILDENV=(\)distcc/\1!distcc/' /etc/makepkg.conf
fi

declare -A packages=(
	[alsaequal]=caps
	[audio_spectrum_oled]='alsa-lib fftw i2c-tools'
	[bluealsa]='bluez bluez-libs bluez-utils libfdk-aac python-docutils sbc'
	[camilladsp]='alsa-lib pkg-config'
	[camillagui-backend]=
	[cava]=fftw
	[dab-scanner]='cmake rtl-sdr'
	[fakepkg]=gzip
	[hfsprogs]=libbsd
	[linux-rpi-legacy]='bc kmod inetutils'
	[matchbox-window-manager]='dbus-glib gnome-common gobject-introspection gtk-doc intltool
								libjpeg libmatchbox libpng libsm libxcursor libxext
								pango polkit startup-notification xsettings-client'
	[mpd]='boost meson python-sphinx'
	[nginx-mainline-pushstream]='geoip mailcap'
	[python-pycamilladsp]=
	[python-pycamilladsp-plot]=
	[python-rpi-gpio]=python-distribute
	[python-rplcd]=
	[python-smbus2]=
	[raspberrypi-firmware]=
	[rtsp-simple-server]=go
	[snapcast]='boost cmake'
	[upmpdcli]='aspell-en expat id3lib jsoncpp libmicrohttpd libmpdclient
				python python-requests python-setuptools python-bottle python-mutagen python-waitress
				recoll sqlite'
)

[[ $arch == armv6h ]] && omit='^rtsp' || omit='^mpd|^rasp|^linux'
menu=$( xargs -n1 <<< ${!packages[@]} | grep -Ev $omit | sort )

pkgname=$( dialog "${optbox[@]}" --output-fd 1 --no-items --menu "
 \Z1Package\Z0:
" 0 0 0 $menu )

[[ $? != 0 ]] && exit

[[ ! $nodistcc && ! -e /usr/bin/distccd ]] && curl -L https://github.com/rern/rern.github.io/raw/main/distcc-install-master.sh | bash -s $clientip

clear
echo -e "\e[46m  \e[0m Install depends ...\n"

pacman -Sy --noconfirm --needed base-devel ${packages[$pkgname]}

currentdir=$PWD

buildPackage() {
	[[ $1 != -i ]] && name=$1 || name=$2
	cd /home/alarm
	curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | sudo -u alarm bsdtar xf -
	cd $name
	case $name in
		libmatchbox )
			sed -i 's/libjpeg>=7/libjpeg/' PKGBUILD;;
		mpd | raspberrypi-firmware )
			sed -i 's/armv7h/armv6h' PKGBUILD;;
		rtsp-simple-server)
			sed -i "s/arch=('any')/arch=('armv6h' 'armv7h' 'aarch64')/" PKGBUILD;;
	esac
	ver=$( grep ^pkgver= PKGBUILD | cut -d= -f2 )
	rel=$( grep ^pkgrel= PKGBUILD | cut -d= -f2 )
	pkgver=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1$name\Z0
 pkgver:
" 0 0 $ver )
	[[ $? != 0 ]] && return
	
	[[ -n $rel ]] && pkgrel=$( dialog "${optbox[@]}" --output-fd 1 --nocancel --inputbox "
 \Z1$name\Z0
 pkgrel:
" 0 0 $rel )
	if [[ $ver != $pkgver || $rel != $pkgrel || $name == mpd || $name == raspberrypi-firmware ]]; then
		sed -i "s/^pkgver.*/pkgver=$pkgver/" PKGBUILD
		[[ -n $pkgrel ]] && sed -i "s/^pkgrel.*/pkgrel=$pkgrel/" PKGBUILD
		skipinteg=--skipinteg
	else
		dialog --defaultno "${optbox[@]}" --yesno "
		
 Skip integrity check?
 
" 0 0
		[[ $? == 0 ]] && skipinteg=--skipinteg
	fi
	
	echo -e "\n\n\e[46m  \e[0m Start build $name ...\n"
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
