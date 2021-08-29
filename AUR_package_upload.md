AUR Package Upload
---

- Generate SSH key:
```sh
echo '\
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
' >> /etc/ssh/ssh_config

systemctl restart sshd

ssh-keygen -f ~/.ssh/aur
```

- Login > My Account > SSH Public Key: Content of `~/.ssh/aur.pub` without last ` USER@HOSTNAME`

- Create new repo:
```sh
git clone ssh://aur@aur.archlinux.org/PKGBASEDIR.git
git init
git remote add LABEL ssh://aur@aur.archlinux.org/PKGBASEDIR.git
git fetch LABEL
git config --global user.email "EMAIL@DOMAIN"
git config --global user.name "NAME"
```

- Replace `PKGBUILD` template content with actual one

- Update package metadata ` makepkg --printsrcinfo > .SRCINFO`

- Upload:
```sh
git add PKGBUILD .SRCINFO
git commit -m "COMMIT MESSAGE"
git push
```
