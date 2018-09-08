#!/bin/bash
echo Tony\'s Arch Linux Installer Script.
timedatectl set-ntp true
pacman --noconfirm --sync --refresh terminus-font f2fs-tools
setfont ter-132n
mkfs.ext4 /dev/nvme0n1p4
mkswap /dev/nvme0n1p5
swapon /dev/nvme0n1p5
mkfs.f2fs -f /dev/nvme0n1p6
mount /dev/nvme0n1p6 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p4 /mnt/boot
pacstrap /mnt base base-devel
genfstab -U /mnt >> /mnt/etc/fstab

###############################
#### Configure base system ####
###############################
arch-chroot /mnt /bin/bash <<EOF
echo "Setting and generating locale"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "Setting time zone"
ln -s /usr/share/zoneinfo/EST /etc/localtime
echo "Setting hostname"
echo "precision5530" > /etc/hostname
sed -i "/localhost/s/$/ precision5530/" /etc/hosts
echo "Installing wifi packages"
pacman --noconfirm -S iw wpa_supplicant dialog wpa_actiond
echo "Generating initramfs"
sed -i 's/^HOOKS.*/HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"/' /etc/mkinitcpio.conf
mkinitcpio -p linux
echo "Setting root password"
echo "root:baloney1" | chpasswd
EOF
