#!/bin/sh

cp -r ./initramfs-tools/* /etc/initramfs-tools/ # yes this is slightly dangerous
cp -r ./initramfs-util /etc/rcrypt/
update-initramfs -u -k all
# "Failed to get canonical path of `'." ->
# you didn't mount all of the crypt drives. Even though partition 2 shouldn't be encrypted anyways...