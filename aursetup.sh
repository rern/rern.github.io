#!/bin/bash

#........................
banner AUR Setup
dirhome=/home/alarm
dirgit=$dirhome/.config/git
dirssh=$dirhome/.ssh
if [[ -e $dirssh/aur ]]; then
#........................
	dialog $opt_yesno '
AUR Git has already setup.

\Z1Continue?\Z0

' 0 0 || exit
#----------------------------------------------------------------------------
fi
echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config
systemctl restart sshd
[[ -e /usr/bin/git ]] || pacman -Sy --noconfirm git
#........................
key=$( dialogMenu 'Raspberry Pi' "\
Use existing keys
Generate new keys" )
if [[ $key == 1 ]]; then
#........................
	dialog $opt_msg '
 Copy saved \Z1.ssh/{aur,aur.pub}\Z0 > $dirhome
 Then press OK to continue.
' 7 58
else
	mkdir -p $dirssh
	ssh-keygen -t rsa -f $dirssh/aur -q -N ""
	sed -i 's/= .*$/=/' $dirssh/aur.pub # remove trailing USER@HOSTNAME
#........................
	dialog $opt_msg "
AUR > My Account

\Z1SSH Public Key:\Z0
$( cat $dirssh/aur.pub )

\Z1PGP Key Fingerprint:\Z0 (empty)
\Z1Your current password:\Z0 (password)
" 24 58
fi
#........................
email=$( dialog $opt_input '
 \Z1Email:\Z0
' 0 0 rernrern@gmail.com )
#........................
username=$( dialog $opt_input '
 \Z1Username:\Z0
' 0 0 rern )
echo "\
[user]
	email = $email
	name = $username
" > $dirhome/.gitconfig
mkdir -p $dirgit
touch $dirgit/{attributes,ignore}
chown -R alarm:alarm $dirhome
chmod 700 $dirssh
chmod 600 $dirssh/*
sudo -u alarm git init $dirhome
echo -e "
$bar Done
"
