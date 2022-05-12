React - Build `camillagui`
---
Require minimum 2GB RAM (Only RPi 4 has more than 1GB)
- Install
```sh
curl -L https://github.com/HEnquist/camillagui/archive/refs/tags/v1.0.0.tar.gz | bsdtar xf -
cd camillagui-1.0.0
pacman -Sy npm
npm install reactjs # or symlink from another directory
```


- Build
	- Edit
	- Build: `npm run build`
	- Result files in `build` directory
