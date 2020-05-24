MArch (Manage Arch?) is a set of scripts and Rakefiles for managing Arch
installations on my laptop and desktop computers.

# Bootstrap machine

* Boot the machine on the latest Arch iso using UEFI.
* Use `# fdisk` to make sure partitions correct.
    * 512M EFI System.
    * Rest Linux LVM.
* Use `# lvs` to examine if LVM is configured correctly.
    * root
    * home
    * boot (EFI partition)
    * swap
* Create missing partitions as thin LVs (if totally blank create thin pool first).
* Format partitions:
    * Clear `swap`: `# mkswap /dev/mapper/vg01-swap`.
    * Clear `/`: `# mkfs.xfs /dev/mapper/vg01-root`.
    * Clear `/boot`: `# mkfs.fat -F32 /dev/nvme0n1p1`.
* Mount partitions under `/mnt`.
* Turn on swap: `# swapon /dev/mapper/vg01-swap`.
* Run bootstrap script: `# curl -s https://raw.github.com/jbro/march/boostrap.sh | sh -- hostname=beefy root=/mnt`.

