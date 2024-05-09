#!/bin/sh

if [ "$#" -ne 4 ]; then
    echo "destpart cryptname keyname btrfs-mountpoint"
    exit 1
fi

destpart=$1
cryptname=$2
keyname=$3
mountpoint=$4

keypath=/etc/rcrypt/keys/$3

if ! test -f $keypath; then
  echo $keypath not found
  exit 1
fi

echo "setting up $destpart as $cryptname..."
# will prompt for master passphrase
cryptsetup -v -c aes-xts-plain64 -h sha512 -s 512 luksFormat $destpart $keypath --batch-mode
echo "Input Backup Key..."
cryptsetup luksAddKey $destpart --key-file $keypath
blkid | grep -i "$destpart"
echo "$cryptname UUID=$(blkid -o value -s UUID $destpart) $keypath discard" >> /etc/crypttab
cryptsetup luksOpen --key-file $keypath $destpart $cryptname
btrfs device add /dev/mapper/$cryptname $mountpoint

# clevis luks regen -d $destpart -s 3
# crypstetup remove $cryptname
# btrfs device remove /dev/mapper/$cryptname /
