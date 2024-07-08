#!/bin/bash

echo "rcrypt hook running..."
rm ${DESTDIR}/rcrypt -r # apparently these are sticky?
mkdir -p ${DESTDIR}/rcrypt/bin
mkdir -p ${DESTDIR}/rcrypt/hashes

cp /etc/rcrypt/hashes/*.tpmpub "${DESTDIR}/rcrypt/hashes"
cp /etc/rcrypt/rtab.conf "${DESTDIR}/rcrypt"
cp -r /etc/rcrypt/initramfs-util/* "${DESTDIR}/rcrypt/bin"
exit 0

# this would be a nice way to force systemd-enroll to decrypt all drives (normally the cryptttab is only read if root is in there),
#    if tpm2=device actually worked in initramfs...
# echo "Force copying crypttab..."
# cp /etc/crypttab "${DESTDIR}/cryptroot/crypttab"
# exit 0