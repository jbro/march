MArch (Manage Arch?) is a set of scripts and Rakefiles for managing Arch
installations on my laptop and desktop computers.

# Installation checklist

* Boot the machine on the latest Arch iso using UEFI.
* Use `fdisk` to make sure partitions correct.
  * 512M EFI System.
  * Rest Linux LVM.
* Use `lvs` to examine if LVM is configured correctly.
* Create missing partitions as thin LVs (if totally blank create thin pool first).
* Format partitions:
  * Clear `swap`: `mkswap /dev/mapper/vg01-swap`.
  * Clear `/`: `mkfs.xfs /dev/mapper/vg01-root`.
  * Clear `/boot`: `mkfs.fat -F32 /dev/nvme0n1p1`.
* Mount partitions under `/mnt`.
* Turn on swap: `swapon /dev/mapper/vg01-swap`.
* Generate `/mnt/etc/fstab`: `genfstab -L /mnt >> /mnt/etc/fstab`.
* Install Arch to `/mnt`: `pacstrap /mnt base linux linux-firmware git vim rake man-db man-pages texinfo xfsprogs lvm2`.
* Jump into new Arch install: `arch-chroot /mnt`.
* Setup resolver `echo "nameserver 192.168.100.50" >> /etc/resolv.conf`.

# Install scripts

`git clone https://github.com/jbro/march.git` /opt/march
