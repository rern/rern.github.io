**Build packages**
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/master/pkgbuild.sh )
```
**+R repo**: [rern.github.io](https://rern.github.io)

**Arch Linux Arm Repo**:
- Current - http://mirror.archlinuxarm.org
- Archives
	- http://tardis.tiny-vps.com/aarm/packages
	- http://alaa.ad24.cz/packages
	- As server `/etc/pacman.d/mirrorlist`:
		- `Server = http://tardis.tiny-vps.com/aarm/repos/2022/01/08/$arch/$repo`
		- `Server = http://alaa.ad24.cz/aarm/repos/2022/02/06/$arch/$repo`

**Arch Linux Arm Sources**:
- `PKGBUILD`s - https://github.com/archlinuxarm/PKGBUILDs
- Not in `https://github.com/archlinuxarm/PKGBUILDs`:
  - List - `https://github.com/archlinux/svntogit-community`
  - Source - `https://github.com/archlinux/svntogit-community/blob/master/PKG_NAME`
- Obsolete ARMv6
	- Last available in [GitHub history](https://github.com/archlinuxarm/PKGBUILDs/tree/5fb6d2b2e8292fb1df5c1d7a347493c9e2164810).
	- Download GitHub specific directory: https://download-directory.github.io/

**Cross compile**:
- [Distcc](https://github.com/rern/rern.github.io/blob/master/cross-compile.md#distcc)
- [Docker](https://github.com/rern/rern.github.io/blob/master/cross-compile.md#docker)

**Custom packages**
- [bluez-alsa](https://github.com/Arkq/bluez-alsa)
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
- [Sortable](https://github.com/SortableJS/Sortable)
