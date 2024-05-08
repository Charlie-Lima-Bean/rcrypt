#!/bin/sh

if [ "$#" -ne 4 ]; then
    echo "destpart cryptname keyname btrfs-mountpoint"
    exit 1
fi

destpart=$1
cryptname=$2
keyname=$3
mountpoint=$4

if ! test -f /etc/rcrypt/$3; then
  echo "/etc/rcrypt/$3" not found
  exit 1
fi

echo "setting up $destpart as $cryptname..."
# will prompt for master passphrase
cryptsetup -v -c aes-xts-plain64 -h sha512 -s 512 luksFormat $destpart /etc/rcrypt/$keyname --batch-mode
echo "Input Backup Key..."
cryptsetup luksAddKey $destpart --key-file /etc/rcrypt/keys/$keyname
blkid | grep -i "$destpart"
echo "$cryptname $(blkid -o value -s UUID $destpart) /etc/rcrypt/keys/$keyname discard" >> /etc/crypttab
cryptsetup luksOpen --key-file /etc/rcrypt/keys/$keyname $destpart $cryptname
btrfs device add /dev/mapper/$cryptname $mountpoint

# clevis luks regen -d $destpart -s 3
# crypstetup remove $cryptname
# btrfs device remove /dev/mapper/$cryptname /
