#!/bin/bash
echo Tony\'s Arch Linux Installer Script.
mkfs.ext4 -F /dev/nvme0n1p4
mkswap /dev/nvme0n1p5
swapon /dev/nvme0n1p5
mkfs.f2fs -f /dev/nvme0n1p6
mount /dev/nvme0n1p6 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p4 /mnt/boot
pacstrap /mnt base terminus-font f2fs-tools 
rm /mnt/etc/fstab && genfstab -U -p /mnt/ >> /mnt/etc/fstab
cp ./local.conf /mnt/etc/fonts/local.conf
rm /mnt/etc/pacman.conf
cp /etc/pacman.conf /mnt/etc/pacman.conf

#filezilla libreoffice-fresh \
#ttf-dejavu ttf-droid ttf-fira-mono ttf-fira-sans ttf-liberation ttf-linux-libertine-g ttf-oxygen ttf-tlwg ttf-ubuntu-font-family \
# grub efibootmgr dosfstools os-prober mtools terminus-font f2fs-tools bash-completion \
# xorg-server xorg-xinit xorg-apps mesa nvidia \
# xorg-twm xterm xorg-xclock \
# xf86-input-synaptics \
# cinnamon nemo-fileroller \
#firefox vlc flashplugin gedit gnome-terminal gnome-screenshot \
# pulseaudio pulseaudio-alsa pavucontrol chromium unzip unrar p7zip pidgin deluge smplayer audacious qmmp gimp xfburn gnome-system-monitor \
# a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-plugins-base \
# gst-plugins-good \
# gst-plugins-ugly \
# faenza-icon-theme \
# libgtop networkmanager \
# git go \
# ttf-dejavu \
#freetype2

###############################
#### Configure base system ####
###############################
arch-chroot /mnt /bin/bash <<EOF

# Terminal fonts that make sense on this machine.
{
    echo FONT=ter-132n
    echo FONT_MAP=8859-2
} > /etc/vconsole.conf

pacman --noconfirm -Sy --needed base-devel \
intel-ucode openssh git bash-completion reflector python \
grub efibootmgr os-prober mtools \
ttf-dejavu ttf-liberation noto-fonts \
xf86-video-intel mesa-libgl libva-intel-driver libva \
xorg-server xorg-xinit xorg-apps xorg-xrandr \
xorg-xbacklight xbindkeys xorg-xinput xorg-twm xorg-xclock xterm xdotool \
xf86-input-synaptics \
lightdm lightdm-gtk-greeter \
cinnamon \
freetype2 \
zip unzip unrar p7zip lzop cpio zziplib \
alsa-utils alsa-plugins \
pulseaudio pulseaudio-alsa \
ntfs-3g dosfstools f2fs-tools fuse fuse-exfat autofs mtpfs \
chromium firefox gedit xfce4-terminal \
go \
jdk8-openjdk \
eclipse-cpp \
meld \
atom \
transmission-gtk \
docker \
gimp

# Setting and generating locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Configure timezone
ln -sfn /usr/share/zoneinfo/America/New_York /etc/localtime

# Configure hardware clock.
hwclock --systohc --utc

# Set hostname.
echo precision5530 > /etc/hostname

# Configure hosts
echo "" >> /etc/hosts
echo '127.0.0.1       precision5530.localdomain localhost precision5530' >> /etc/hosts
echo '::1             precision5530.localdomain localhost precision5530' >> /etc/hosts
echo '127.0.1.1       precision5530.localdomain localhost precision5530' >> /etc/hosts

echo "Installing wifi packages"
pacman --noconfirm -S iw wpa_supplicant dialog wpa_actiond
echo "Generating initramfs"
sed -i 's/^HOOKS.*/HOOKS="base udev autodetect modconf block consolefont encrypt lvm2 filesystems keyboard fsck"/' /etc/mkinitcpio.conf
mkinitcpio -p linux
echo "Setting root password"
echo "root:baloney1" | chpasswd
mkdir /boot/EFI
mount /dev/nvme0n1p1 /boot/EFI  #Mount FAT32 EFI partition 
rm /boot/grub/grub.cfg
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
grub-mkfont --output=/boot/grub/fonts/DejaVuSansMono24.pf2 --size=24 /usr/share/fonts/TTF/DejaVuSansMono.ttf
echo "GRUB_FONT=/boot/grub/fonts/DejaVuSansMono24.pf2" >> /etc/default/grub 
grub-mkconfig -o /boot/grub/grub.cfg

# fonts 
ln -sfn /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
ln -sfn /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -sfn /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

#Enable FreeType subpixel hinting mode
chmod +x /etc/profile.d/freetype2.sh
/etc/profile.d/freetype2.sh

export FREETYPE_PROPERTIES="truetype:interpreter-version=40"

# ADD NEW USER
useradd -m -g users -G wheel,lp,rfkill,sys,storage,power,audio,disk,input,kvm,video,scanner -s /bin/bash tdestro -c "Tony Destro"
echo "tdestro:baloney1" | chpasswd

# CONFIGURE SUDOERS
sed -i '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers
echo "" >> /etc/sudoers
echo 'Defaults !requiretty, !tty_tickets, !umask' >> /etc/sudoers
echo 'Defaults visiblepw, path_info, insults, lecture=always' >> /etc/sudoers
echo 'Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth' >> /etc/sudoers
echo 'Defaults passwd_tries=3, passwd_timeout=1' >> /etc/sudoers
echo 'Defaults env_reset, always_set_home, set_home, set_logname' >> /etc/sudoers
echo 'Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"' >> /etc/sudoers
echo 'Defaults timestamp_timeout=15' >> /etc/sudoers
echo 'Defaults passprompt="[sudo] password for %u: "' >> /etc/sudoers
echo 'Defaults lecture=never' >> /etc/sudoers
git config --global user.name "Tony Destro" && git config --global user.email "tony.destro@gmail.com"
git config --global credential.helper cache store

# Configure systemd-timesyncd
sed -i -e 's/^#NTP=.*/NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org/' /etc/systemd/timesyncd.conf
sed -i -e 's/^#FallbackNTP=.*/FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd.service
timedatectl set-ntp true

# Save current map, keycode 66 is where Caps lock lies
xmodmap -pke > ~/.Xmodmap.bak

# add following content to ~/.Xmodmap:
echo "clear lock" >> /home/tdestro/.Xmodmap
echo "keycode 66 = Control_L" >> /home/tdestro/.Xmodmap
echo "add control = Control_L Control_R" >> /home/tdestro/.Xmodmap

# We're using lightdm, no need to source that file.
# make it work in current session
xmodmap ~/.Xmodmap

systemctl enable lightdm.service
systemctl enable dhcpcd

su tdestro -c 'cd ~; git clone https://aur.archlinux.org/yay.git; cd ~/yay; makepkg -s' 
pacman -U /home/tdestro/yay/*.tar.gz
#rm -rf /home/tdestro/yay 
yay -S jetbrains-toolbox


EOF
