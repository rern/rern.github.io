#!/bin/bash

arch=$( pacman -Qi bash | awk '/^Arch/ {print $NF}' )
[[ ! $arch =~ .*(aarch|armv).* ]] && echo This is not a Raspberry Pi. && exit

optbox=( --colors --no-shadow --no-collapse )

dialog "${optbox[@]}" --infobox "


                    Build Packages


" 9 58
sleep 1

declare -A packages=(
	[alsaequal]='caps ladspa'
	[bluealsa]='bluez bluez-libs bluez-utils glib2-devel libfdk-aac python-docutils sbc'
	[camilladsp]=
	[cava]='fftw sndio'
	[dab-scanner]='cmake rtl-sdr'
	[distcc]=gtk3
	[fakepkg]=gzip
	[hfsprogs]=libbsd
	[linux-rpi-legacy]='bc kmod inetutils'
	[matchbox-window-manager]='dbus-glib gnome-common gobject-introspection gtk-doc intltool
								libjpeg libmatchbox libpng libsm libxcursor libxext
								pango polkit startup-notification xsettings-client'
	[mediamtx]=go
	[mpd]='audiofile avahi boost chromaprint faad2 ffmpeg flac fluidsynth fmt jack
			lame libao libcdio libcdio-paranoia libgme libid3tag libmad libmikmod libmms libmodplug libmpcdec libnfs
			libogg libopenmpt libpulse libsamplerate libshout libsidplayfp libsndfile libsoxr libupnp liburing libvorbis
			meson mpg123 openal opus pipewire python-sphinx smbclient twolame wavpack wildmidi yajl zziplib'
	[mpd_oled]='alsa-lib fftw i2c-tools'
	[python-pycamilladsp-plot]=python-setuptools
	[python-rpi-gpio]='python-distribute python-setuptools'
	[python-rplcd]=python-setuptools
	[python-smbus2]=python-setuptools
	[python-upnpp]='libnpupnp python-devtools swig'
	[raspberrypi-utils]='cmake dtc'
	[snapcast]='boost cmake'
	[upmpdcli]='aspell-en expat id3lib jsoncpp libmicrohttpd libmpdclient meson
				python python-requests python-setuptools python-bottle python-mutagen python-waitress sqlite'
	[wiringpi]=
	[wirelessregdom-codes]=
)

[[ $arch == armv6h ]] && omit='^camilla|^dab|^mediamtx' || omit='^cava|^mpd$|^rasp|^linux'
[[ $arch != aarch64 ]] && omit+='|^wiringpi'
menu=$( xargs -n1 <<< ${!packages[@]} | grep -Ev $omit | sort )

pkgname=$( dialog "${optbox[@]}" --output-fd 1 --no-items --menu "
 \Z1Package\Z0:
" 0 0 0 $menu )

[[ $? != 0 ]] && exit

if [[ $pkgname == snapcast ]]; then
	(( $( awk '/^MemFree/ {print $2}' /proc/meminfo ) < 2000000 )) && echo 'Snapcast requires swap partition.' && exit
fi

urlrern=https://github.com/rern/rern.github.io/raw/main
if [[ $pkgname == wirelessregdom-codes ]]; then
	bash <( curl -skL $urlrern/wirelessregdom.sh )
	exit
fi

packagelist=${packages[$pkgname]}

clear
echo -e "\e[46m  \e[0m Install depends ...\n"
pacman -Sy --noconfirm --needed base-devel fakeroot git $packagelist
[[ $arch != aarch64 ]] && sed -i 's/ -mno-omit-leaf-frame-pointer//' /etc/makepkg.conf

currentdir=$PWD

buildPackage() {
	cd /home/alarm
	[[ $1 != -i ]] && name=$1 || name=$2
	urlalarm=https://github.com/archlinuxarm/PKGBUILDs/raw/master
	case $name in
		distcc | linux-rpi-legacy | raspberrypi-utils | xf86-video-fbturbo )
			case $name in
				distcc )
					url=$urlalarm/extra/$name
					;;
				raspberrypi-utils )
					url=$urlalarm/alarm/$name
					;;
				* )
					url=$urlrern/PKGBUILD/$name
					;;
			esac
			curl -L $urlrern/github-download.sh | bash -s "$url"
			cd $name
			;;
		libnpupnp | libupnpp | mpd | upmpdcli )
	 		curl -L https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/archive/main/$name-main.tar.gz | bsdtar xf -
			mv $name{-main,}
			cd $name
			[[ $name == mpd ]] && sed -E -i 's/lib(pipewire\s*)/\1/' PKGBUILD
			if [[ $arch == armv6h ]]; then
				dirmeson=/lib/python3.10/site-packages/mesonbuild
				[[ ! -e $dirmeson ]] && ln -s $( ls -d /lib/python*/site-packages/mesonbuild ) $dirmeson
			fi
			;;
		wiringpi ) # fix: No 'Hardware' line in /proc/cpuinfo anymore
			mkdir -p wiringpi
			cd wiringpi
			curl -LO $urlalarm/alarm/wiringpi/PKGBUILD
			sed -i "/wiringPi.c/ a\  sed -i '/Start by/,/Or the next/ d' wiringPi/wiringPi.c" PKGBUILD
			;;
		* )
			curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | bsdtar xf -
			cd $name
			case $name in
				cava )        sed -i 's/^arch=.*/arch=(armv6h armv7h aarch64)/' PKGBUILD;;
				libmatchbox ) sed -i 's/libjpeg>=7/libjpeg/' PKGBUILD;;
			esac
			;;
	esac
	chown -R alarm:alarm /home/alarm/$name
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
