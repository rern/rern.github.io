### GitHub Desktop
```sh
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/github-desktop.tar.gz | bsdtar xf -
cd github-desktop

# get latest version: https://github.com/shiftkey/desktop/releases
nano PKGBUILD

makepkg -A --skipinteg
```
