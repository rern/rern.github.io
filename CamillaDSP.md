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
- `camillagui` - Frontend requires `React` (minimum 2GB RAM - only RPi 4 has more than 1GB)
	```sh
	su
	cd
	pacman -Sy --needed --noconfirm  npm
	curl -L https://github.com/rern/camillagui/archive/refs/tags/1.0.0.tar.gz | bsdtar xf -
	cd camillagui-1.0.0
	npm install reactjs
	# >> NO: fix vulnerables - npm audit fix
	```
	
- Development server
	- `npm start`
	- `Starting the development server...` > `Compiled successfully!` - get `SERVER_URL:PORT` for browser
	- Any changes recompile immediately
	- Custom CSS files:
		- Copy to `src`
		- `index.tsx` - Add `import "./NAME.css"`
	
- Build
	- `npm run build`
	- Deployment files in `build` directory
	- Unminified codes: Developer tools > `SERVER_IP_ADDRESS:5000` > `gui` > `static`

### Tips
- Get audio hardware parameters (RPi on-board audio - sample format: S16LE)
```sh
# while playing - get from loopback cardN/pcmNp
card=$( aplay -l | grep 'Loopback.*device 0' | sed 's/card \(.\): .*/\1/' )
grep -r ^format: /proc/asound/card$card/pcm${card}p | sed 's|.*/\(card.\).*:\(format.*\)|\1 \2|'
```
