**C.A.V.A.** - Console-based Audio Visualizer for Alsa

Source: [cava](https://github.com/karlstav/cava)
```sh
pacman -Syu
pacman -S --needed base-devel fftw

su alarm
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/cava.tar.gz | bsdtar xf -
cd cava
makepkg
```

`/etc/cava.conf`
```sh
[general]
framerate = 4
bars = 1

[input]
method = fifo
source = /tmp/mpd.fifo

[output]
method = raw
channels = mono
mono_option = average
data_format = ascii
ascii_max_range = 40
```

`/etc/mpd.conf`
```sh
...
audio_output {
	type           "fifo"
	name           "my_fifo"
	path           "/tmp/mpd.fifo"
}
```

`vumeter.sh`
```sh
#!/bin/bash
while read vu; do
	echo ${vu:0:-1}
done
```

Run:
- Direct stdout - `cava`
- Pipe - `cava -p /etc/cava.conf | vumeter.sh &> /dev/null &`
