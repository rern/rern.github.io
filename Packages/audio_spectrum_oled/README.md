**audio_spectrum_oled** - MPD OLED Spectrum Display

Source: [mpd_oled](https://github.com/antiprism/mpd_oled)
```sh
pacman -Syu
pacman -S --needed base-devel

su alarm
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/audio_spectrum_oled.tar.gz | bsdtar xf -
cd audio_spectrum_oled
makepkg
```

`/boot/config.txt`
```sh
...
dtparam=i2c_arm=on
dtparam=i2c_arm_baudrate=1200000

# spi
dtparam=spi=on
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

- `/etc/modules-load.d/raspberrypi.conf` (no for SPI)
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
