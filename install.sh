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
xorg-server xorg-xinit xorg-apps \
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
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# Configure systemd-timesyncd
sed -i -e 's/^#NTP=.*/NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org/' /etc/systemd/timesyncd.conf
sed -i -e 's/^#FallbackNTP=.*/FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd.service
timedatectl set-ntp true

# Configure hardware clock.
hwclock --systohc --utc

# Set hostname.
echo precision5530 > /etc/hostname

# Configure hosts
echo "" >> /etc/hosts
echo '127.0.0.1       precision5530.localdomain localhost precision5530' >> /etc/hosts
echo '::1             precision5530.localdomain localhost precision5530' >> /etc/hosts
echo '127.0.1.1       precision5530.localdomain localhost precision5530' >> /etc/hosts

# CONFIGURE MULTILIB
sed -i '/^#\[multilib\]/s/^#//' /etc/pacman.conf
sed -i "$(( `grep -n "^\[multilib\]" /etc/pacman.conf | cut -f1 -d:` + 1 ))s/^#//" /etc/pacman.conf



EOF
