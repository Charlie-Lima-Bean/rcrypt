#!/bin/sh
# cp /etc/cryptkeys/scripts/crypttab-hook.sh /etc/initramfs-tools/hooks
# this would be a nice way to force systemd-enroll to decrypt all drives (normally the cryptttab is only read if root is in there),
#    if it actually worked in initramfs...
echo "Force copying crypttab..."
cp /etc/crypttab "${DESTDIR}/cryptroot/crypttab"
exit 0
