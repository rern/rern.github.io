CamillaDSP
---

### `camilladsp`
- v1.0.0 needs recent version of `Rust`
	```sh
	su alarm
	cd
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	```

	- `2) Customize installation` for `beta`/`nightly`
	- `Default host triple?` - `enter` for default
	- `Default toolchain?` - Type `stable`/`beta`/`nightly`
	- `Profile (which tools and data to install)?` - `enter` for default
	- `Modify PATH variable?` - `enter` for `Y`
	- `enter` to start install
	- Exit terminal and restart to activate new `PATH`
- Build package
	```sh
	bash <( curl -L https://github.com/rern/rern.github.io/raw/main/pkgbuild.sh )
	```
	- `camilladsp` - binary
	- `camillagui-backend` - gui
	- `python-pycamilladsp` - gui
	- `python-pycamilladsp-plot` - gui

### `camillagui`
- **Backend - Python**
- `camillagui-backend`
```sh
dircamillagui=/srv/http/settings/camillagui
mkdir -p $dircamillagui
curl -L https://github.com/HEnquist/camillagui-backend/archive/refs/tags/v1.0.0-rc2.tar.gz | bsdtar xf - --strip=1 -C $dircamillagui
rm -rf $dircamillagui/{.*,*.md,*.txt} 2> /dev/null
```

- **Frontend - React**
Require minimum 2GB RAM (Only RPi 4 has more than 1GB)
```sh
curl -L https://github.com/HEnquist/camillagui/archive/refs/tags/v1.0.0.tar.gz | bsdtar xf -
cd camillagui-1.0.0
pacman -Sy --needed npm
npm install reactjs
npm audit fix --force
```
- Build
	- Edit
	- Build: `npm run build`
	- Deploy: `cp -rf build $dircamillagui`
