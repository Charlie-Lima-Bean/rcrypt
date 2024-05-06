# read config

while read -r devname uuid keyname ignore; do
    clevis decrypt < /recrypt/$keyname.tpmpub | sudo cryptsetup open /dev/disk/by-uuid/$uuid $devname --key-file=-
done < /rcrypt/rtab.conf
# clevis decrypt $cipher > cryptsetup
