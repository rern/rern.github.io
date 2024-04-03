**+R repo**: [rern.github.io](https://rern.github.io)

**Build packages** (on rAudio):
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/package.sh )
```
- Build
- Update repo
- AUR setup
- Create `regdomcodes.json`
- Create `guide.tar.xz`
- RPi Zero, 1 - update firmware:
	- `firmware-raspberrypi` `linux-firmware` `raspberrypi-bootloader`
- RPi Zero: Might need swap partition (eg.: `gcc`, `python-upnpp`, `upmpdcli`) - on PC
	- Gparted > Resize > Create 4GB `linux-swap` partition
   	```sh
    fstab=/run/media/x/ROOT/etc/fstab
 	swap=$( sed -n '1 {s/01 .* vfat/03  swap   swap/; p}' $fstab )
	echo "$swap" >> $fstab
	```

**Arch Linux Arm Repo**:
- Current - http://mirror.archlinuxarm.org
- Archives
	- http://alaa.ad24.cz/packages
	- http://tardis.tiny-vps.com/aarm/packages

**Arch Linux Arm Sources**:
- `PKGBUILD` - [https://github.com/archlinuxarm/PKGBUILDs](https://github.com/archlinuxarm/PKGBUILDs)
	- Not found: Go to: [https://archlinux.org](https://archlinux.org) > Package search > Source Files
   	- Archives for `linux-rpi-legacy`: [PKGBUILDs](https://github.com/archlinuxarm/PKGBUILDs/tree/4a2735c88645cf21e6817b6a32902f0528a60887)
- Obsolete ARMv6
	- `/etc/pacman.d/mirrorlist`:
		```sh
  		# updated packages for arch 'any' (armv6h will not be available)
  		Server = http://mirror.archlinuxarm.org/armv7h/$repo
  
  		# archive - mirror.archlinuxarm.org must be commented/removed
		Server = http://alaa.ad24.cz/repos/2022/02/06/$arch/$repo
		```
	- To compile with `PKGBUILD` from last available in [GitHub history](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810).
		- Download GitHub specific directory: https://download-directory.github.io/
	- Kernel and firmware
		- `firmware-raspberrypi` - `any`
		- `linux-firmware` - `any`
		- `linux-firmware-whence` - `any`
		- [`linux-rpi-legacy`](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810/core/linux-rpi-legacy) - `armv6h`
		- `raspberrypi-bootloader` - `any`

**Cross compile**:
- [Distcc](https://github.com/rern/rern.github.io/blob/main/cross-compile.md#distcc)
- [Docker](https://github.com/rern/rern.github.io/blob/main/cross-compile.md#docker)

**Custom packages**
- [bluez-alsa](https://github.com/Arkq/bluez-alsa/tags)
- [camilladsp](https://github.com/HEnquist/camilladsp), [pycamilladsp-plot](https://github.com/HEnquist/pycamilladsp-plot)
- [cava](https://github.com/karlstav/cava)
- [mediamtx](https://github.com/aler9/mediamtx)
- [mpd_oled](https://github.com/antiprism/mpd_oled/tags)
- [snapcast](https://github.com/badaix/snapcast)
- [upmpdcli](https://www.lesbonscomptes.com/upmpdcli/downloads/?C=N;O=D)

**JS plugins**
- [d3](https://github.com/d3/d3) (CDN: https://cdnjs.com/libraries/d3)
- [html5kellycolorpicker](https://github.com/NC22/HTML5-Color-Picker)
- [jquery](https://jquery.com/)
- [lazysizes](https://github.com/aFarkas/lazysizes)
- [pica](https://github.com/nodeca/pica/tags)
- [Plotly](https://github.com/plotly/plotly.js)
- [qrcode](https://github.com/datalog/qrcode-svg)
- [roundslider](https://github.com/soundar24/roundSlider)
- [Select2](https://github.com/select2/select2)
- [simple-keyboard](https://github.com/hodgef/simple-keyboard/blob/master/build/index.modern.js) (Remove sourcemap - last line: //# sourceMappingURL=index.modern.js.map)
- [Sortable](https://github.com/SortableJS/Sortable) (CDN: https://cdnjs.com/libraries/Sortable)
