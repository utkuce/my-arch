#!/bin/bash
set -x

ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc

sed -i s/'#en_US.UTF-8'/'en_US.UTF-8'/g /etc/locale.gen
echo 'LC_TIME=en_DK' > /etc/locale.conf
locale-gen
echo 'KEYMAP=trq' > /etc/vconsole.conf

me=lenovo-utku
echo $me > /etc/hostname
sed -i '8i127.0.0.1\t'$me'.localdomain\t'$me'\n' /etc/hosts

timedatectl set-local-rtc 0
echo 'root:'$pass|chpasswd
bootctl --path=$bootp install

pacman -S intel-ucode --noconfirm

echo -e 'default\tarch\ntimeout\t0\neditor\t0' > $bootp/loader/loader.conf

arch_conf=$bootp/loader/entries/arch.conf 
echo -e 'title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/intel-ucode.img' > $arch_conf
echo -e 'initrd\t/initramfs-linux.img\noptions\troot='$arch >> $arch_conf

useradd -m -G wheel utku
echo 'utku:'$pass|chpasswd

pacman -S sudo --noconfirm
sed -i s/'# %wheel ALL=(ALL) ALL'/'%wheel ALL=(ALL) ALL'/g /etc/sudoers
#echo 'Defaults targetpw' >> /etc/sudoers
 
pacman -S networkmanager iw wpa_supplicant dhclient --noconfirm
pacman -S xorg-server xorg-xinit i3 --noconfirm
echo -e "setxkbmap tr\nexec i3" > /home/utku/.xinitrc

#systemctl start NetworkManager.service
#nmcli dev wifi connect "NetMASTER Uydunet-B781" password f22d96a1