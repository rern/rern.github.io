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
- Might need swap partition
	- RPi Zero, 1: `gcc`, `python-upnpp`, `snapcast`, `upmpdcli`
	- RPI 2, 3: `snapcast`
	- on PC
		- Gparted > Resize > Create 4GB `linux-swap` partition
    	- `fstab`:
		   	```sh
		    fstab=/run/media/x/ROOT/etc/fstab
		 	swap=$( sed -n '1 {s/01 .* vfat/03  swap   swap/; p}' $fstab )
			echo "$swap" >> $fstab
			```

**Arch Linux Arm Repo**:
- Current - http://mirror.archlinuxarm.org
- Archives
	- http://tardis.tiny-vps.com/aarm/repos

**Arch Linux Arm Sources**:
- `PKGBUILD` - https://github.com/archlinuxarm/PKGBUILDs
	- Not found: Go to: https://archlinux.org > Package search > Source Files
   	- Archives for `linux-rpi-legacy`: [PKGBUILDs](https://github.com/archlinuxarm/PKGBUILDs/tree/4a2735c88645cf21e6817b6a32902f0528a60887)
- Obsolete ARMv6
	- `/etc/pacman.d/mirrorlist`:
		```sh
  		# updated packages for arch 'any' (armv6h will not be available)
  		Server = http://mirror.archlinuxarm.org/armv7h/$repo
  
  		# archive - mirror.archlinuxarm.org must be commented/removed
		Server = http://alaa.ad24.cz/repos/2022/02/06/$arch/$repo
		```
	- Alternative archive: [http://tardis.tiny-vps.com/aarm/repos/2022/01/08/armv6h]([http://tardis.tiny-vps.co](http://tardis.tiny-vps.com/aarm/repos/2022/01/08/armv6h)m)
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
- [python-upnpp](https://www.lesbonscomptes.com/upmpdcli/downloads/)
- [mediamtx](https://github.com/aler9/mediamtx)
- [mpd_oled](https://github.com/antiprism/mpd_oled/tags)
- [snapcast](https://github.com/badaix/snapcast)

**JS plugins**
- [jquery](https://jquery.com/) (CDN: https://cdnjs.com/libraries/jquery)
- [pica](https://github.com/nodeca/pica/tags) (CDN: https://cdnjs.com/libraries/pica)
- [Plotly](https://github.com/plotly/plotly.js) (CDN: https://cdnjs.com/libraries/plotly.js)
- [qrcode](https://github.com/datalog/qrcode-svg)
