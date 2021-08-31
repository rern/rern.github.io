**mpd_oled** - MPD OLED Spectrum Display

Source: [mpd_oled](https://github.com/antiprism/mpd_oled)
```sh
pacman -Syu
pacman -S --needed base-devel

su alarm
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/mpd_oled.tar.gz | bsdtar xf -
cd mpd_oled
makepkg
```
Note:
- `makepkg` - runtime error `Assertion '__builtin_expect(__n < this->size(), true)' failed`
- `make` - no errors

- Workaround 
```sh
su alarm
cd
git clone https://github.com/rern/mpd_oled
cd mpd_oled
./bootstrap

su
make install-strip
cp /usr/local/bin/mpd_oled /home/alarm/mpd_oled

su alarm

rm -rf mpd_oled
mkdir mpd_oled

cat << EOF > /home/alarm/mpd_oled/PKGBUILD
pkgname=mpd_oled
pkgver=0.02
pkgrel=1
arch=(armv6h armv7h aarch64)
license=(MIT)
source=(https://github.com/rern/mpd_oled/archive/refs/heads/master.zip)
sha256sums=(SKIP)

package() {
	install -d "$pkgdir/usr/bin/"
	cp /usr/bin/mpd_oled "$pkgdir/usr/bin/"
}
EOF

makepkg
```

`/boot/config.txt`
```sh
...
dtparam=i2c_arm=on
dtparam=i2c_arm_baudrate=1200000
```

`/etc/mpd.conf`
```sh
...
audio_output {
     type           "fifo"
     name           "mpd_oled"
     path           "/tmp/mpd.fifo"
     buffer_time    "1000000"
}
```

- `/etc/modules-load.d/raspberrypi.conf`
```sh
...
i2c-dev
```

- `/etc/systemd/system/mpd_oled.service`
```sh
[Unit]
Description=MPD OLED Display

[Service]
Type=Idle
ExecStart=/usr/bin/mpd_oled -o 6 -b 7 -f 25 -k -c 'fifo,/tmp/mpd.fifo'

[Install]
WantedBy=multi-user.target
```
