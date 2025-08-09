#!/bin/bash
cd "$(dirname "$0")"
function check_iso {

# check for possible errors in iso file

echo "K: Kanotix start iso check..." >>binary.log
    IERR=0
if grep -q "^E: " /tmp/KLB_config.log; then
    echo "K: Download ERROR found...1" >>binary.log
    IERR=5
fi
if grep -q "^E: " binary.log; then
    echo "K: build ERROR found...1" >>binary.log
    IERR=1
fi
if grep -F -q "Err:" binary.log; then
    echo "K: apt-cacher-ng ERROR found...2" >>binary.log
    IERR=2
fi
if grep -q ^parted binary.packages; then
    if grep ^parted binary.packages|grep kanotix >/dev/null; then
        echo
    else
        echo "K: non kanotix parted version found" >>binary.log
        echo "K: ERROR found...3" >>binary.log
        IERR=4
    fi
fi
if grep -q ^winetricks binary.packages; then
    if grep ^winetricks binary.packages|grep kanotix >/dev/null; then
        echo
    else
        echo "K: non kanotix winetricks version found" >>binary.log
        echo "K: ERROR found...4" >>binary.log
        IERR=4
    fi
fi
if [ $IERR -eq 0 ]; then
echo "K: Kanotix iso check passed..." >>binary.log
else
echo "K: Kanotix iso check errors detected... removing iso" >>binary.log
rm -f kanotix*.iso
fi

return $IERR
}

rm -rf cache tmpfs/cache

TARGETDIR="/data/kanotix"

# delete iso files older 35 days

find $TARGETDIR/nightly -mtime +35 -type f -print -delete
find $TARGETDIR/nightly -type d -empty -print -delete

# reset apt-cacher-ng cache
find /var/cache/apt-cacher-ng \( -type f -name 'Packages*' -o -name 'Sources*' -o -name 'Release*' -o -name 'InRelease*' \) -delete

d="$(date +%y%m%d)"
v=a
target=$TARGETDIR/nightly/$d
next=$TARGETDIR/nightly/.next
rm -rf $next
mkdir -p $target $next
rm -f $target/isos-failed.txt

## remove gfxdetect entries from grub.cfg (for non-gfxdetect-builds)
#sed -i '/gfxdetect/,/^}/{d}' config/binary_grub/grub.cfg

BUILD_TRIXIE=true
BUILD_TRIXIE_EEE_I386=true
BUILD_TRIXIE_EEE_AMD64=false
BUILD_TRIXIE_AMD64=true
BUILD_TRIXIE_I386=false
BUILD_BOOKWORM=true
BUILD_BOOKWORM_EEE=true
BUILD_BULLSEYE=true # only eeepc

################### TOWELFIRE  ###################

if $BUILD_TRIXIE; then
git checkout auto/config
DISTRO=trixie
KDISTRO=towelfire
rm -rf cache tmpfs/cache
sed -i 's/\(export LB_DISTRIBUTION=\).*/\1"'$DISTRO'"/' auto/config


cat <<"EOF" >$target/readme-$KDISTRO.txt
Towelfire Isos are current release.
===================================
Based on Debian13 trixie (stable).
Isos are nightly builds.
acritox installer(recommended)
and calamares installer are provided.

i386 eeepc4G.iso ships with bookworm kernel
and reduced firmware
and may need nomodeset to boot.
EOF

ln -s $target/readme-$KDISTRO.txt $next/readme-$KDISTRO.txt

if $BUILD_TRIXIE_EEE_AMD64; then
# eeepc4G amd64 with LXDE
lb clean
lb config -d $DISTRO -p "kanotix-eeepc4G firefox systemd-extra" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd --initramfs live-boot
echo Kanotix towelfire-nightly Towelfire64 $d$v eeepc4G > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso
check_iso
mv kanotix64.iso $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.packages
cp tmpfs/binary.log $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.log
cd $target
if [ ! -f kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso ]; then
        echo "$KDISTRO amd64 eeepc4G failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.log $next/kanotix64-towelfire-nightly-eeepc4G.log
else
        md5sum -b kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso > kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso.md5
        zsyncmake kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso
        cd -
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.packages $next/kanotix64-towelfire-nightly-eeepc4G.packages
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.log $next/kanotix64-towelfire-nightly-eeepc4G.log
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso $next/kanotix64-towelfire-nightly-eeepc4G.iso
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso.zsync $next/kanotix64-towelfire-nightly-eeepc4G.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-towelfire-nightly-${d}${v}-eeepc4G.iso.md5 > $next/kanotix64-towelfire-nightly-eeepc4G.iso.md5
fi
fi # end amd64 EEE

if $BUILD_TRIXIE_AMD64; then
# kde 64
lb clean
lb config -d $DISTRO -p "debpool kanotix-kde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd --initramfs live-boot
echo Kanotix towelfire-nightly Towelfire64 $d$v KDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso
check_iso
#ls -hgo kanotix64.iso >>binary.log; rm -f kanotix64.iso
mv kanotix64.iso $target/kanotix64-towelfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-towelfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix64-towelfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix64-towelfire-nightly-${d}${v}-KDE.iso ]; then
        echo "$KDISTRO amd64 KDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-KDE.log $next/kanotix64-towelfire-nightly-KDE.log
else
        md5sum -b kanotix64-towelfire-nightly-${d}${v}-KDE.iso > kanotix64-towelfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix64-towelfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-KDE.packages $next/kanotix64-towelfire-nightly-KDE.packages
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-KDE.log $next/kanotix64-towelfire-nightly-KDE.log
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-KDE.iso $next/kanotix64-towelfire-nightly-KDE.iso
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix64-towelfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-towelfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix64-towelfire-nightly-KDE.iso.md5
fi
#
# lxde 64
lb clean
lb config -d $DISTRO -p "debpool kanotix-lxde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd --initramfs live-boot
echo Kanotix towelfire-nightly Towelfire64 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso
check_iso
#ls -hgo kanotix64.iso >>binary.log; rm -f kanotix64.iso
mv kanotix64.iso $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix64-towelfire-nightly-${d}${v}-LXDE.iso ]; then
        echo "$KDISTRO amd64 LXDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.log $next/kanotix64-towelfire-nightly-LXDE.log
else
        md5sum -b kanotix64-towelfire-nightly-${d}${v}-LXDE.iso > kanotix64-towelfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix64-towelfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.packages $next/kanotix64-towelfire-nightly-LXDE.packages
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.log $next/kanotix64-towelfire-nightly-LXDE.log
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.iso $next/kanotix64-towelfire-nightly-LXDE.iso
        ln -s $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix64-towelfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-towelfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix64-towelfire-nightly-LXDE.iso.md5
fi
fi #end of amd64
if $BUILD_TRIXIE_I386; then
# kde 32
lb clean
lb config -d $DISTRO -p "kanotix-kde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix towelfire-nightly Towelfire32 $d$v KDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-towelfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-towelfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix32-towelfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix32-towelfire-nightly-${d}${v}-KDE.iso ]; then
        echo "$KDISTRO i386 KDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-KDE.log $next/kanotix32-towelfire-nightly-KDE.log
else
        md5sum -b kanotix32-towelfire-nightly-${d}${v}-KDE.iso > kanotix32-towelfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix32-towelfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-KDE.packages $next/kanotix32-towelfire-nightly-KDE.packages
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-KDE.log $next/kanotix32-towelfire-nightly-KDE.log
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-KDE.iso $next/kanotix32-towelfire-nightly-KDE.iso
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix32-towelfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-towelfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix32-towelfire-nightly-KDE.iso.md5
fi

# lxde 32
lb clean
lb config -d $DISTRO -p "kanotix-lxde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix towelfire-nightly Towelfire32 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix32-towelfire-nightly-${d}${v}-LXDE.iso ]; then
        echo "$KDISTRO i386 LXDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.log $next/kanotix32-towelfire-nightly-LXDE.log
else
        md5sum -b kanotix32-towelfire-nightly-${d}${v}-LXDE.iso > kanotix32-towelfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix32-towelfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.packages $next/kanotix32-towelfire-nightly-LXDE.packages
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.log $next/kanotix32-towelfire-nightly-LXDE.log
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.iso $next/kanotix32-towelfire-nightly-LXDE.iso
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix32-towelfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-towelfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix32-towelfire-nightly-LXDE.iso.md5
fi
fi #end of trixie i386 kde lxde

if $BUILD_TRIXIE_EEE_I386; then
# eeepc4G with LXDE
lb clean
lb config -d $DISTRO -p "kanotix-eeepc4G netsurf-gtk" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix towelfire-nightly Towelfire32 $d$v eeepc4G > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.packages
cp tmpfs/binary.log $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.log
cd $target
if [ ! -f kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso ]; then
        echo "$KDISTRO i386 eeepc4G failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-towelfire-nightly-eeepc4G.log
else
        md5sum -b kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso > kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso.md5
        zsyncmake kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso
        cd -
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.packages $next/kanotix32-towelfire-nightly-eeepc4G.packages
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-towelfire-nightly-eeepc4G.log
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso $next/kanotix32-towelfire-nightly-eeepc4G.iso
        ln -s $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso.zsync $next/kanotix32-towelfire-nightly-eeepc4G.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-towelfire-nightly-${d}${v}-eeepc4G.iso.md5 > $next/kanotix32-towelfire-nightly-eeepc4G.iso.md5
fi
fi #end of i386 eeepc
fi # end of trixie build

################### SLOWFIRE  ###################

if $BUILD_BOOKWORM; then
git checkout auto/config
DISTRO=bookworm
KDISTRO=slowfire
rm -rf cache tmpfs/cache
sed -i 's/\(export LB_DISTRIBUTION=\).*/\1"'$DISTRO'"/' auto/config


cat <<"EOF" >$target/readme-$KDISTRO.txt
Slowfire Isos are based on bookworm.
====================================
amd64 Iso ship with acritoxinstaller(recommended) and calamares installer(for testing)
refind is preinstalled using grub in acritoxinstaller is recommended.
you can enable refind later in installation with # refind-install
EOF

ln -s $target/readme-$KDISTRO.txt $next/readme-$KDISTRO.txt

# kde 64
lb clean
lb config -d $DISTRO -p "debpool kanotix-kde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix slowfire-nightly Slowfire64 $d$v KDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso
check_iso
#ls -hgo kanotix64.iso >>binary.log; rm -f kanotix64.iso
mv kanotix64.iso $target/kanotix64-slowfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-slowfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix64-slowfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix64-slowfire-nightly-${d}${v}-KDE.iso ]; then
        echo "$KDISTRO amd64 KDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-KDE.log $next/kanotix64-slowfire-nightly-KDE.log
else
        md5sum -b kanotix64-slowfire-nightly-${d}${v}-KDE.iso > kanotix64-slowfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix64-slowfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-KDE.packages $next/kanotix64-slowfire-nightly-KDE.packages
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-KDE.log $next/kanotix64-slowfire-nightly-KDE.log
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-KDE.iso $next/kanotix64-slowfire-nightly-KDE.iso
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix64-slowfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-slowfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix64-slowfire-nightly-KDE.iso.md5
fi
#
# lxde 64
lb clean
lb config -d $DISTRO -p "debpool kanotix-lxde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix slowfire-nightly Slowfire64 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso
check_iso
#ls -hgo kanotix64.iso >>binary.log; rm -f kanotix64.iso
mv kanotix64.iso $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix64-slowfire-nightly-${d}${v}-LXDE.iso ]; then
        echo "$KDISTRO amd64 LXDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.log $next/kanotix64-slowfire-nightly-LXDE.log
else
        md5sum -b kanotix64-slowfire-nightly-${d}${v}-LXDE.iso > kanotix64-slowfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix64-slowfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.packages $next/kanotix64-slowfire-nightly-LXDE.packages
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.log $next/kanotix64-slowfire-nightly-LXDE.log
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.iso $next/kanotix64-slowfire-nightly-LXDE.iso
        ln -s $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix64-slowfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-slowfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix64-slowfire-nightly-LXDE.iso.md5
fi

# kde 32
lb clean
lb config -d $DISTRO -p "kanotix-kde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix slowfire-nightly Slowfire32 $d$v KDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-slowfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-slowfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix32-slowfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix32-slowfire-nightly-${d}${v}-KDE.iso ]; then
        echo "$KDISTRO i386 KDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-KDE.log $next/kanotix32-slowfire-nightly-KDE.log
else
        md5sum -b kanotix32-slowfire-nightly-${d}${v}-KDE.iso > kanotix32-slowfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix32-slowfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-KDE.packages $next/kanotix32-slowfire-nightly-KDE.packages
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-KDE.log $next/kanotix32-slowfire-nightly-KDE.log
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-KDE.iso $next/kanotix32-slowfire-nightly-KDE.iso
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix32-slowfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-slowfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix32-slowfire-nightly-KDE.iso.md5
fi

# lxde 32
lb clean
lb config -d $DISTRO -p "kanotix-lxde-master firefox wine-staging" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix slowfire-nightly Slowfire32 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix32-slowfire-nightly-${d}${v}-LXDE.iso ]; then
        echo "$KDISTRO i386 LXDE failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.log $next/kanotix32-slowfire-nightly-LXDE.log
else
        md5sum -b kanotix32-slowfire-nightly-${d}${v}-LXDE.iso > kanotix32-slowfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix32-slowfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.packages $next/kanotix32-slowfire-nightly-LXDE.packages
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.log $next/kanotix32-slowfire-nightly-LXDE.log
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.iso $next/kanotix32-slowfire-nightly-LXDE.iso
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix32-slowfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-slowfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix32-slowfire-nightly-LXDE.iso.md5
fi

fi # end of normal bookworm build

if $BUILD_BOOKWORM_EEE; then

# eeepc4G with LXDE
git checkout auto/config
DISTRO=bookworm
KDISTRO=slowfire
rm -rf cache tmpfs/cache
sed -i 's/\(export LB_DISTRIBUTION=\).*/\1"'$DISTRO'"/' auto/config

lb clean
lb config -d $DISTRO -p "kanotix-eeepc4G netsurf-gtk" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix slowfire-nightly Slowfire32 $d$v eeepc4G > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.packages
cp tmpfs/binary.log $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.log
cd $target
if [ ! -f kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso ]; then
        echo "$KDISTRO i386 eeepc4G failed" >>isos-failed.txt
        cd -
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-slowfire-nightly-eeepc4G.log
else
        md5sum -b kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso > kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso.md5
        zsyncmake kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso
        cd -
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.packages $next/kanotix32-slowfire-nightly-eeepc4G.packages
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-slowfire-nightly-eeepc4G.log
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso $next/kanotix32-slowfire-nightly-eeepc4G.iso
        ln -s $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso.zsync $next/kanotix32-slowfire-nightly-eeepc4G.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-slowfire-nightly-${d}${v}-eeepc4G.iso.md5 > $next/kanotix32-slowfire-nightly-eeepc4G.iso.md5
fi

fi # end of bookworm EEE build

################### SPEEDFIRE  ###################

if $BUILD_BULLSEYE; then
git checkout auto/config
DISTRO=bullseye
rm -rf cache tmpfs/cache
sed -i 's/\(export LB_DISTRIBUTION=\).*/\1"'$DISTRO'"/' auto/config

# eeepc4G with LXDE
lb clean
lb config -d $DISTRO -p "kanotix-eeepc4G netsurf-gtk" --bootloader grub2 --tmpfs true --tmpfs-options size=16G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix speedfire-nightly Speedfire32 $d$v eeepc4G > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso
check_iso
mv kanotix32.iso $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.packages
cp tmpfs/binary.log $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.log
cd $target
if [ ! -f kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso ]; then
        cd -
        ln -s $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-speedfire-nightly-eeepc4G.log
else
        md5sum -b kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso > kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso.md5
        zsyncmake kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso
        cd -
        ln -s $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.packages $next/kanotix32-speedfire-nightly-eeepc4G.packages
        ln -s $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-speedfire-nightly-eeepc4G.log
        ln -s $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso $next/kanotix32-speedfire-nightly-eeepc4G.iso
        ln -s $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso.zsync $next/kanotix32-speedfire-nightly-eeepc4G.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-speedfire-nightly-${d}${v}-eeepc4G.iso.md5 > $next/kanotix32-speedfire-nightly-eeepc4G.iso.md5
fi
fi # end of bullseye build


git checkout auto/config

rm -rf $next/../latest
mv $next $next/../latest
