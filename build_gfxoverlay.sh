#!/bin/bash
if ((UID)); then
  echo "Error: You must be root to run this script"
  exit 2
fi
case "$1" in
nvidia|fglrx) drv=$1;;
*)
  echo "Usage: $(basename "$0") <nvidia|fglrx> <version>"
  exit 3
  ;;
esac
case "$2" in
?*) ver="$2";;
*)
  echo "Usage: $(basename "$0") <nvidia|fglrx> <version>"
  exit 3
  ;;
esac
if [ ! -x chroot/bin/bash ]; then
  echo "Error: something is wrong with \"chroot/\" - maybe you are in the wrong directory or haven't built it yet?"
  exit 4
fi
bit="$(file chroot/bin/true | grep -q 'ELF 64-bit' && echo 64 || echo 32)"
if [ -d "overlay$bit-$drv-$ver" -a -z "$OVERWRITE" ]; then
  echo "Error: overlay \"overlay$bit-$drv-$ver\" already exists."
  exit 5
fi
mkdir -p overlay root
umount root/proc root/sys root/dev root &>/dev/null
rm -rf overlay/* overlay/.??*
mount -t aufs -o br:overlay:chroot/ none root/
if [ -d cache ]; then
  mkdir -p overlay/usr/src
  for i in cache/NVIDIA-Linux* cache/ati-driver-installer*
  do
    [ -f $i ] && ln $i overlay/usr/src/
  done
fi
cd root/
mount --bind /proc proc/
mount --bind /sys sys/
mount --bind /dev dev/
cp /etc/resolv.conf etc/resolv.conf 
cat <<"eof" > usr/sbin/update-initramfs
#!/bin/sh
echo "update-initramfs is disabled for overlay-build"
exit 0
eof
cat <<"eof" > overlay.sh
#!/bin/sh

export LC_ALL=C LANG= DISPLAY=

uname()
{
case $1 in
-m)
   file /bin/true | grep -q 'ELF 64-bit' && echo x86_64 || echo x86
   ;;
-r)
   basename /lib/modules/*
   ;;
esac
}

eof
cat usr/local/bin/install-$drv-debian.sh >> overlay.sh
sed -i '/exit 3/d' overlay.sh
chmod +x overlay.sh
if [ "$(uname -m)" = "x86_64" ] && ! file bin/true | grep -q 'ELF 64-bit'; then
	echo "Found 32bit chroot, using linux32..."
	chroot . linux32 /overlay.sh -v $ver -z
else
	chroot . /overlay.sh -v $ver -z
fi
cd ..
umount root/proc root/sys root/dev root &>/dev/null
rm -rf root
if [ -d cache ]; then
  mv -f overlay/usr/src/NVIDIA-Linux* cache/ 2>/dev/null
  mv -f overlay/usr/src/ati-driver-installer* cache/ 2>/dev/null
fi
if [ -z "$(find overlay/ -name '*.ko')" ]; then
  echo "Error: Something went wrong while building the overlay (no *.ko module has been built)"
  exit 6
fi
cd overlay
rm -rf usr/sbin/update-initramfs etc/resolv.conf usr/src/NVIDIA-Linux* usr/src/ati-driver-installer* overlay.sh tmp var/log .??*
rm -f etc/X11/xorg.conf.1st
printf 'Section "Device"\n    Identifier     "Device0"\n    Driver         "'"$drv"'"\nEndSection\n' > etc/X11/xorg.conf
cd ..
mv overlay "overlay$bit-$drv-$ver"

