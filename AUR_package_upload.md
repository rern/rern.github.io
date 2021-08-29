AUR Package Upload
---

- Generate SSH key:
```sh
echo "\
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd

su USER
ssh-keygen -f ~/.ssh/aur
```

- Login > My Account > SSH Public Key: Content of `~/.ssh/aur.pub` without last ` USER@HOSTNAME`

- Create new repo:
```sh
git clone ssh://aur@aur.archlinux.org/pkgbase.git
git init
git config --global user.email "EMAIL@DOMAIN"
git config --global user.name "NAME"
git remote add LABEL ssh://aur@aur.archlinux.org/pkgbase.git
git fetch LABEL
```

- Replace `PKGBUILD` template content with actual one

- Upload:
```sh
cd pkgbase
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "COMMIT MESSAGE"
git push
```
