#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "src dev"
    exit 1
fi
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
sync
# purge the missing
# while read -r uuid; do
#     $(blkid -o uuid -s $uuid)
# done < /etc/kernel/proxmox-boot-uuids > /etc/kernel/proxmox-boot-uuids