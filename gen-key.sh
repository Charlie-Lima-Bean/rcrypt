#!/bin/sh
if [ "$#" -ne 1 ]; then
    echo "keyname"
    exit 1
fi

keyname=$1
mkdir -p /etc/rcrypt/keys
mkdir -p /etc/rcrypt/hashes

if test -f /etc/rcrypt/keys/$keyname; then
  echo "already have a key for $keyname. updating tpm binding"
else
  dd bs=64 count=1 if=/dev/urandom of=/etc/rcrypt/keys/$keyname iflag=fullblock
  chmod 600 /etc/rcrypt/keys/$keyname
fi

clevis encrypt tpm2 '{"pcr_bank":"sha256","pcr_ids":"7,8,12"}' < /etc/rcrypt/keys/$keyname >  /etc/rcrypt/hashes/$keyname.tpmpub
