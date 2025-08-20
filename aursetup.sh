#!/bin/bash

dirhome=/home/alarm
dirgit=$dirhome/.config/git
dirssh=$dirhome/.ssh

optbox=( --colors --no-shadow --no-collapse )
dialog "${optbox[@]}" --infobox "

                          \Z1AUR\Z0

                       Git Setup
" 9 58
sleep 2

if [[ -e $dirssh/aur ]]; then
	dialog "${optbox[@]}" --yesno "
AUR Git has already setup.

\Z1Continue?\Z0

" 0 0
	[[ $? == 1 ]] && exit
fi

echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd

[[ -e /usr/bin/git ]] || pacman -Sy --noconfirm git

keys=$( dialog "${optbox[@]}" --output-fd 1 --nocancel --menu "
\Z1Raspberry Pi:\Z0
" 8 0 0 \
1 'Use existing keys' \
2 'Generate new keys' )

if [[ $keys == 1 ]]; then
	dialog "${optbox[@]}" --msgbox "
 Copy saved \Z1.ssh/{aur,aur.pub}\Z0 > $dirhome
 Then press OK to continue.
" 7 58
else
	mkdir -p $dirssh
	ssh-keygen -t rsa -f $dirssh/aur -q -N ""
	sed -i 's/= .*$/=/' $dirssh/aur.pub # remove trailing USER@HOSTNAME
	dialog "${optbox[@]}" --msgbox "
AUR > My Account

\Z1SSH Public Key:\Z0
$( cat $dirssh/aur.pub )

\Z1PGP Key Fingerprint:\Z0 (empty)
\Z1Your current password:\Z0 (password)
" 24 58
fi

email=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1Email:\Z0
" 0 0 rernrern@gmail.com )
username=$( dialog "${optbox[@]}" --output-fd 1 --inputbox "
 \Z1Username:\Z0
" 0 0 rern )

echo "\
[user]
	email = rernrern@gmail.com
	name = rern
" > $dirhome/.gitconfig

mkdir -p $dirgit
touch $dirgit/{attributes,ignore}
chown -R alarm:alarm $dirhome
chmod 700 $dirssh
chmod 600 $dirssh/*

sudo -u alarm git init $dirhome
