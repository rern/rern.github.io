NGINX Upgrade with pushstream
---
- RuneAudio needs NGINx with **pushstream**
- **pushstream** is not available as a separated package

### compile
```sh
# compare version
pacman -Q nginx | cut -d' ' -f2
curl -s https://archlinuxarm.org/packages/aarch64/nginx-mainline | grep h1 | sed 's/.*mainline \(.*\)<.*/\1/'

pacman -Syu
pacman -S --needed base-devel geoip mailcap

# setup distcc
systemctl start distccd

su alarm
cd
mkdir nginx
cd nginx

# get build scripts
for file in PKGBUILD logrotate service; do
    wget --show-progress https://github.com/archlinux/svntogit-community/raw/packages/nginx-mainline/trunk/$file
done

# customize
pushstreamver=$( curl -s https://api.github.com/repos/wandenberg/nginx-push-stream-module/tags | grep -m 1 '"name":' | cut -d\" -f4 )
sed -i -e 's/^\(pkgname=\).*/\1nginx-mainline-pushstream/
' -e "/^pkgver/ a\
pushstreamver=$pushstreamver
" -e 's/\(package_nginx-mainline\)()/\1-pushstream()/
' -e '/^install/ d
' -e '/^source/ a\
        https://github.com/wandenberg/nginx-push-stream-module/archive/$pushstreamver.tar.gz
' -e '/--with-threads/ a\
  --add-module=/home/alarm/nginx/src/nginx-push-stream-module-$pushstreamver
' PKGBUILD

makepkg -A --skipinteg
```
