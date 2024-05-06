#backup script if the tpm gets shuffled
echo "passkey to use:"
read -s $pw
while read -r devname uuid keyname ignore; do
    clevis echo $pw | cryptsetup open /dev/disk/by-uuid/$uuid $devname --key-file=-
done < /rcrypt/rtab.conf
exit 0
