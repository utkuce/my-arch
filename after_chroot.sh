#!/bin/bash
set -x

ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc

sed -i s/'#en_US.UTF-8'/'en_US.UTF-8'/g /etc/locale.gen
sed -i s/'#en_DK.UTF-8'/'en_DK.UTF-8'/g /etc/locale.gen
echo -e 'LANG=en_US.UTF-8\nLC_TIME=en_DK.UTF-8' > /etc/locale.conf
locale-gen
echo 'KEYMAP=trq' > /etc/vconsole.conf

me=lenovo-arch
echo $me > /etc/hostname
sed -i '8i127.0.0.1\t'$me'.localdomain\t'$me'\n' /etc/hosts

timedatectl set-local-rtc 0
echo 'root:'$pass|chpasswd
bootctl install

pacman -S intel-ucode --noconfirm

echo -e 'default\tarch\ntimeout\t0\neditor\t0' > boot/loader/loader.conf

arch_conf=boot/loader/entries/arch.conf 
echo -e 'title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/intel-ucode.img' > $arch_conf
echo -e 'initrd\t/initramfs-linux.img\noptions\troot='$arch >> $arch_conf

useradd -m -G wheel utku
echo 'utku:'$pass|chpasswd

pacman -S --needed base-devel --noconfirm
sed -i s/'# %wheel ALL=(ALL) ALL'/'%wheel ALL=(ALL) ALL'/g /etc/sudoers
#echo 'Defaults targetpw' >> /etc/sudoers

# autologin for my user
mkdir /etc/systemd/system/getty@tty1.service.d/
autologin=/etc/systemd/system/getty@tty1.service.d/override.conf
echo -e '[Service]\nExecStart=' > $autologin
echo 'ExecStart=-/usr/bin/agetty --autologin utku --noclear %I $TERM' >> $autologin

pacman -S networkmanager iw wpa_supplicant dhclient --noconfirm
systemctl enable NetworkManager.service

pacman -S xorg-server xorg-xinit xterm bspwm sxhkd --noconfirm
echo -e "setxkbmap tr\nexec bspwm" > /home/utku/.xinitrc
echo "exec startx" >> /home/utku/.bash_profile

pacman -S rofi xdg-utils --noconfirm

# install pacaur
mkdir -p /tmp/pacaur_install
chown -R utku /tmp/pacaur_install
cd /tmp/pacaur_install
pacman -S expac yajl git --noconfirm --needed

curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
su -c "makepkg PKGBUILD --skippgpcheck" utku
pacman -U cower*.tar.xz --noconfirm

curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
su -c "makepkg PKGBUILD" utku
pacman -U pacaur*.tar.xz --noconfirm

#nmcli dev wifi connect "NetMASTER Uydunet-B781" password f22d96a1

chown -R utku /home/utku
rm -r /tmp/pacaur_install
rm /after_chroot.sh /README.md