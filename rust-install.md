Rust custom install
---

- Install with script from: https://www.rust-lang.org/tools/install

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

- Switch TOOLCHAIN: `stable`/`beta`/`nightly`
```sh
rustup default TOOLCHAIN
```
