#!/bin/bash
# ./combine_iso.bash kanotix64.iso kanotix32.iso kanotix-2in1.iso

wd=tmp
iso=1
isos=()
sfx=()
bit=()

cleanup ()
{
	while ((iso--))
	do
		[ -d "$wd/iso$iso" ] || continue
		umount "$wd/iso$iso" || umount -l "$wd/iso$iso" | :
		rm -rf "$wd/iso$iso"
	done
	rm -rf "$wd"
}
trap cleanup EXIT HUP INT QUIT TERM

while [ "$2" ]
do
	file="$1"
	case "$(basename "$file")" in
	*.iso)
		mkdir -p "$wd/iso$iso"
		unset is_bootable
		while IFS=: read var val
		do
			case "$var" in
			"System id") opt_sysid=$val;;
			"Volume id") opt_volid=$val;;
			"Volume set id") opt_setid=$val;;
			"Publisher id") opt_pubid=$val;;
			"Data preparer id") opt_preid=$val;;
			"Application id") opt_appid=$val;;
			"    Key 55 AA") is_bootable=1;;
			esac
		done < <(isoinfo -d -i "$1")
		if [ -z "$is_bootable" ]; then
			rm -rf "$wd/iso$iso"
			echo "Ignored $file because it is not a bootable iso" >&2
			shift
			continue
		fi
		if mount -o loop "$1" "$wd/iso$iso" &>/dev/null; then
			isos[$iso]="$file"
			((iso++))
		else
			rm -rf "$wd/iso$iso"
			echo "Error: $file could not be loop-mounted as iso" >&2
		fi
		;;
	esac
	shift
done

out="$1"
[ "${out:0:1}" = / ] || out="$PWD/$out"
case "$out" in
*.iso)
	if [ -e "$out" ]; then
		echo -n "Do you really want to overwrite $out? "
		read yn
		case $yn in y*|j*);; *) exit;; esac
	fi
	;;
*)
	echo "Unknown output format: $out"
	exit
	;;
esac

cd "$wd"
mkdir out
group64=
group32=
for i in $(seq $[iso-1])
do
	echo "Copying ${isos[$i]}..."
	rsync -Ha --ignore-existing "iso$i/" out/
	if grep -q amd64 "iso$i/.disk/info"; then
		bit[$i]=64
		group64+=" $i"
	else
		bit[$i]=32
		group32+=" $i"
	fi
	[ $iso -gt 3 ] && suffix=$i || suffix=${bit[$i]}
	while read -e -p "rename live-folder to: live" -i "$suffix" suffix
	do
		[ ! -e out/live$suffix ] && break
		echo "Error! live$suffix already exists!"
	done
	sfx[$i]="$suffix"
	sfx[$i]="$suffix"
	mv out/live out/live$suffix || :
done

# we need only one memtest
mkdir out/live
mv "$(ls -t out/live*/memtest* | tail -n1)" out/live/
rm -f out/live?*/memtest*

rm -f out/md5sum.txt out/boot.catalog

# generate grub.cfg
{ read head; read block; read tail; } < <(cat out/boot/grub/grub.cfg | tr '\n' '\a' | sed 's/\a#####\a/\n/g')
entry() { tr '\a' '\n' <<<"$block" | sed "s/\/live\/\(vmlinuz[^ ]*\)/\/live${sfx[$1]}\/\1 live-media-path=live${sfx[$1]}/g; s/\/live\//\/live${sfx[$1]}\//g; s/Kanotix\(32\|64\|\)/Kanotix${bit[$1]}/g"; }
tr '\a' '\n' <<<"$head" > out/boot/grub/grub.cfg

if [ "$group64" ]; then
cat <<eof >> out/boot/grub/grub.cfg

# 64bit ################################
if cpuid -l ; then
if [ \$efi_arch != x86 ] ; then
eof
for i in $group64
do
entry $i >> out/boot/grub/grub.cfg
done
cat <<eof >> out/boot/grub/grub.cfg
fi
fi
eof
fi

if [ "$group32" ]; then
cat <<eof >> out/boot/grub/grub.cfg

# 32bit ################################
if [ \$efi_arch != x64 ] ; then
eof
for i in $group32
do
entry $i >> out/boot/grub/grub.cfg
done
cat <<eof >> out/boot/grub/grub.cfg
fi
eof
fi

tr '\a' '\n' <<<"$tail" >> out/boot/grub/grub.cfg

vim out/boot/grub/grub.cfg

wget -qO- "http://git.acritox.com/kanotix/plain/config/binary_iso/isoimage.sort" | sed "s/^binary/out$/" > isoimage.sort

echo "Generating md5sums.txt..."
cd out
find . -type f \
        \! -path './isolinux/isolinux.bin' \
        \! -path './boot/grub/stage2_eltorito' \
        \! -path './boot/grub/grub_eltorito' \
        \! -path './boot.catalog' \
        \! -path './boot.isohybrid' \
        \! -path './md5sum.txt' \
        \! -path './sha1sum.txt' \
        \! -path './sha256sum.txt' \
-print0 | sort -z | xargs -0 md5sum > md5sum.txt
cd ..

genisoimage -J -l -cache-inodes -allow-multidot -A "$opt_appid" -publisher "$opt_pubid" -p "$opt_preid" -V "$opt_volid" -no-emul-boot -boot-load-size 4 -boot-info-table -r -b boot/grub/grub_eltorito -sort isoimage.sort -o "$out" out
cd -

