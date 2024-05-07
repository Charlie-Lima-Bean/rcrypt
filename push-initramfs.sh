#!/bin/sh

cp -r ./initramfs-tools/* /etc/initramfs-tools/ # yes this is slightly dangerous
cp -r ./initramfs-util /etc/rcrypt/initramfs-util
update-initramfs -u -k all
