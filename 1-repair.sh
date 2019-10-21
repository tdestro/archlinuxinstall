#!/bin/bash
mount /dev/nvme0n1p7 /mnt
mount /dev/nvme0n1p5 /mnt/boot
arch-chroot /mnt /bin/bash <<EOF
mount /dev/nvme0n1p2 /boot/EFI
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
EOF
