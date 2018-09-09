#!/bin/bash
timedatectl set-ntp true
pacman --noconfirm --sync --refresh terminus-font f2fs-tools
setfont ter-132n
git config --global user.email "tony.destro@gmail.com"
git config --global user.name "Tony Destro"
sed -i '/^#\[multilib\]/s/^#//' /etc/pacman.conf
sed -i "$(( `grep -n "^\[multilib\]" /etc/pacman.conf | cut -f1 -d:` + 1 ))s/^#//" /etc/pacman.conf
echo "Server = http://mirror.cs.pitt.edu/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
pacman -Syyu
