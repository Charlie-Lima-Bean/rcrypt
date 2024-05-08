#!/bin/sh

rm /etc/initramfs-tools/hooks/rcrypt-setup.sh
rm /etc/initramfs-tools/scripts/local-top/rcrypt-automount-shim.sh

update-initramfs -u -k all
