#!/bin/sh
# Disable the diversion that prevented update-initramfs from being run
# This way we save time by not calling update-initramfs several times
rm -f /usr/local/sbin/update-initramfs

# Create stubs that will be updated by chroot_hacks afterwards

# not working in bullseye TODO

case "${LB_DISTRIBUTION}" in

       whezzy|jessie|stretch|buster)
            touch $(ls /boot/vmlinuz-* | sed 's@^.*/vmlinuz-@/var/lib/initramfs-tools/@g')
            ;;
       *)
            echo
            ;;
esac

