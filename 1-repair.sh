#!/bin/bash
mount /dev/nvme0n1p6 /mnt
mount /dev/nvme0n1p4 /mnt/boot
arch-chroot /mnt /bin/bash
mount /dev/nvme0n1p1 /boot/EFI
grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
