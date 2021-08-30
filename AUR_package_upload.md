AUR Package Upload
---

- Prepare SSH:
```sh
echo "
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User aur
" >> /etc/ssh/ssh_config

systemctl restart sshd
```
- New keys
	```sh
	su USER
	ssh-keygen -f ~/.ssh/aur
	```
	- Login > My Account > SSH Public Key: Content of `~/.ssh/aur.pub` without last ` USER@HOSTNAME`
- Existing keys
	```sh
	chown -R alarm:alarm ~/.ssh
	chmod 600 ~/.ssh/aur
	chmod 644 ~/.ssh/aur.pub
	```

- Init git
```sh
git init
git config --global user.email "EMAIL@DOMAIN"
git config --global user.name "NAME"
```
- Add new repo
```sh
git clone ssh://aur@aur.archlinux.org/pkgbase.git
git remote add REPONAME ssh://aur@aur.archlinux.org/pkgbase.git
git fetch REPONAME
```
- Fetch existing repo
```sh
git clone ssh://aur@aur.archlinux.org/REPONAME.git
```

- Checksum source
```sh
wget https://github.com/REPO/REPONAME/archive/refs/tags/RELEASE.tar.gz
shasum -a 256 RELEASE.tar.gz

# sha256sums=( ... ) OR sha256sums=(SKIP)
```

- Push repo
```sh
cd REPONAME
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "COMMIT MESSAGE"
git push
```
