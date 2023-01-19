CamillaDSP
---

### Build binary and Python libraries
- `camilladsp` - Binary
	- Only `armv6h` - `rust` >= 1.62
	```sh
	su alarm
	cd
	curl https://sh.rustup.rs -sSf | sh
	# Restart terminal to activate new PATH
	```
- `camillagui-backend` - GUI
- `python-pycamilladsp` - GUI
- `python-pycamilladsp-plot` - GUI
- Build:
	```sh
	bash <( curl -L https://github.com/rern/rern.github.io/raw/main/pkgbuild.sh )
	```

### Build GUI backend
- `backend/routes.py`
	```sh
	...
	app.router.add_static("/gui/", path=BASEPATH / "build", follow_symlinks=True)
	...
	```
- `backend/view.py`
	```sh
	...
	    if name == "volume":
        result = cdsp.get_volume()
    elif name == "configmutevolume":
        config = cdsp.get_config()
        mute = True if cdsp.get_mute() else False
        volume = cdsp.get_volume()
        result = {"config": config, "mute": mute, "volume": volume}
        return web.json_response(result)
	...
	```
	
### Build GUI frontend
- `camillagui` - Frontend requires `React` (minimum 2GB RAM - only RPi 4 has more than 1GB)
	```sh
	su
	cd
	pacman -Sy --needed --noconfirm  npm
	curl -L https://github.com/rern/camillagui/archive/refs/tags/RELEASE.tar.gz | bsdtar xf -
	cd camillagui-RELEASE
	npm install reactjs
	# >> NO: fix vulnerables - npm audit fix
	```
	
- Development server
	```
	systemctl start camilladsp camillagui
	npm start
	
	> Starting the development server...

	> Compiled successfully!

	> You can now view camillagui in the browser.

	> Local:            http://localhost:3000
	> On Your Network:  http://192.168.1.4:3000
	```
	- Any changes to files recompile and refresh browser immediately
	- `public/...` for custom css, font-face, js, images
		- img: `src="%PUBLIC_URL%/assets/img/camillagui.svg"`
		- css:
			- `<link rel="stylesheet" href="%PUBLIC_URL%/assets/css/camillagui.css">` - after `#root` to force after `main.css`
			- @font-face: `../fonts/rern.woff2` - relative path
		- js: `<script defer="defer" src="%PUBLIC_URL%/assets/js/camillagui.js"></script>`
	
- Build
	- `npm run build`
	- Deployment files in `build` directory

### Tips
- Get audio hardware parameters (RPi on-board audio - sample format: S16LE)
```sh
# while playing - get from loopback cardN/pcmNp
card=$( aplay -l | grep 'Loopback.*device 0' | sed 's/card \(.\): .*/\1/' )
grep -r ^format: /proc/asound/card$card/pcm${card}p | sed 's|.*/\(card.\).*:\(format.*\)|\1 \2|'
```
