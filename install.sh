#!/bin/bash
echo Tony\'s Arch Linux Installer Script.
mkfs.ext4 /dev/nvme0n1p4
mkswap /dev/nvme0n1p5
swapon /dev/nvme0n1p5
mkfs.f2fs -f /dev/nvme0n1p6
mount /dev/nvme0n1p6 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p4 /mnt/boot
pacstrap /mnt base base-devel \
grub efibootmgr dosfstools os-prober mtools f2fs-tools intel-ucode \
terminus-font ttf-dejavu ttf-liberation noto-fonts \
xf86-video-intel mesa-libgl libva-intel-driver libva \
xorg-server xorg-xinit xorg-apps \
xf86-input-synaptics \
lightdm lightdm-gtk-greeter \
cinnamon \
freetype2 \
chromium firefox gedit xfce4-terminal \
git \
go \
jdk8-openjdk \
eclipse-cpp


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



genfstab -U /mnt > /mnt/etc/fstab

###############################
#### Configure base system ####
###############################
arch-chroot /mnt /bin/bash <<EOF
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S phpstorm clion datagrip goland rider
sed -i '/^#\[multilib\]/s/^#//' /etc/pacman.conf
sed -i "$(( `grep -n "^\[multilib\]" /etc/pacman.conf | cut -f1 -d:` + 1 ))s/^#//" /etc/pacman.conf
echo "Server = http://mirror.cs.pitt.edu/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
{
    echo FONT=ter-132n
    echo FONT_MAP=8859-2
} > /etc/vconsole.conf
echo "Setting and generating locale"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "Setting time zone"
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc --utc
echo "Setting hostname"
echo "precision5530" > /etc/hostname
sed -i "/localhost/s/$/ precision5530/" /etc/hosts
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
ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d

#Enable FreeType subpixel hinting mode
/etc/profile.d/freetype2.sh

export FREETYPE_PROPERTIES="truetype:interpreter-version=40"

{
<?xml version=\"1.0\"?>
<!DOCTYPE fontconfig SYSTEM \"fonts.dtd\">
<fontconfig>
      <match>
          <edit mode=\"prepend\" name=\"family\"><string>Noto Sans</string></edit>
      </match>
      <match target=\"pattern\">
          <test qual=\"any\" name=\"family\"><string>serif</string></test>
          <edit name=\"family\" mode=\"assign\" binding=\"same\"><string>Noto Serif</string></edit>
      </match>
      <match target=\"pattern\">
          <test qual=\"any\" name=\"family\"><string>sans-serif</string></test>
          <edit name=\"family\" mode=\"assign\" binding="same"><string>Noto Sans</string></edit>
      </match>
      <match target=\"pattern\">
          <test qual=\"any\" name=\"family\"><string>monospace</string></test>
          <edit name=\"family\" mode=\"assign\" binding=\"same\"><string>Noto Mono</string></edit>
      </match>
  </fontconfig>
} > /etc/fonts/local.conf

useradd -m -g users -G wheel,lp,rfkill,sys,storage,power,audio,disk,input,kvm,video,scanner -s /bin/bash tdestro -c "Tony Destro"
echo "tdestro:baloney1" | chpasswd
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

systemctl enable lightdm.service
systemctl enable dhcpcd
EOF
