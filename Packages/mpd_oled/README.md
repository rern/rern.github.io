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
- `make` - no runtime error

- Workaround
```sh
# after makepkg
cd
curl -L https://github.com/rern/mpd_oled/archive/refs/heads/master.zip | bsdtar xf -
cd mpd_oled-master
chmod +x bootstrap
./bootstrap

su
make install-strip

su alarm
cd
cd mpd_oled

sed '/^build/,$ d' PKGBUILD > PKGBUILD1
echo '
package() {
	install -d "$pkgdir/usr/bin/"
	cp -f /usr/bin/mpd_oled "$pkgdir/usr/bin/"
}
' >> PKGBUILD1

makepkg -p PKGBUILD1

rm /usr/bin/mpd_oled
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
