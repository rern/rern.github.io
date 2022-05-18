CamillaDSP
---

### Build package
```sh
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/pkgbuild.sh )
```
- `camilladsp` - Binary - requires `Rust >= 1.61`:
	```sh
	su alarm
	cd
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain beta
	```
	- Restart terminal to activate new `PATH`
- `camillagui-backend` - GUI
- `python-pycamilladsp` - GUI
- `python-pycamilladsp-plot` - GUI

### Build GUI frontend
- `camillagui` - requires `React` (minimum 2GB RAM - only RPi 4 has more than 1GB)
	```sh
	su
	cd
	pacman -Sy --needed --noconfirm  npm
	curl -L https://github.com/rern/camillagui/archive/refs/tags/1.0.0.tar.gz | bsdtar xf -
	cd camillagui-1.0.0
	npm install reactjs
	# fix vulnerables
	npm audit fix --force
	# restore versioned dependency tree
	wget https://github.com/HEnquist/camillagui/raw/master/package-lock.json -O package-lock.json
	# build
	npm run build
	```
	- Unminified codes: Developer tools > `URL:5000` > `gui` > `static`

- Get audio hardware parameters (RPi on-board audio - sample format: S16LE)
```sh
# while playing - get from loopback cardN/pcmNp
card=$( aplay -l | grep 'Loopback.*device 0' | sed 's/card \(.\): .*/\1/' )
grep -r ^format: /proc/asound/card$card/pcm${card}p | sed 's|.*/\(card.\).*:\(format.*\)|\1 \2|'
```
