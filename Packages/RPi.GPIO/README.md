### Python RPi.GPIO
Source: [RPi.GPIO](https://sourceforge.net/projects/raspberry-gpio-python/)

```sh
pacman -Syu
pacman -S --needed base-devel

su alarm
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/python-raspberry-gpio.tar.gz | bsdtar xf -
cd python-raspberry-gpio

# get latest version: https://sourceforge.net/p/raspberry-gpio-python/code/commit_browser
version=VERSION
sed -i "s/\(pkgver=\).*/\1$version/" PKGBUILD

makepkg -A
```

Python
```py
import RPi.GPIO as GPIO

GPIO.setwarnings( 0 )
GPIO.setmode( GPIO.BOARD )
GPIO.setup( PIN_NO, GPIO.OUT )
# on PIN_NO
GPIO.output( PIN_NO, 1 )
# pin status
GPIO.input( PIN_NO )
# off
GPIO.output( PIN_NO, 0 )
```
