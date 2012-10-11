#!/bin/sh
# Disable the diversion that prevented update-initramfs from being run
# This way we save time by not calling update-initramfs several times
rm -f /usr/local/sbin/update-initramfs

# Create stubs that will be updated by chroot_hacks afterwards
touch $(ls /boot/vmlinuz-* | sed 's@^.*/vmlinuz-@/var/lib/initramfs-tools/@g')

