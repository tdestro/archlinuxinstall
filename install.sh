#!/bin/bash
echo "Tony's Arch Linux Installer Script"
# Fix the unreadable screen.
pacman --sync --refresh terminus-font --noconfirm
setfont /usr/share/consolefonts/ter-132n.psf.gz
