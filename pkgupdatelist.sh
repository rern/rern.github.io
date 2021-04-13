#!/bin/bash

for pkg in bluez-alsa fakepkg hfsprogs matchbox-window-manager mpdscribble snapcast upmpdcli; do
	version=$( curl -L https://aur.archlinux.org/packages/$pkg \
				| grep 'Package Details:' \
				| sed 's/.*h2>\(.*\)<.*/\1/' \
				| cut -d' ' -f4 )
	existing=$( pacman -Q ${pkg/-git} | cut -d' ' -f2 )
	[[ $version != $existing ]] && echo $pkg $existing --- $version
done
