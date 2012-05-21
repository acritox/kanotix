#!/bin/bash
# ./combine_iso.bash kanotix64.iso kanotix32.iso kanotix-2in1.iso

wd=tmp
iso=1
isos=()

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
for src in iso*/
do
	grep -q amd64 "$src/.disk/info" && bit=64 || bit=32
	rsync -Ha --ignore-existing "$src" out/
	mv out/live out/live$bit || :
done

# we need only one memtest
mkdir out/live
mv "$(ls -t out/live*/memtest* | tail -n1)" out/live/
rm -f out/live?*/memtest*

# generate grub.cfg
{ read head; read block; read tail; } < <(cat out/boot/grub/grub.cfg | tr '\n' '\a' | sed 's/\a#####\a/\n/g')
entry() { tr '\a' '\n' <<<"$block" | sed "s/\/live\/\(vmlinuz[^ ]*\)/\/live$1\/\1 live-media-path=live$1/g; s/\/live\//\/live$1\//g; s/Kanotix\(32\|64\|\)/Kanotix$1/g"; }
tr '\a' '\n' <<<"$head" > out/boot/grub/grub.cfg
cat <<eof >> out/boot/grub/grub.cfg
if cpuid -l ; then
if [ \$efi_arch != x86 ] ; then
$(entry 64)
fi
fi
if [ \$efi_arch != x64 ] ; then
$(entry 32)
fi
eof
tr '\a' '\n' <<<"$tail" >> out/boot/grub/grub.cfg

wget -qO- "http://git.acritox.com/kanotix/plain/config/binary_iso/isoimage.sort" | sed "s/^binary/out$/" > isoimage.sort
genisoimage -J -l -cache-inodes -allow-multidot -A "$opt_appid" -publisher "$opt_pubid" -p "$opt_preid" -V "$opt_volid" -no-emul-boot -boot-load-size 4 -boot-info-table -r -b boot/grub/grub_eltorito -sort isoimage.sort -o "$out" out
cd -
