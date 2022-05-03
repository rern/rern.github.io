Rust install
---
- Install with script from: https://www.rust-lang.org/tools/install
	- Select custom install for `beta`/`nightly`
	- Exit terminal and restart to activate new `PATH`
```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- Switch default TOOLCHAIN: `stable`/`beta`/`nightly`
```sh
rustup default TOOLCHAIN
```
