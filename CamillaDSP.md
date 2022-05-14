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
	- Type `2` for `Customize installation`
	- `Default host triple?` - `[Enter]` for default
	- `Default toolchain?` - Type `beta`
	- `Profile (which tools and data to install)?` - `[Enter]` for default
	- `Modify PATH variable?` - `[Enter]` for `Y`
	- `[Enter]` to start install
	- Exit terminal and restart to activate new `PATH`
- `camillagui-backend` - GUI
- `python-pycamilladsp` - GUI
- `python-pycamilladsp-plot` - GUI

### Build GUI frontend
- `camillagui` - requires `React` (minimum 2GB RAM - only RPi 4 has more than 1GB)
	```sh
	su
	cd
	pacman -Sy --needed npm
	curl -L https://github.com/rern/camillagui/archive/refs/tags/1.0.0.tar.gz | bsdtar xf -
	cd camillagui-1.0.0
	npm install reactjs
	npm audit fix --force
	npm run build
	```
