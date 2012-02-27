#!/bin/sh
[ $(id -u) != 0 ] && exit
export http_proxy=
dpkg -l libgl1-mesa-glx|grep -q bpo || exit 0
if [ -f /usr/lib32/libGL.so.1.2 ]; then
 TMP=$(mktemp -d /tmp/libgl.XXXXXX)
 DEB=$(wget -qO- http://packages.debian.org/squeeze-backports/i386/libgl1-mesa-glx/download|awk -F\" '/ftp.de/&&/pool/{print $2}')
 wget -NP $TMP $DEB
 dpkg-deb -x $TMP/${DEB##*/} $TMP
 mv -v $TMP/usr/lib/libGL.so.1.2 /usr/lib32
 rm -rf $TMP
else
 exit 0
fi
