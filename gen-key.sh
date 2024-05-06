
keyname=$1
if test -f /etc/rcrypt/$keyname; then
  echo "already have a key for $keyname. updating tpm binding"
else
  dd bs=64 count=1 if=/dev/urandom of=/etc/rcrypt/$keyname iflag=fullblock
  chmod 600 /etc/rcrypt/$keyname
fi

clevis encrypt tpm2 '{"pcr_bank":"sha256","pcr_ids":"7,8"}' < /etc/rcrypt/$keyname >  /etc/rcrypt/$keyname.tpmpub
