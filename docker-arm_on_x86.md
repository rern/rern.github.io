### ARM Docker containers on x86_64 Linux
```sh
pacman -S docker
meson

su USER

# glib2-static
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/glib2-static.tar.gz | bsdtar xf -
cd glib2-static
makepkg -A

su
pacman -U glib2-static*

# pcre-static
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/pcre-static.tar.gz
cd pcre-static
makepkg -A

su
pacman -U pcre-static*

# qemu-user-static
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/qemu-user-static.tar.gz
cd qemu-user-static
makepkg -A

su
pacman -U qemu-user-static*

# binfmt-qemu-static
cd
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/binfmt-qemu-static.tar.gz
cd binfmt-qemu-static
makepkg -A

su
pacman -U binfmt-qemu-static*

echo "\
{ 
    "experimental": true 
}
" >> /etc/docker/daemon.json

systemctl start docker
```
