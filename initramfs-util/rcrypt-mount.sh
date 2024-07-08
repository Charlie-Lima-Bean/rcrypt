#!/bin/bash

#backup script if the tpm gets shuffled
read "passkey to use:" -s pw
while read -r devname uuid keyname ignore; do
    echo -n $pw | cryptsetup open /dev/disk/by-uuid/$uuid $devname --key-file=-
done < /rcrypt/rtab.conf
exit 0
