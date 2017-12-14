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

chmod +x /.config/sxhkd/sxhkdrc
chmod +x /.config/bspwm/bspwmrc
mv /.config /mnt/home/utku
echo -e '#!/bin/bash\nchown -R utku /home/utku/.config' > change_owner.sh
chmod +x change_ownser.sh
arch-chroot /mnt ./change_owner.sh 

read -r -p "Installation complete. Reboot now? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    reboot
fi