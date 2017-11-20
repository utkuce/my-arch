#!/bin/bash
set -x

timedatectl set-ntp true

arch="$1" bootp="$2" pass="$3"

mkfs.ext4 arch
mount $arch /mnt
mkdir /mnt/boot
mount $bootp /mnt/boot

pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

sed -i '1ipass=$pass' after_chroot.sh
sed -i '1ibootp=$bootp' after_chroot.sh
sed -i '1iarch=$arch' after_chroot.sh

chmod +x after_chroot.sh
mv after_chroot.sh /mnt

arch-chroot /mnt ./after_chroot.sh

chmod +x after_reboot.sh
mv after_reboot /mnt/root/

reboot