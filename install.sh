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
pacstrap /mnt base base-devel grub efibootmgr dosfstools os-prober mtools f2fs-tools bash-completion \
xorg-server xorg-xinit xorg-utils xorg-server-utils mesa xorg-twm xterm xorg-xclock xf86-input-synaptics cinnamon nemo-fileroller gdm \
pulseaudio pulseaudio-alsa pavucontrol gnome-terminal firefox flashplugin vlc chromium unzip unrar p7zip pidgin skype deluge smplayer audacious qmmp gimp xfburn thunderbird gedit gnome-system-monitor \
a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gstreamer0.10-plugins \
yaourt \
Faenza-icon-theme numix-themes \
libgtop networkmanager \
git go \
nvidia
genfstab -U /mnt > /mnt/etc/fstab

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
mkdir /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI  #Mount FAT32 EFI partition 
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkfont --output=/boot/grub/fonts/DejaVuSansMono20.pf2 \ --size=20 /usr/share/fonts/TTF/dejavu/DejaVuSansMono.ttf
echo "GRUB_FONT=/boot/grub/fonts/DejaVuSansMono18.pf2" >> /etc/default/grub 
update-grub
EOF
