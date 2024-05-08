#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "destpart cryptname keyname"
    exit 1
fi

destpart=$1
cryptname=$2
keyname=$3

if ! test -f /etc/rcrypt/$3; then
  echo "/etc/rcrypt/$3" not found
  exit 1
fi

echo "setting up $destpart as $cryptname..."
# will prompt for master passphrase
cryptsetup -v -c aes-xts-plain64 -h sha512 -s 512 luksFormat $destpart /etc/rcrypt/$keyname --batch-mode
cryptsetup luksAddKey $destpart --key-file /etc/rcrypt/keys/$keyname
blkid | grep -i "$destpart"
# cryptenroll refuses to read the tpm properly during initramfs
# systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="7+8" --wipe-slot=4 $destpart 
# clevis works, but it seems that successive clevis-binds interfere with each other
# clevis-luks-bind -d $destpart -k /etc/rcrypt/$keyname -s 3 tpm2 '{"pcr_bank":"sha256","pcr_ids":"7,8"}'
# echo "$cryptname UUID=$(blkid -o value -s UUID $destpart) none tpm2-device=auto,discard" >> /etc/crypttab
echo "$cryptname $(blkid -o value -s UUID $destpart) $keyname" >> /etc/rcrypt/rtab.conf
cryptsetup luksOpen --key-file /etc/rcrypt/keys/$keyname $destpart $cryptname
btrfs device add /dev/mapper/$cryptname /
#this script will probably be run in batches, so don't push automatically
echo "don't forget to push-initramfs"

# clevis luks regen -d $destpart -s 3
# dmsetup remove gold_crypt
# btrfs device remove /dev/mapper/$cryptnamWe /
