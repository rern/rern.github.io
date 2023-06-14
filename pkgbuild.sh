#!/bin/bash

arch=$( pacman -Qi bash | awk '/^Arch/ {print $NF}' )
[[ ! $arch =~ .*(aarch|armv).* ]] && echo This is not a Raspberry Pi. && exit

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
	[camilladsp]='alsa-lib pkg-config rust'
	[camillagui-backend]=
	[cava]='fftw sndio'
	[dab-scanner]='cmake rtl-sdr'
	[fakepkg]=gzip
	[hfsprogs]=libbsd
	[linux-rpi-legacy]='bc kmod inetutils'
	[matchbox-window-manager]='dbus-glib gnome-common gobject-introspection gtk-doc intltool
								libjpeg libmatchbox libpng libsm libxcursor libxext
								pango polkit startup-notification xsettings-client'
	[mediamtx]=go
	[mpd]='audiofile avahi boost chromaprint faad2 ffmpeg flac fluidsynth fmt jack
			lame libao libcdio libcdio-paranoia libgme libid3tag libmad libmikmod libmms libmodplug libmpcdec libnfs libogg
			libopenmpt libpipewire libpulse libsamplerate libshout libsidplayfp libsndfile libsoxr libupnp liburing libvorbis
			meson mpg123 openal opus python-sphinx smbclient twolame wavpack wildmidi yajl zziplib'
	[nginx-mainline-pushstream]='geoip mailcap'
	[python-pycamilladsp]='python-setuptools'
	[python-pycamilladsp-plot]='python-setuptools'
	[python-rpi-gpio]='python-distribute python-setuptools'
	[python-rplcd]='python-setuptools'
	[python-smbus2]='python-setuptools'
	[raspberrypi-firmware]=
	[snapcast]='boost cmake'
	[upmpdcli]='aspell-en expat id3lib jsoncpp libmicrohttpd libmpdclient
				python python-requests python-setuptools python-bottle python-mutagen python-waitress
				recoll sqlite'
)

[[ $arch == armv6h ]] && omit='camilla|^dab|^rtsp' || omit='^mpd|^rasp|^linux'
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
	cd /home/alarm
	[[ $1 != -i ]] && name=$1 || name=$2
	if [[ $name == mpd ]]; then
		curl -L https://gitlab.archlinux.org/archlinux/packaging/packages/mpd/-/archive/main/mpd-main.tar.gz | sudo -u alarm bsdtar xf -
		mv mpd{-main,}
	elif [[ $name == raspberrypi-firmware && ! -e raspberrypi-firmware ]]; then
		mkdir -p raspberrypi-firmware
		cd raspberrypi-firmware
		files="\
00-raspberrypi-firmware.conf
10-raspberrypi-firmware.rules
PKGBUILD
raspberrypi-firmware.sh"
		for file in $files; do
			curl -LO https://github.com/rern/rern.github.io/raw/main/PKGBUILD/raspberrypi-firmware/$file
		done
		sed -i 's/armv7h/armv6h/' PKGBUILD
		chown -R alarm:alarm /home/alarm/raspberrypi-firmware
		cd ..
	else
		curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | sudo -u alarm bsdtar xf -
		[[ $name == libmatchbox ]] && sed -i 's/libjpeg>=7/libjpeg/' PKGBUILD
	fi
	cd $name
	ver=$( grep ^pkgver= PKGBUILD | cut -d= -f2 )
	rel=$( grep ^pkgrel= PKGBUILD | cut -d= -f2 )
	pkgver=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1$name\Z0
 pkgver:
" 0 0 $ver )
	[[ $? != 0 ]] && return
	
	[[ $rel ]] && pkgrel=$( dialog "${optbox[@]}" --output-fd 1 --nocancel --inputbox "
 \Z1$name\Z0
 pkgrel:
" 0 0 $rel )
	if [[ $ver != $pkgver || $rel != $pkgre ]]; then
		sed -i "s/^pkgver.*/pkgver=$pkgver/" PKGBUILD
		[[ $pkgrel ]] && sed -i "s/^pkgrel.*/pkgrel=$pkgrel/" PKGBUILD
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

echo -e "\n\e[46m  \e[0m Package: $( ls -1 $pkgname*.xz | tail -1 )\n"
