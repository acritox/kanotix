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
if [ -d "${CACHE}overlay$bit-$drv-$ver" -a -z "$OVERWRITE" ]; then
  echo "Error: overlay \"${CACHE}overlay$bit-$drv-$ver\" already exists."
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
mv bin/uname bin/uname.real
cat <<"eof" > bin/uname
#!/bin/sh
[ -z "$1" ] && uname.real && exit
m=$(file /bin/true | grep -q 'ELF 64-bit' && echo x86_64 || echo x86)
r=$(basename "$(ls /lib/modules|head -n1)")
( while [ "$1" ]; do
case $1 in
-m) echo $m;;
-r) echo $r;;
-a)
   echo $(uname.real -s -n) $r $(uname.real -v) $m
   p=$(uname.real -p)
   i=$(uname.real -i)
   [ "$p" = "unknown" ] || echo $p
   [ "$i" = "unknown" ] || echo $n
   uname.real -o
   ;;
*)
   uname.real $1
   ;;
esac; shift; done ) | tr '\n' ' ' | sed 's/ $/\n/'
eof
chmod +x bin/uname
mv sbin/modinfo sbin/modinfo.real
cat <<"eof" > sbin/modinfo
#!/bin/sh
if echo "$@" | grep -qw -- -k; then
modinfo.real "$@"
exit $?
else
modinfo.real -k $(uname -r) "$@"
exit $?
fi
eof
chmod +x sbin/modinfo
cat <<"eof" > usr/sbin/update-initramfs
#!/bin/sh
echo "update-initramfs is disabled for overlay-build"
exit 0
eof
cat <<"eof" > overlay.sh
#!/bin/sh

export LC_ALL=C LANG= DISPLAY=

eof
cat usr/local/bin/install-$drv-debian.sh >> overlay.sh
sed -i '/exit 3/d' overlay.sh
chmod +x overlay.sh
if [ "$(uname -m)" = "x86_64" ] && ! file bin/true | grep -q 'ELF 64-bit'; then
	echo "Found 32bit chroot, using linux32..."
	linux32 chroot . /overlay.sh -v $ver -z
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
rm bin/uname sbin/modinfo
mv bin/uname.real bin/uname
mv sbin/modinfo.real sbin/modinfo
rm -f etc/X11/xorg.conf.1st
printf 'Section "Device"\n    Identifier     "Device0"\n    Driver         "'"$drv"'"\nEndSection\n' > etc/X11/xorg.conf
cd ..
mv overlay "${CACHE}overlay$bit-$drv-$ver"

