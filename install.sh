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
 
###############################
#### Configure base system ####
###############################
arch-chroot /mnt /bin/bash <<EOF

# Terminal fonts that make sense on this machine.
{
    echo FONT=ter-132n
    echo FONT_MAP=8859-2
} > /etc/vconsole.conf

pacman -Sy --needed base-devel \
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
ntfs-3g dosfstools exfat-utils f2fs-tools fuse fuse-exfat autofs mtpfs \
chromium firefox gedit xfce4-terminal \
go \
jdk8-openjdk \
eclipse-cpp \
meld \
atom \
transmission-gtk \
docker \
gimp
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
EOF
