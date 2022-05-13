`camillagui`
---

### Backend - Python
- Install
```sh
dircamillagui=/srv/http/settings/camillagui
mkdir -p $dircamillagui
curl -L https://github.com/HEnquist/camillagui-backend/archive/refs/tags/v1.0.0-rc2.tar.gz | bsdtar xf - --strip=1 -C $dircamillagui
rm -rf $dircamillagui/{.*,*.md,*.txt} 2> /dev/null
```

### Frontend - React
Require minimum 2GB RAM (Only RPi 4 has more than 1GB)
- Install
```sh
curl -L https://github.com/HEnquist/camillagui/archive/refs/tags/v1.0.0.tar.gz | bsdtar xf -
cd camillagui-1.0.0
pacman -Sy npm
npm install reactjs
npm audit fix --force
```
- Build
	- Edit
	- Build: `npm run build`
	- Deploy: `cp -rf build $dircamillagui`
