#!/bin/bash

matchbox="\
dbus-glib glib2-devel gnome-common gobject-introspection gtk-doc intltool \
libjpeg libmatchbox libpng libsm libxcursor libxext \
pango polkit startup-notification xsettings-client"

packages="\
alsaequal               : caps ladspa
bluealsa                : bluez bluez-libs bluez-utils glib2-devel libfdk-aac python-docutils sbc
camilladsp              : 
dab-scanner             : cmake rtl-sdr
fakepkg                 : gzip
hfsprogs                : libbsd
matchbox-window-manager : $matchbox
mediamtx                : go
mpd_oled                : alsa-lib fftw i2c-tools
python-rpi-gpio         : python-distribute python-setuptools
python-rplcd            : python-setuptools
python-smbus2           : python-setuptools
python-upnpp            : libnpupnp meson-python swig
snapcast                : boost cmake"
list_menu=$( awk '{print $1}' <<< $packages )
#........................
pkg=$( dialog.menu Package "$list_menu" )
name_pkg=$( sed -n "$pkg p" <<< $list_menu )
depends=$( sed -n "$pkg {s/.*: //; p}" <<< $packages )
#----------------------------------------------------------------------------
if [[ $name_pkg == snapcast ]]; then
	if (( $( awk '/^MemFree/ {print $2}' /proc/meminfo ) < 2000000 )) && ! grep swap /etc/fstab ; then
		fstab_swap=$( sed -n -E '1 {s/(.*-0).*/\13    none   swap  sw  0  0/; p}' /etc/fstab )
		echo $fstab_swap >> /etc/fstab
 		dialog.error_exit "\
Snapcast requires \Z1swap partition\Zn for RAM < 3GB.

Added to /etc/fstab:
$fstab_swap

» Power off
» GParted - Create 4GB linux-swap partition
"
#----------------------------------------------------------------------------
	fi
fi
clear -x
echo -e "$bar Install depends ...\n"
pacman -Sy --noconfirm --needed base-devel git $depends
#[[ $( uname -m ) != aarch64 ]] && sed -i 's/ -mno-omit-leaf-frame-pointer//' /etc/makepkg.conf
buildPackage() {
	local dir_meson name pkg_rel pkg_ver rel url url_rern ver
	cd /home/alarm
	[[ $1 != -i ]] && name=$1 || name=$2
	case $name in
		python-upnpp | xf86-video-fbturbo )
			url_rern=https://github.com/rern/rern.github.io/raw/main
			url=$url_rern/PKGBUILD/$name
			curl -L $url_rern/github-download.sh | bash -s "$url"
			;;
   		* )
			curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/$name.tar.gz | bsdtar xf -
			[[ $name == libmatchbox ]] && sed -i 's/libjpeg>=7/libjpeg/' PKGBUILD
			;;
	esac
	chown -R alarm:alarm $name
	cd $name
	read ver rel < <( awk -F= '/^pkg_*ver=|^pkg_*rel/ {print $2}' PKGBUILD | tr '\n' ' ' )
#........................
	pkg_ver=$( dialog.input "\Z1$name\Z0 version:" $ver )
#........................
	[[ $rel ]] && pkg_rel=$( dialog.input "\Z1$name\Z0 release:" $rel )
	[[ $ver != $pkg_ver ]] && sed -i -E "s/^(pkg_*ver=).*/\1$pkg_ver/" PKGBUILD
	[[ $rel && $rel != $pkg_rel ]] && sed -i -E "s/^(pkg_*rel=).*/\1$pkg_rel/" PKGBUILD
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
	[[ $1 == -i ]] && pacman -U --noconfirm $name*.xz
	mv -f $name*.xz /root
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
