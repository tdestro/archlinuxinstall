#!/bin/bash
timedatectl set-ntp true
git config --global user.email "tony.destro@gmail.com"
git config --global user.name "Tony Destro"
sed -i '/^#\[multilib\]/s/^#//' /etc/pacman.conf
sed -i "$(( `grep -n "^\[multilib\]" /etc/pacman.conf | cut -f1 -d:` + 1 ))s/^#//" /etc/pacman.conf
#echo "Server = http://mirrors.advancedhosters.com/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
#echo "Server = http://mirror.cs.pitt.edu/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
#echo "Server = http://arch.mirrors.pair.com/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
#echo "Server = http://mirror.vtti.vt.edu/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
#echo "Server = http://mirror.csclub.uwaterloo.ca/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
pacman --noconfirm -Sy --refresh terminus-font f2fs-tools
setfont ter-132n
