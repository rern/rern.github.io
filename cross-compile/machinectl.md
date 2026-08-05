## `machinectl` / `systemd-nspawn`

- Slightly faster than RPi 4, 5
- Much faster than RPi 3 and less

```sh
pacman -Sy --needed qemu-user-static qemu-user-static-binfmt
systemctl restart systemd-binfmt # run once

# clone rpi0 ROOT partition in usb reader
dir_sysroot=/home/x/rpi0-sysroot
mkdir -p $dir_sysroot
rsync -aAXv --info=progress2 /run/media/x/ROOT/ $dir_sysroot/
chown -R x:x $dir_sysroot
rm /etc/resolv.conf
echo nameserver 192.168.1.1 > $dir_sysroot/etc/resolv.conf
sed -i '/^auth .* pam_securetty.so/ s/^/#/' $dir_sysroot/etc/pam.d/login # allow root login

# new machine
cp -r /home/x/{rpi0,x}-sysroot
dir_machine=/var/lib/machines/rpi0
ln -s $dir_sysroot $dir_machine
systemd-nspawn -M rpi0 -D $dir_machine # set machine name

# allow: use host tmpfs(ram)
mkdir -p /etc/systemd/system/systemd-nspawn@rpi0.d/
cat << 'EOF' > /etc/systemd/system/systemd-nspawn@rpi0.d/override.conf
[Service]
DevicePolicy=closed
ExecStart=
ExecStart=systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --settings=override --machine=%I --tmpfs=/tmp --tmpfs=/root/.cache
EOF
systemctl daemon-reload

# allow networking and set env
cat << EOF > /etc/systemd/nspawn/rpi0.nspawn
[Network]
VirtualEthernet=no

[Files]
Bind=/home/x:/home/x
TemporaryFileSystem=/tmp
TemporaryFileSystem=/root/.cache

[Exec]
PrivateUsers=no
EOF

cat << 'EOF' > rpi0.sh
#!/bin/bash

rpi0Kill() {
	machinectl kill rpi0 --signal=SIGKILL &> /dev/null
	sleep 2
}

case $1 in
	boot )
		rpi0Kill
		sudo systemd-nspawn \
			-bD /var/lib/machines/rpi0 \
			--bind=/home/x:/home/x \
			--tmpfs=/tmp --tmpfs=/root/.cache
		;;
	list )  machinectl list;;
	pacman ) sudo pacman --sysroot /home/x/x-sysroot/ -U $1 --overwrite '*';;
	renew )
		rpi0Kill
		sudo rm -rf /home/x/x-sysroot
		sudo cp -r /home/x/{rpi0,x}-sysroot
		sudo chown -R x:x /home/x/x-sysroot
		mkdir -p /home/x/x-sysroot/home/x
		machinectl start rpi0
		;;
	show )  machinectl show rpi0;;
	stop | kill ) rpi0Kill;;
	* )
		[[ ! $( machinectl list --no-legend ) ]] && machinectl start rpi0 && sleep 2
		machinectl shell rpi0
		;;
esac
EOF
chmod +x rpi0.sh

# exit machinectl shell : ctrl + D
# exit systemd-nspand   : hold Ctrl and ] 3 times
```
