#!/bin/bash

for pkg in bluez-alsa-git fakepkg hfsprogs kid3-cli matchbox-window-manager mpdscribble snapcast upmpdcli; do
	version=$( curl -L "https://aur.archlinux.org/packages/?O=0&K=$pkg" \
				| grep -A1 '<td>.*upmpdcli' \
				| tail -1 \
				| sed 's/.*td>\(.*\)<.*/\1/' )
done
