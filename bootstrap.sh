#!/bin/sh
set -e
# This script should not be run on anything other than the Arch install iso, and will break your system

# Host name canary
if [ "$HOSTNAME" != archiso ]; then
  echo "Will install arch on: $HOSTNAME"
  exit 1
fi

# Translate arguments to variables
for a in "$@"; do
  name="$(echo $a | cut -f1 -d=)"
  value="$(echo $a | cut -f2 -d=)"
  printf -v "$name" "$value"
done

if [ -z "$root" ]; then
  echo "Please give location of root mount, eg. '$0 -s root=/mnt'"
  exit 1
fi

if [ -z "$hostname" ]; then
  echo "Please give machine host name, eg. '$0 -s hostname=beefy'"
  exit 1
fi

if ! mount | grep -q "on $root type"; then
  echo "Please mount a partition on $root"
  exit 1
fi

if [ -n "$(ls -A $root | grep -v -e ^boot$ -e ^home$)" ]; then
  echo "$root must be empty except for the folders boot and home"
  exit 1
fi

if ! mount | grep -q "on $root/boot type vfat"; then
  echo "Please mount a fat32 partition on $root/boot"
  exit 1
fi

if [ -n "$(ls -A $root/boot)" ]; then
  echo "$root/boot must be empty"
  exit 1
fi

if ! mount | grep -q "on $root/home type"; then
  echo "Please mount a partition on $root/home"
  exit 1
fi

if [ -z "$(swapon)" ]; then
  echo "No swap partition mounted"
  exit 1
fi

echo "Sync with ntp..."
timedatectl set-ntp true
echo Installing Arch to "$root"...
pacstrap "$root" base linux linux-firmware git rake xfsprogs lvm2 sudo grub efibootmgr
echo Writing "$root/etc/fstab"...
genfstab -L "$root" >> "$root/etc/fstab"
echo Set host name, timezone, input and locale...
systemd-firstboot --prompt-root-password --root="$root" --locale=en_DK.UTF-8 --locale-message=en_GB.UTF-8 --timezone=Europe/Copenhagen --hostname="$hostname" --keymap=uk
echo Create "$root/etc/hosts"...
echo "127.0.0.1    localhost" > "$root/etc/hosts"
echo "::1          localhost" >> "$root/etc/hosts"
echo "127.0.1.1r   $hostname.localdomain $hostname" >> "$root/etc/hosts"
echo Seup resolver...
echo "nameserver 192.168.100.50" >> "/$root/etc/resolv.conf"
echo Set hwclock...
arch-chroot "$root" hwclock --systohc
echo Enableing locale...
while read -r l; do
  locale=$(echo $l | cut -f2 -d=)
  echo "$locale"
  sed -i -e "/$locale/s/^#//" "$root/etc/locale.gen"
done < "$root/etc/locale.conf"
arch-chroot "$root" locale-gen
echo Fixing initramfs
sed -i "$root/etc/mkinitcpio.conf" -e "/^HOOKS=/s/^/#/;//aHOOKS=(base systemd autodetect modconf block sd-vconsole sd-lvm2 fsck filesystems)"
arch-chroot "$root" mkinitcpio -p linux
echo Installing GRUB...
arch-chroot "$root" grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
arch-chroot "$root" grub-mkconfig -o /boot/grub/grub.cfg

echo Cloning MArch into /opt/march...
arch-chroot "$root" git clone https://github.com/jbro/march.git /opt/march

echo
echo Done
echo
echo Reboot into new install
