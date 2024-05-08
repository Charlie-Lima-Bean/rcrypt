#!/bin/sh

while read -r devname uuid keyname ignore; do
    clevis decrypt < /rcrypt/$keyname.tpmpub | cryptsetup open /dev/disk/by-uuid/$uuid $devname --key-file=-
done < /rcrypt/rtab.conf
exit 0
