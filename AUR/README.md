AUR Package Repo
---

### Git setup
```sh
# as root
bash <( curl -L https://github.com/rern/rern.github.io/raw/main/aursetup.sh )
su alarm
cd
git config --global core.excludesfile ~/.config/git/ignore
mkdir -p .config/git
touch .config/git/ignore
```

### Git repo
- New / Existing
```sh
git clone ssh://aur@aur.archlinux.org/REPONAME
cd REPONAME
```

### Set checksum
- Skip: `sha256sums=(SKIP [SKIP ...])`
- Set: Place/Replace stdout `makepkg -g` in `PKGBUILD`

### Push
```sh
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO [OTHER_BUILD_FILES ...]
git commit -m "MESSAGE"
git push
```
