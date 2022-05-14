CamillaDSP
---

### Build package
	```sh
	bash <( curl -L https://github.com/rern/rern.github.io/raw/main/pkgbuild.sh )
	```
	- `camilladsp` - Binary - requires recent version of `Rust`:
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
	- `camillagui-backend` - GUI
	- `python-pycamilladsp` - GUI
	- `python-pycamilladsp-plot` - GUI

### Build GUI frontend
	- `camillagui` - requires `React` (minimum 2GB RAM - only RPi 4 has more than 1GB)
		```sh
		# forked:
		su
		cd
		curl -L https://github.com/rern/camillagui/archive/refs/tags/1.0.0.tar.gz | bsdtar xf -
		cd camillagui-1.0.0
		pacman -Sy --needed npm
		npm install reactjs
		npm audit fix --force
		npm run build
		```
