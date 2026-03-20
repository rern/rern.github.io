#!/bin/bash

SECONDS=0
dir_base=$PWD

matchbox="\
dbus-glib glib2-devel gnome-common gobject-introspection gtk-doc intltool \
libjpeg libmatchbox libpng libsm libxcursor libxext \
pango polkit startup-notification xsettings-client"

list="\
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
list_menu=$( awk '{print $1}' <<< $list )
#........................
package=$( dialog.menu Package "$list_menu" )
pkg_name=$( sed -n "$package p" <<< $list_menu )
depends=$( sed -n "$package {s/.*: //; p}" <<< $list )
#----------------------------------------------------------------------------
if [[ $pkg_name == snapcast ]]; then
	if (( $( awk '/^MemFree/ {print $2}' /proc/meminfo ) < 2000000 )); then
		file_swap=/swap
		fallocate -l 4G $file_swap
		chmod 600 $file_swap
		mkswap $file_swap
		swapon $file_swap
	fi
fi
clear -x
for pkg in base-devel git $depends; do
	! pacman -Qi $pkg &> /dev/null && pkg_install+="$pkg "
done
if [[ $pkg_install ]]; then
	banner Install depends ...
	pacman -Sy --noconfirm $pkg_install
fi
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
	clear -x
	banner Build $name ...
	sudo -u alarm makepkg -fA $skipinteg
	[[ ! $( ls $name*.xz 2> /dev/null ) ]] && dialog.error_exit Build $pkg_name failed.
#----------------------------------------------------------------------------
	[[ $1 == -i ]] && pacman -U --noconfirm $name*.xz
	mv -f $name*.xz $dir_base
}

if [[ $pkg_name == matchbox-window-manager ]]; then
	buildPackage -i gconf
	buildPackage -i libmatchbox
fi
buildPackage $pkg_name
[[ -e $file_swap ]] && swapoff $file_swap && rm $file_swap
cd $dir_base
bar "Done
Package: $( ls $pkg_name*.xz | tail -1 )
$( date -d@$SECONDS -u +%M:%S )
"
