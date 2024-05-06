# src dest
srcdev=$1
destdev=$2
sgdisk $srcdev -R $destdev
sync
partprobe
sync #idk just put these everywhere
sgdisk -G $destdev
sync
proxmox-boot-tool format ${destdev}2
sync
proxmox-boot-tool init ${destdev}2 grub
