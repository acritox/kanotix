#!/bin/bash
cd "$(dirname "$0")"
rm -rf cache tmpfs/cache

# reset apt-cacher-ng cache
find /var/cache/apt-cacher-ng \( -type f -name 'Packages*' -o -name 'Sources*' -o -name 'Release*' -o -name 'InRelease*' \) -delete

d="$(date +%y%m%d)"
v=a
target=/data/kanotix/nightly/$d
next=/data/kanotix/nightly/.next
rm -rf $next
mkdir -p $target $next

## remove gfxdetect entries from grub.cfg (for non-gfxdetect-builds)
#sed -i '/gfxdetect/,/^}/{d}' config/binary_grub/grub.cfg

lb clean
lb config -d wheezy -p "kanotix-kde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64
echo Kanotix dragonfire-nightly Dragonfire64 $d$v KDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix64-dragonfire-nightly-${d}${v}-KDE.iso ]; then
        cd -
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.log $next/kanotix64-dragonfire-nightly-KDE.log
else
        md5sum -b kanotix64-dragonfire-nightly-${d}${v}-KDE.iso > kanotix64-dragonfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix64-dragonfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.packages $next/kanotix64-dragonfire-nightly-KDE.packages
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.log $next/kanotix64-dragonfire-nightly-KDE.log
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.iso $next/kanotix64-dragonfire-nightly-KDE.iso
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix64-dragonfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-dragonfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix64-dragonfire-nightly-KDE.iso.md5
fi

lb clean
lb config -d wheezy -p "kanotix-kde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386
echo Kanotix dragonfire-nightly Dragonfire32 $d$v KDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix32-dragonfire-nightly-${d}${v}-KDE.iso ]; then
        cd -
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.log $next/kanotix32-dragonfire-nightly-KDE.log
else
        md5sum -b kanotix32-dragonfire-nightly-${d}${v}-KDE.iso > kanotix32-dragonfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix32-dragonfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.packages $next/kanotix32-dragonfire-nightly-KDE.packages
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.log $next/kanotix32-dragonfire-nightly-KDE.log
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.iso $next/kanotix32-dragonfire-nightly-KDE.iso
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix32-dragonfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-dragonfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix32-dragonfire-nightly-KDE.iso.md5
fi

lb clean
lb config -d wheezy -p "kanotix-lxde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64
echo Kanotix dragonfire-nightly Dragonfire64 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso ]; then
        cd -
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.log $next/kanotix64-dragonfire-nightly-LXDE.log
else
        md5sum -b kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso > kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.packages $next/kanotix64-dragonfire-nightly-LXDE.packages
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.log $next/kanotix64-dragonfire-nightly-LXDE.log
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso $next/kanotix64-dragonfire-nightly-LXDE.iso
        ln -s $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix64-dragonfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-dragonfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix64-dragonfire-nightly-LXDE.iso.md5
fi

lb clean
lb config -d wheezy -p "kanotix-lxde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386
echo Kanotix dragonfire-nightly Dragonfire32 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso ]; then
        cd -
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.log $next/kanotix32-dragonfire-nightly-LXDE.log
else
        md5sum -b kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso > kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.packages $next/kanotix32-dragonfire-nightly-LXDE.packages
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.log $next/kanotix32-dragonfire-nightly-LXDE.log
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso $next/kanotix32-dragonfire-nightly-LXDE.iso
        ln -s $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix32-dragonfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-dragonfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix32-dragonfire-nightly-LXDE.iso.md5
fi

################### SPITFIRE ###################

DISTRO=jessie
rm -rf cache tmpfs/cache
sed -i 's/\(export LB_DISTRIBUTION=\).*/\1"'$DISTRO'"/' auto/config

lb clean
lb config -d $DISTRO -p "kanotix-kde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix spitfire-nightly Spitfire64 $d$v KDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-spitfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-spitfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix64-spitfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix64-spitfire-nightly-${d}${v}-KDE.iso ]; then
        cd -
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE.log $next/kanotix64-spitfire-nightly-KDE.log
else
        md5sum -b kanotix64-spitfire-nightly-${d}${v}-KDE.iso > kanotix64-spitfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix64-spitfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE.packages $next/kanotix64-spitfire-nightly-KDE.packages
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE.log $next/kanotix64-spitfire-nightly-KDE.log
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE.iso $next/kanotix64-spitfire-nightly-KDE.iso
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix64-spitfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-spitfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix64-spitfire-nightly-KDE.iso.md5
fi

lb clean
lb config -d $DISTRO -p "kanotix-kde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix spitfire-nightly Spitfire32 $d$v KDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-spitfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-spitfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix32-spitfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix32-spitfire-nightly-${d}${v}-KDE.iso ]; then
        cd -
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE.log $next/kanotix32-spitfire-nightly-KDE.log
else
        md5sum -b kanotix32-spitfire-nightly-${d}${v}-KDE.iso > kanotix32-spitfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix32-spitfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE.packages $next/kanotix32-spitfire-nightly-KDE.packages
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE.log $next/kanotix32-spitfire-nightly-KDE.log
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE.iso $next/kanotix32-spitfire-nightly-KDE.iso
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix32-spitfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-spitfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix32-spitfire-nightly-KDE.iso.md5
fi

lb clean
lb config -d $DISTRO -p "kanotix-lxde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix spitfire-nightly Spitfire64 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix64-spitfire-nightly-${d}${v}-LXDE.iso ]; then
        cd -
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.log $next/kanotix64-spitfire-nightly-LXDE.log
else
        md5sum -b kanotix64-spitfire-nightly-${d}${v}-LXDE.iso > kanotix64-spitfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix64-spitfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.packages $next/kanotix64-spitfire-nightly-LXDE.packages
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.log $next/kanotix64-spitfire-nightly-LXDE.log
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.iso $next/kanotix64-spitfire-nightly-LXDE.iso
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix64-spitfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-spitfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix64-spitfire-nightly-LXDE.iso.md5
fi

lb clean
lb config -d $DISTRO -p "kanotix-lxde-master firefox" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix spitfire-nightly Spitfire32 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix32-spitfire-nightly-${d}${v}-LXDE.iso ]; then
        cd -
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.log $next/kanotix32-spitfire-nightly-LXDE.log
else
        md5sum -b kanotix32-spitfire-nightly-${d}${v}-LXDE.iso > kanotix32-spitfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix32-spitfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.packages $next/kanotix32-spitfire-nightly-LXDE.packages
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.log $next/kanotix32-spitfire-nightly-LXDE.log
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.iso $next/kanotix32-spitfire-nightly-LXDE.iso
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix32-spitfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-spitfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix32-spitfire-nightly-LXDE.iso.md5
fi

## gfxdetect
#git checkout config/binary_grub/grub.cfg

lb clean
lb config -d $DISTRO -p "kanotix-master firefox google-chrome virtualbox android steam xbmc gfxdetect" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix spitfire-nightly Spitfire64 $d$v KDE-special > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.packages
cp tmpfs/binary.log $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.log
cd $target
if [ ! -f kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso ]; then
        cd -
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.log $next/kanotix64-spitfire-nightly-KDE-special.log
else
        md5sum -b kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso > kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso.md5
        zsyncmake kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso
        cd -
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.packages $next/kanotix64-spitfire-nightly-KDE-special.packages
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.log $next/kanotix64-spitfire-nightly-KDE-special.log
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso $next/kanotix64-spitfire-nightly-KDE-special.iso
        ln -s $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso.zsync $next/kanotix64-spitfire-nightly-KDE-special.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-spitfire-nightly-${d}${v}-KDE-special.iso.md5 > $next/kanotix64-spitfire-nightly-KDE-special.iso.md5
fi

lb clean
lb config -d $DISTRO -p "kanotix-master firefox google-chrome virtualbox android steam xbmc gfxdetect" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix spitfire-nightly Spitfire32 $d$v KDE-special > config/chroot_local-includes/etc/kanotix-version 
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.packages
cp tmpfs/binary.log $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.log
cd $target
if [ ! -f kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso ]; then
        cd -
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.log $next/kanotix32-spitfire-nightly-KDE-special.log
else
        md5sum -b kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso > kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso.md5
        zsyncmake kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso
        cd -
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.packages $next/kanotix32-spitfire-nightly-KDE-special.packages
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.log $next/kanotix32-spitfire-nightly-KDE-special.log
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso $next/kanotix32-spitfire-nightly-KDE-special.iso
        ln -s $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso.zsync $next/kanotix32-spitfire-nightly-KDE-special.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-spitfire-nightly-${d}${v}-KDE-special.iso.md5 > $next/kanotix32-spitfire-nightly-KDE-special.iso.md5
fi


################### STEELFIRE ###################

git checkout auto/config
DISTRO=stretch
rm -rf cache tmpfs/cache
sed -i 's/\(export LB_DISTRIBUTION=\).*/\1"'$DISTRO'"/' auto/config

# lxde 64
lb clean
lb config -d $DISTRO -p "kanotix-lxde-master firefox retabell" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix steelfire-nightly Steelfire64 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix64-steelfire-nightly-${d}${v}-LXDE.iso ]; then
        cd -
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.log $next/kanotix64-steelfire-nightly-LXDE.log
else
        md5sum -b kanotix64-steelfire-nightly-${d}${v}-LXDE.iso > kanotix64-steelfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix64-steelfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.packages $next/kanotix64-steelfire-nightly-LXDE.packages
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.log $next/kanotix64-steelfire-nightly-LXDE.log
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.iso $next/kanotix64-steelfire-nightly-LXDE.iso
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix64-steelfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-steelfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix64-steelfire-nightly-LXDE.iso.md5
fi
#
# lxde 32
lb clean
lb config -d $DISTRO -p "kanotix-lxde-master firefox retabell" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix steelfire-nightly Steelfire32 $d$v LXDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.packages
cp tmpfs/binary.log $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.log
cd $target
if [ ! -f kanotix32-steelfire-nightly-${d}${v}-LXDE.iso ]; then
        cd -
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.log $next/kanotix32-steelfire-nightly-LXDE.log
else
        md5sum -b kanotix32-steelfire-nightly-${d}${v}-LXDE.iso > kanotix32-steelfire-nightly-${d}${v}-LXDE.iso.md5
        zsyncmake kanotix32-steelfire-nightly-${d}${v}-LXDE.iso
        cd -
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.packages $next/kanotix32-steelfire-nightly-LXDE.packages
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.log $next/kanotix32-steelfire-nightly-LXDE.log
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.iso $next/kanotix32-steelfire-nightly-LXDE.iso
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.iso.zsync $next/kanotix32-steelfire-nightly-LXDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-steelfire-nightly-${d}${v}-LXDE.iso.md5 > $next/kanotix32-steelfire-nightly-LXDE.iso.md5
fi
#
# kde 64
lb clean
lb config -d $DISTRO -p "kanotix-kde-master firefox retabell" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a amd64 --initsystem systemd
echo Kanotix steelfire-nightly Steelfire64 $d$v KDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix64.iso; mv kanotix64.iso $target/kanotix64-steelfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix64-steelfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix64-steelfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix64-steelfire-nightly-${d}${v}-KDE.iso ]; then
        cd -
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-KDE.log $next/kanotix64-steelfire-nightly-KDE.log
else
        md5sum -b kanotix64-steelfire-nightly-${d}${v}-KDE.iso > kanotix64-steelfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix64-steelfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-KDE.packages $next/kanotix64-steelfire-nightly-KDE.packages
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-KDE.log $next/kanotix64-steelfire-nightly-KDE.log
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-KDE.iso $next/kanotix64-steelfire-nightly-KDE.iso
        ln -s $target/kanotix64-steelfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix64-steelfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix64-steelfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix64-steelfire-nightly-KDE.iso.md5
fi
#
# kde 32
lb clean
lb config -d $DISTRO -p "kanotix-kde-master firefox retabell" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix steelfire-nightly Steelfire32 $d$v KDE > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-steelfire-nightly-${d}${v}-KDE.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-steelfire-nightly-${d}${v}-KDE.packages
cp tmpfs/binary.log $target/kanotix32-steelfire-nightly-${d}${v}-KDE.log
cd $target
if [ ! -f kanotix32-steelfire-nightly-${d}${v}-KDE.iso ]; then
        cd -
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-KDE.log $next/kanotix32-steelfire-nightly-KDE.log
else
        md5sum -b kanotix32-steelfire-nightly-${d}${v}-KDE.iso > kanotix32-steelfire-nightly-${d}${v}-KDE.iso.md5
        zsyncmake kanotix32-steelfire-nightly-${d}${v}-KDE.iso
        cd -
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-KDE.packages $next/kanotix32-steelfire-nightly-KDE.packages
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-KDE.log $next/kanotix32-steelfire-nightly-KDE.log
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-KDE.iso $next/kanotix32-steelfire-nightly-KDE.iso
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-KDE.iso.zsync $next/kanotix32-steelfire-nightly-KDE.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-steelfire-nightly-${d}${v}-KDE.iso.md5 > $next/kanotix32-steelfire-nightly-KDE.iso.md5
fi
#
# eeepc4G with LXDE
lb clean
lb config -d $DISTRO -p "kanotix-eeepc4G firefox retabell" --bootloader grub2 --tmpfs true --tmpfs-options size=12G --apt-http-proxy "http://127.0.0.1:3142" --cache-packages false --gfxoverlays false -a i386 --initsystem systemd
echo Kanotix steelfire-nightly Steelfire32 $d$v eeepc4G > config/chroot_local-includes/etc/kanotix-version
lb build; cd tmpfs; ./isohybrid-acritox kanotix32.iso; mv kanotix32.iso $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso; cd ..
cp tmpfs/binary.packages $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.packages
cp tmpfs/binary.log $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.log
cd $target
if [ ! -f kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso ]; then
        cd -
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-steelfire-nightly-eeepc4G.log
else
        md5sum -b kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso > kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso.md5
        zsyncmake kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso
        cd -
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.packages $next/kanotix32-steelfire-nightly-eeepc4G.packages
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.log $next/kanotix32-steelfire-nightly-eeepc4G.log
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso $next/kanotix32-steelfire-nightly-eeepc4G.iso
        ln -s $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso.zsync $next/kanotix32-steelfire-nightly-eeepc4G.iso.zsync
        sed "s/${d}${v}-//" $target/kanotix32-steelfire-nightly-${d}${v}-eeepc4G.iso.md5 > $next/kanotix32-steelfire-nightly-eeepc4G.iso.md5
fi

git checkout auto/config

rm -rf $next/../latest
mv $next $next/../latest
