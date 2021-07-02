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

`/root/.config/cava/config`
```sh
[general]
framerate = 30
autosens = 1
bars = 1

[input]
method = fifo
source = /tmp/mpd.fifo
sample_rate = 44100
sample_bits = 16

[output]
method = raw
channels = mono
mono_option = average
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
```

`/etc/mpd.conf`
```sh
...
audio_output {
	type           "fifo"
	name           "my_fifo"
	path           "/tmp/mpd.fifo"
	format         "44100:16:2"
}
```

Run: `cava`
