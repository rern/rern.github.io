**+R repo**: [rern.github.io](https://rern.github.io)

**Build packages**
- Build (on RPi)
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/pkgbuild.sh )
```
- Update repo (on RPi)
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/repoupdate.sh )
```
- RPi Zero: Might need swap partition (eg.: `gcc` `upmpdcli`)
	- Gparted > Resize > Create 4GB `linux-swap` partition
	```sh
	partuuid=$( blkid /dev/mmcblk0p3 -o value | tail -1 )
	echo PARTUUID=$partuuid  swap   swap  defaults          0  0 > /etc/fstab
	mount -a
	```

**Arch Linux Arm Repo**:
- Current - http://mirror.archlinuxarm.org
- Archives
	- http://alaa.ad24.cz/packages
	- http://tardis.tiny-vps.com/aarm/packages

**Arch Linux Arm Sources**:
- `PKGBUILD` - [https://github.com/archlinuxarm/PKGBUILDs](https://github.com/archlinuxarm/PKGBUILDs)
	- Not found: Go to: [https://archlinux.org](https://archlinux.org) > Package search > Source Files
- Obsolete ARMv6
	- Set mirror server `/etc/pacman.d/mirrorlist`:
		- `Server = http://alaa.ad24.cz/repos/2022/02/06/$arch/$repo` (2022/02/06 as the latest)
		- `Server = http://tardis.tiny-vps.com/aarm/repos/2022/01/08/$arch/$repo` (2022/01/08 as the latest)
	- To compile with `PKGBUILD` from last available in [GitHub history](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810).
		- Download GitHub specific directory: https://download-directory.github.io/
	- Kernel and firmware
		- `firmware-raspberrypi` - `any`
		- `linux-firmware` - `any`
		- `linux-firmware-whence` - `any`
		- [`linux-rpi-legacy`](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810/core/linux-rpi-legacy) - `armv6h`
		- `raspberrypi-bootloader` - `any`
		- [`raspberrypi-firmware`](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810/alarm/raspberrypi-firmware) - `armv6h`

**Cross compile**:
- [Distcc](https://github.com/rern/rern.github.io/blob/main/cross-compile.md#distcc)
- [Docker](https://github.com/rern/rern.github.io/blob/main/cross-compile.md#docker)

**Custom packages**
- [bluez-alsa](https://github.com/Arkq/bluez-alsa/tags)
- [camilladsp](https://github.com/HEnquist/camilladsp)
	- [camillagui](https://github.com/HEnquist/camillagui)
	- [camillagui-backend](https://github.com/HEnquist/camillagui-backend)
	- [pycamilladsp](https://github.com/HEnquist/pycamilladsp)
	- [pycamilladsp-plot](https://github.com/HEnquist/pycamilladsp-plot)
- [cava](https://github.com/karlstav/cava)
- [mediamtx](https://github.com/aler9/mediamtx)
- [mpd_oled](https://github.com/antiprism/mpd_oled/tags)
- [nginx](https://nginx.org)
- [snapcast](https://github.com/badaix/snapcast)
- [upmpdcli](https://www.lesbonscomptes.com/upmpdcli/pages/downloads.html)

**JS plugins**
- [html5kellycolorpicker](https://github.com/NC22/HTML5-Color-Picker)
- [jquery](https://jquery.com/)
- [lazysizes](https://github.com/aFarkas/lazysizes)
- [pica](https://github.com/nodeca/pica/tags)
- [pushstream](https://github.com/wandenberg/nginx-push-stream-module/blob/master/misc/js/pushstream.js)
- [qrcode](https://github.com/datalog/qrcode-svg)
- [roundslider](https://github.com/soundar24/roundSlider)
- [Select2](https://github.com/select2/select2)
- [simple-keyboard](https://github.com/hodgef/simple-keyboard/blob/master/build/index.modern.js)
	- Remove sourcemap - last line: //# sourceMappingURL=index.modern.js.map
- [Sortable](https://github.com/SortableJS/Sortable)
