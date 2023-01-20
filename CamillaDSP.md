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
- Modify for `PKGBUILD`:
```sh
sed -i 's/5000/5005/' ./src/setupProxy.js
sed -i 's/"build")$/"build", follow_symlinks=True)/' $installdir/backend/routes.py
sed -i -e '/cdsp.get_volume/ a\
    elif name == "mute":\
        config = cdsp.get_config()\
        mute = True if cdsp.get_mute() else False\
        volume = cdsp.get_volume()\
        result = {"config": config, "mute": mute, "volume": volume}\
        return web.json_response(result)\
        
' -e '/cdsp.set_volume/ a\
    elif name == "mute":\
        cdsp.set_mute(value == "true")
' $installdir/backend/views.py
```

### Setup Loopback
- on **rAudio**: Features > enable DSP
```sh
echo '
pcm.!default { 
	type plug 
	slave.pcm camilladsp
}
pcm.camilladsp {
	type plug
	slave {
		pcm {
			type     hw
			card     Loopback
			device   0
			channels 2
			format   S32LE
			rate     44100
		}
	}
}
ctl.!default {
	type hw
	card Loopback
}
ctl.camilladsp {
	type hw
	card Loopback
}' >> /etc/asound.conf
```
### Build GUI frontend
- Install `camilladsp`, `camillagui-backend` (on **rAudio**: already installed)
- `camillagui` - Frontend requires `React` (minimum 2GB RAM - only RPi 4 has more than 1GB)
```sh
su
cd
pacman -Sy --needed --noconfirm npm

curl -L https://github.com/rern/camillagui/archive/refs/tags/RELEASE.tar.gz | bsdtar xf -

cd camillagui-RELEASE
npm install reactjs

ln -s /srv/http/assets public/static
chmod +x postbuild.sh
```
	
- Development server
```sh
systemctl start camilladsp camillagui

npm start

> Starting the development server...
# (wait for compiling ...)
> Compiled successfully!
# You can now view camillagui in the browser.
# Local:            http://localhost:3000
# On Your Network:  http://192.168.1.4:3000
```
- On browser: http://192.168.1.4:3000
- Any changes to files recompile and refresh browser immediately
- `public/...` for custom css, font-face, js, image
	- img: `src="%PUBLIC_URL%/assets/img/camillagui.svg"`
	- css:
		- `<link rel="stylesheet" href="%PUBLIC_URL%/assets/css/camillagui.css">` - after `#root` to force after `main.css`
		- @font-face: `../fonts/rern.woff2` - relative path
	- js: `<script defer="defer" src="%PUBLIC_URL%/assets/js/camillagui.js"></script>`
	
- Build
	- `npm run build`
	- Deployment files: `./build` (copied to `/srv/http/settings/camillagui/build` by `postbuild.sh`)

### Tips
- Get audio hardware parameters (RPi on-board audio - `sample format: S16LE`)
```sh
# while playing - get from loopback cardN/pcmNp
card=$( aplay -l | grep 'Loopback.*device 0' | sed 's/card \(.\): .*/\1/' )
grep -r ^format: /proc/asound/card$card/pcm${card}p | sed 's|.*/\(card.\).*:\(format.*\)|\1 \2|'
```
