#!/bin/bash

matchbox="\
dbus-glib glib2-devel gnome-common gobject-introspection gtk-doc intltool \
libjpeg libmatchbox libpng libsm libxcursor libxext \
pango polkit startup-notification xsettings-client"
mpd="\
audiofile avahi boost chromaprint faad2 ffmpeg flac fluidsynth fmt jack \
lame libao libcdio libcdio-paranoia libgme libid3tag libmad libmikmod libmms libmodplug libmpcdec libnfs \
libogg libopenmpt libpulse libsamplerate libshout libsidplayfp libsndfile libsoxr libupnp liburing libvorbis \
meson mpg123 openal opus pipewire python-sphinx smbclient twolame wavpack wildmidi yajl zziplib"

packages="\
alsaequal               : caps ladspa
bluealsa                : bluez bluez-libs bluez-utils glib2-devel libfdk-aac python-docutils sbc
camilladsp              : 
dab-scanner             : cmake rtl-sdr
fakepkg                 : gzip
hfsprogs                : libbsd
matchbox-window-manager : $matchbox
mediamtx                : go
mpd                     : $mpd
mpd_oled                : alsa-lib fftw i2c-tools
python-rpi-gpio         : python-distribute python-setuptools
python-rplcd            : python-setuptools
python-smbus2           : python-setuptools
python-upnpp            : libnpupnp meson-python swig
snapcast                : boost cmake"
arch=$( uname -m )
[[ $arch == armv6h ]] && omit='^camilla|^dab|^mediamtx' || omit='^mpd\s'
packages=$( grep -Ev $omit <<< $packages )
list_menu=$( awk '{print $1}' <<< $packages )
#........................
pkg=$( dialog.menu Package "$list_menu" )
name_pkg=$( sed -n "$pkg p" <<< $list_menu )
depends=$( sed -n "$pkg {s/.*: //; p}" <<< $packages )
#----------------------------------------------------------------------------
if [[ $name_pkg == snapcast ]]; then
	if (( $( awk '/^MemFree/ {print $2}' /proc/meminfo ) < 2000000 )) && ! grep swap /etc/fstab ; then
		swap=$( sed -n '1 {s/-01 .* vfat/-03  swap   swap/; p}' /etc/fstab )
		echo "$swap" >> /etc/fstab
 		dialog.error_exit "\
Snapcast requires \Z1swap partition\Zn for RAM < 3GB.

Added to /etc/fstab:
$swap

» Power off
» GParted - Create swap partition
"
#----------------------------------------------------------------------------
	fi
fi
clear -x
echo -e "$bar Install depends ...\n"
pacman -Sy --noconfirm --needed base-devel git $depends
[[ $arch != aarch64 ]] && sed -i 's/ -mno-omit-leaf-frame-pointer//' /etc/makepkg.conf
buildPackage() {
	local dir_meson name pkg_rel pkg_ver rel url url_rern ver
	cd /home/alarm
	[[ $1 != -i ]] && name=$1 || name=$2
	case $name in
		python-upnpp | xf86-video-fbturbo )
			url_rern=https://github.com/rern/rern.github.io/raw/main
			url=$url_rern/PKGBUILD/$name
			curl -L $url_rern/github-download.sh | bash -s "$url"
			cd $name
			;;
		mpd )
	 		curl -L https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/archive/main/$name-main.tar.gz | bsdtar xf -
			mv $name{-main,}
			cd $name
			[[ $name == mpd ]] && sed -E -i 's/lib(pipewire\s*)/\1/' PKGBUILD
			if [[ $arch == armv6h ]]; then
				dir_meson=/lib/python3.10/site-packages/mesonbuild
				[[ ! -e $dir_meson ]] && ln -s $( ls -d /lib/python*/site-packages/mesonbuild ) $dir_meson
			fi
			;;
   		* )
			curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | bsdtar xf -
			curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/snapcast.tar.gz
			[[ $name == libmatchbox ]] && sed -i 's/libjpeg>=7/libjpeg/' PKGBUILD
			cd $name
			;;
	esac
	chown -R alarm:alarm /home/alarm/$name
	grep -q grep ^pkg_ver= PKGBUILD && var_ver=pkg_ver || var_ver=pkgver
	grep -q grep ^pkg_rel= PKGBUILD && var_rel=pkg_rel || var_ver=pkgrel
	ver=$( grep ^$var_ver= PKGBUILD | cut -d= -f2 )
	rel=$( grep ^$var_rel= PKGBUILD | cut -d= -f2 )
#........................
	pkg_ver=$( dialog.input "\Z1$name\Z0 $var_ver:" $ver )
#........................
	[[ $rel ]] && pkg_rel=$( dialog.input "\Z1$name\Z0 $var_rel:" $rel )
	[[ $ver != $pkg_ver ]] && sed -i -E "s/^($var_ver=).*/\1$pkg_ver/" PKGBUILD
	[[ $rel && $rel != $pkg_rel ]] && sed -i -E "s/^($var_rel=).*/\1$pkg_rel/" PKGBUILD
	if [[ $ver != $pkg_ver || $rel != $pkgre ]]; then
		skipinteg=--skipinteg
	else
#........................
		dialog $opt_yesno "
		
 Skip integrity check?
 
" 0 0 && skipinteg=--skipinteg
	fi
	echo -e "\n$bar Start build $name ...\n"
	sudo -u alarm makepkg -fA $skipinteg
	[[ -z $( ls $name*.xz 2> /dev/null ) ]] && dialog.error_exit Build $name_pkg failed.
#----------------------------------------------------------------------------
	mv -f $name*.xz "$PWD"
	cd "$PWD"
	[[ $1 == -i ]] && pacman -U --noconfirm $name*
}

if [[ $name_pkg == matchbox-window-manager ]]; then
	buildPackage -i gconf
	buildPackage -i libmatchbox
fi
buildPackage $name_pkg
echo -e "
$bar Done
Package: $( ls -1 $name_pkg*.xz | tail -1 )
"
