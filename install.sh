#!/bin/bash
set -x

timedatectl set-ntp true

arch="$1" bootp="$2" pass="$3"

mkfs.ext4 $arch
mount $arch /mnt
mkdir /mnt/boot
mount $bootp /mnt/boot

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

sed -i '3ipass='$pass /after_chroot.sh
sed -i '3ibootp='$bootp /after_chroot.sh
sed -i '3iarch='$arch /after_chroot.sh

chmod +x /after_chroot.sh
mv /after_chroot.sh /mnt

arch-chroot /mnt ./after_chroot.sh
mv /.config /mnt/home/utku/
chown -R utku /mnt/home/utku

read -r -p "Installation complete. Reboot now? [Y/n]" response
 response=${response,,} # tolower
 if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    reboot
 fi