**Build packages**
- On RPi
- `armv6h`: Run manually on Docker. `gcc` on RPi0,1 is not up to date.
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/pkgbuild.sh )
```
**+R repo**: [rern.github.io](https://rern.github.io)

**Arch Linux Arm Repo**:
- Current - http://mirror.archlinuxarm.org
- Archives
	- http://tardis.tiny-vps.com/aarm/packages
	- http://alaa.ad24.cz/packages

**Arch Linux Arm Sources**:
- `PKGBUILD`s - https://github.com/archlinuxarm/PKGBUILDs
- Not in `https://github.com/archlinuxarm/PKGBUILDs`:
  - List - https://github.com/archlinux/svntogit-community
  - Source - `https://github.com/archlinux/svntogit-community/blob/master/PKG_NAME`
- Obsolete ARMv6
	- Set mirror server `/etc/pacman.d/mirrorlist`:
		- `Server = http://alaa.ad24.cz/repos/2022/02/06/$arch/$repo` (2022/02/06 as the latest)
		- `Server = http://tardis.tiny-vps.com/aarm/repos/2022/01/08/$arch/$repo` (2022/01/08 as the latest)
	- To compile with `PKGBUILD` from last available in [GitHub history](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810).
		- Download GitHub specific directory: https://download-directory.github.io/
		- Kernel: [`linux-rpi-legacy`](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810/core/linux-rpi-legacy)
			- No Distcc
			- Compile on ARMv6 Docker (faster than native)
		- Bootloader: [`raspberrypi-bootloader`](https://archlinuxarm.org/packages/any/raspberrypi-bootloader)
			- Either package for `armv7h` or `aarch64` can be used. (`any` package)
		- Firmware: [`raspberrypi-firmware`](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810/alarm/raspberrypi-firmware)
			- No need for Distcc - Compile just packs directories and files to package.

**Cross compile**:
- [Distcc](https://github.com/rern/rern.github.io/blob/main/cross-compile.md#distcc)
- [Docker](https://github.com/rern/rern.github.io/blob/main/cross-compile.md#docker)

**Custom packages**
- [bluez-alsa](https://github.com/Arkq/bluez-alsa/tags)
- [nginx](https://nginx.org/)
- [snapcast](https://github.com/badaix/snapcast)
- [upmpdcli](https://www.lesbonscomptes.com/upmpdcli/pages/downloads.html)

**JS plugins**
- [html5kellycolorpicker](https://github.com/NC22/HTML5-Color-Picker)
- [jquery.selectric](https://github.com/lcdsantos/jQuery-Selectric/tags)
- [jquery](https://jquery.com/)
- [lazysizes](https://github.com/aFarkas/lazysizes)
- [pica](https://github.com/nodeca/pica/tags)
- [pushstream](https://github.com/wandenberg/nginx-push-stream-module/blob/master/misc/js/pushstream.js)
- [qrcode](https://github.com/datalog/qrcode-svg)
- [roundslider](https://github.com/soundar24/roundSlider)
- [simple-keyboard](https://github.com/hodgef/simple-keyboard/blob/master/build/index.modern.js)
	- Remove sourcemap - last line: //# sourceMappingURL=index.modern.js.map
- [Sortable](https://github.com/SortableJS/Sortable)
