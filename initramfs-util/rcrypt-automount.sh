#!/bin/bash
prefix=$1

while read -r devname uuid keyname ignore; do
    clevis decrypt < $prefix/rcrypt/hashes/$keyname.tpmpub | cryptsetup open /dev/disk/by-uuid/$uuid $devname --key-file=-
done < $prefix/rcrypt/rtab.conf
exit 0
