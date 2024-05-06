echo "rcrypt hook running..."
mkdir -p ${DESTDIR}/rcrypt/bin
cp /etc/rcrypt/*.tpmpub "${DESTDIR}/rcrypt/"
cp /etc/rcrypt/rtab.conf "${DESTDIR}/rcrypt"
cp -r /etc/rcrypt/initramfs-util/* "${DESTDIR}/rcrypt/bin"
exit 0

# this would be a nice way to force systemd-enroll to decrypt all drives (normally the cryptttab is only read if root is in there),
#    if tpm2=device actually worked in initramfs...
# echo "Force copying crypttab..."
# cp /etc/crypttab "${DESTDIR}/cryptroot/crypttab"
# exit 0