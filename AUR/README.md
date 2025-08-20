AUR Package Repo
---

### AUR setup
```sh
# as root
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/aursetup.sh )
```

### Git commands
```sh
su alarm
cd

# clone existing / init new
git clone ssh://aur@aur.archlinux.org/pkg_name

cd pkg_name

# checksum (skip: sha256sums=(SKIP [SKIP ...])
makepkg -g
# Copy sha256sums=... to PKGBUILD

# ready
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO [other_file ...]
git commit -m 'commit description'
git push
```
