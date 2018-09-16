#!/bin/bash
echo Tony\'s Arch Linux Installer Script.

exit_on_error() {
    exit_code=$1
    last_command=${@:2}
    if [ $exit_code -ne 0 ]; then
        >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
        exit $exit_code
    fi
}

# enable !! command completion
set -o history -o histexpand

# ensure drives are unmounted, even if it's stupid.
umount -l /dev/nvme0n1p4 || [ $? -eq 1 ]
swapoff /dev/nvme0n1p5 || [ $? -eq 1 ]
umount -l /dev/nvme0n1p5 || [ $? -eq 1 ]
umount -l /dev/nvme0n1p6 || [ $? -eq 1 ]

mkfs.ext4 -F /dev/nvme0n1p4
exit_on_error $? !!
mkswap -f /dev/nvme0n1p5
exit_on_error $? !!
swapon /dev/nvme0n1p5
exit_on_error $? !!
mkfs.f2fs -f /dev/nvme0n1p6
exit_on_error $? !!
mount /dev/nvme0n1p6 /mnt
exit_on_error $? !!
mkdir /mnt/boot
exit_on_error $? !!
mount /dev/nvme0n1p4 /mnt/boot
exit_on_error $? !!
pacstrap /mnt base terminus-font f2fs-tools
exit_on_error $? !!
rm /mnt/etc/fstab
exit_on_error $? !!
genfstab -U -p /mnt/ >> /mnt/etc/fstab
exit_on_error $? !!
rm /mnt/etc/pacman.conf
exit_on_error $? !!
cp /etc/pacman.conf /mnt/etc/pacman.conf
exit_on_error $? !!
cp ./wlp59s0-dd-wrt /mnt/etc/netctl/wlp59s0-dd-wrt
exit_on_error $? !!
cp ./undervolt.timer /mnt/etc/systemd/system/undervolt.timer
exit_on_error $? !!
cp ./undervolt.service /mnt/etc/systemd/system/undervolt.service
exit_on_error $? !!
cp ./cinnamon_settings /mnt/cinnamon_settings
exit_on_error $? !!

#xinput set-prop 14 145 2.400000, 0.000000, 0.000000, 0.000000, 2.400000, 0.000000, 0.000000, 0.000000, 1.000000

###############################
#### Configure base system ####
###############################
arch-chroot /mnt /bin/bash <<EOF
pacman --noconfirm -Sy --needed base-devel \
intel-ucode openssh git bash-completion reflector python \
grub efibootmgr os-prober mtools \
ttf-dejavu ttf-liberation noto-fonts \
xf86-video-intel mesa-libgl libva-intel-driver libva \
xorg-server xorg-xinit xorg-apps \
xterm \
xf86-input-libinput xf86-video-modesetting xf86-video-vesa xf86-video-fbdev \
lightdm accountsservice \
freetype2 \
zip unzip unrar p7zip lzop cpio zziplib \
alsa-utils alsa-plugins \
pulseaudio pulseaudio-alsa qmmp \
ntfs-3g dosfstools f2fs-tools fuse fuse-exfat autofs mtpfs \
chromium firefox flashplugin gedit xfce4-terminal \
cinnamon variety \
go \
gvim \
jdk8-openjdk \
eclipse-cpp \
meld \
atom \
deluge \
docker \
gimp \
librsvg redshift \
steam \
vlc \
virtualbox virtualbox-guest-iso \
powertop \
python-pip \
filezilla libreoffice-fresh \
cups cups-pdf system-config-printer gutenprint ghostscript gsfonts foomatic-db foomatic-db-engine foomatic-db-nonfree foomatic-db-ppds foomatic-db-nonfree-ppds \
nfs-utils samba smbnetfs \
xfburn \
wine \
gparted \
borg \
nvidia bumblebee primus bbswitch
EOF

cp ./30-touchpad.conf /mnt/etc/X11/xorg.conf.d/30-touchpad.conf 
exit_on_error $? !!
cp ./10-monitor.conf /mnt/etc/X11/xorg.conf.d/10-monitor.conf
exit_on_error $? !!
cp ./Xresources /mnt/home/tdestro/.Xresources
exit_on_error $? !!

arch-chroot /mnt /bin/bash <<EOF
# Terminal fonts that make sense on this machine.
{
    echo FONT=ter-132n
    echo FONT_MAP=8859-2
} > /etc/vconsole.conf


{
    echo [Unit]
    echo Description=Powertop tunings
    echo 
    echo [Service]
    echo Type=oneshot
    echo ExecStart=/usr/bin/powertop --auto-tune
    echo 
    echo [Install]
    echo WantedBy=multi-user.target
} > /etc/systemd/system/powertop.service 


echo "vboxdrv" >> /etc/modules-load.d/virtualbox.conf

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

# lightdm fonts
#sed -i 's/#xft-dpi.*/xft-dpi=282/' /etc/lightdm/lightdm-gtk-greeter.conf;
sed -i 's/#xserver-command.*/xserver-command=X -dpi 282.24/' /etc/lightdm/lightdm.conf


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
usermod -aG vboxusers tdestro

# Configure systemd-timesyncd
sed -i -e 's/^#NTP=.*/NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org/' /etc/systemd/timesyncd.conf
sed -i -e 's/^#FallbackNTP=.*/FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd.service
timedatectl set-ntp true

# add following content to ~/.Xmodmap:
echo "clear lock" >> /home/tdestro/.Xmodmap
echo "keycode 66 = Control_L" >> /home/tdestro/.Xmodmap
echo "add control = Control_L Control_R" >> /home/tdestro/.Xmodmap

# Allow redshift to access location
su tdestro -c 'mkdir /home/tdestro/.config /home/tdestro/.config/redshift'
su tdestro -c 'echo [redshift] > /home/tdestro/.config/redshift/redshift.conf'
su tdestro -c 'echo location-provider=manual >> /home/tdestro/.config/redshift/redshift.conf'
su tdestro -c 'echo [manual] >>/home/tdestro/.config/redshift/redshift.conf'
su tdestro -c 'echo lon=-79.995888 >> /home/tdestro/.config/redshift/redshift.conf'
su tdestro -c 'echo lat=40.4417 >> /home/tdestro/.config/redshift/redshift.conf'


systemctl enable lightdm.service
systemctl enable dhcpcd
systemctl enable netctl-auto@wlp59s0.service
systemctl enable powertop.service
systemctl enable bumblebeed.service
systemctl enable org.cups.cupsd.service

# under volt this thing.
pip install undervolt
systemctl enable undervolt.timer

su tdestro -c 'cd ~; git clone https://aur.archlinux.org/yay.git; cd ~/yay; makepkg -sf' 
pacman -U --noconfirm --needed /home/tdestro/yay/*.pkg.tar.xz
rm -rf /home/tdestro/yay 
su tdestro -c 'echo "baloney1" | yay -S --noconfirm --noprovides jetbrains-toolbox debtap virtualbox-ext-oracle xarchiver-gtk2 lightdm-webkit2-greeter lightdm-webkit-theme-aether acroread nemo-compare kalu vertex-themes-git cinnamon-applet-cpu-temperatur-git cinnamon-applet-hardware-monitor cinnamon-sound-effects jdownloader2 visual-studio-code-bin gitkraken postman-bin simplenote-electron-bin' 

# avatar from github for light dm
curl https://avatars0.githubusercontent.com/u/10113013?s=90 -o /var/lib/AccountsService/icons/tdestro.jpg

{
    echo [User]
    echo Icon=/var/lib/AccountsService/icons/tdestro.jpg
} > /var/lib/AccountsService/users/tdestro
chmod 644 /var/lib/AccountsService/users/tdestro
chmod 644 /var/lib/AccountsService/icons/tdestro.jpg


# gcloud 
curl https://sdk.cloud.google.com -o ./install-gcloud.sh && \
chmod +x ./install-gcloud.sh && \
./install-gcloud.sh --disable-prompts --install-dir=/opt && \
rm ./install-gcloud.sh
su tdestro -c 'echo source /opt/google-cloud-sdk/completion.bash.inc >> /home/tdestro/.profile'
su tdestro -c 'echo source /opt/google-cloud-sdk/path.bash.inc >> /home/tdestro/.profile'

su tdestro -c 'mkdir /home/tdestro/.local /home/tdestro/.local/share /home/tdestro/.local/share/cinnamon /home/tdestro/.local/share/cinnamon/applets'
su tdestro -c 'curl https://cinnamon-spices.linuxmint.com/files/applets/redshift@marvel4u.zip -o /home/tdestro/.local/share/cinnamon/applets/redshift@marvel4u.zip && unzip /home/tdestro/.local/share/cinnamon/applets/redshift@marvel4u.zip -d /home/tdestro/.local/share/cinnamon/applets'
dconf load /org/cinnamon/ < /cinnamon_settings && rm /cinnamon_settings

# Install JLink
#su tdestro -c 'curl –sS –output /home/tdestro/JLink_Linux_x86_64.deb https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.deb'
#su tdestro -c 'debtap -q /home/tdestro/JLink_Linux_x86_64.deb'
#rm /home/tdestro/JLink_Linux_x86_64.deb
#pacman -U --noconfirm --needed /home/tdestro/JLink_Linux_x86_64.pkg.tar.xz
EOF


