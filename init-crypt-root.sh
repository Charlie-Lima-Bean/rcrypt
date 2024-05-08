#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "dest cryptname keyname"
    exit 1
fi

dest=${1}3
cryptname=$2
keyname=$3

if ! test -f /etc/rcrypt/keys/$keyname; then
  echo "/etc/rcrypt/keys/$keyname" not found
  exit 1
fi

echo "setting up $dest as $cryptname..."
# will prompt for master passphrase
cryptsetup -v -c aes-xts-plain64 -h sha512 -s 512 luksFormat $dest /etc/rcrypt/keys/$keyname --batch-mode
cryptsetup luksAddKey $dest --key-file /etc/rcrypt/keys/$keyname
blkid | grep -i "$dest"
# cryptenroll refuses to read the tpm properly during initramfs
# systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="7+8" --wipe-slot=4 ${dest} 
# clevis works, but it seems that successive clevis-binds interfere with each other
# clevis-luks-bind -d ${dest} -k /etc/rcrypt/$keyname -s 3 tpm2 '{"pcr_bank":"sha256","pcr_ids":"7,8"}'
# echo "$cryptname UUID=$(blkid -o value -s UUID ${dest}) none tpm2-device=auto,discard" >> /etc/crypttab
echo "$cryptname $(blkid -o value -s UUID $dest) $keyname" >> /etc/rcrypt/rtab.conf
cryptsetup luksOpen --key-file /etc/rcrypt/keys/$keyname $dest $cryptname
btrfs device add /dev/mapper/$cryptname /
#this script will probably be run in batches, so don't push automatically
echo "don't forget to push-initramfs"

# clevis luks regen -d ${dest} -s 3
# dmsetup remove gold_crypt
# btrfs device remove /dev/mapper/$cryptnamWe /
