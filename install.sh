#!/bin/bash
echo Tony\'s Arch Linux Installer Script.
timedatectl set-ntp true
pacman --noconfirm --sync --refresh terminus-font f2fs-tools
setfont ter-132n
mkfs.ext4 -f /dev/nvme0n1p4
mkswap /dev/nvme0n1p5
swapon /dev/nvme0n1p5
mkfs.f2fs -f /dev/nvme0n1p6
mount /dev/nvme0n1p6 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p4 /mnt/boot
