#!/bin/sh

# clones the partition layout of a "known good" boot drive and adds part 2 to the proxmox boot manager
# @TODO probably needs to clone part 1 too?

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
partprobe
sync
proxmox-boot-tool format ${destdev}2 --force
sync
proxmox-boot-tool init ${destdev}2 grub
sync
proxmox-boot-tool status

# purge the missing
# while read -r uuid; do
#     $(blkid -o uuid -s $uuid)
# done < /etc/kernel/proxmox-boot-uuids > /etc/kernel/proxmox-boot-uuids