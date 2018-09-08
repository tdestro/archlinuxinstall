#!/bin/bash
echo Tony\'s Arch Linux Installer Script.
timedatectl set-ntp true
pacman --noconfirm --sync --refresh terminus-font 
setfont ter-132n
mkswap /dev/nvme0n1p5
swapon /dev/nvme0n1p5
