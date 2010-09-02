#!/bin/sh
if test $(id -u) != 0; then
 echo Error: You must be root to run this script!
 exit 1
fi
# reinstall grub
if [ -w /boot/grub/menu.lst ] && false; then
 OLDGRUB=$(awk -F= '/^# groot/{print $2}' /boot/grub/menu.lst)
 if [ -n "$OLDGRUB" ]; then
  grub-install --recheck --no-floppy "$OLDGRUB" &>/dev/null
  grub-install --recheck --no-floppy "$OLDGRUB"
 fi
 # add quiet option if not there
 KOPT=$(awk '/# kopt/' /boot/grub/menu.lst)
 if [ -n "$KOPT" ]; then
  case  $KOPT in
   *quiet*) ;;
   *)
   	perl -pi -e "s|^$KOPT|$KOPT quiet|" /boot/grub/menu.lst
	update-grub
   	;;
  esac
 fi
fi
# use new message file
if [ -f /boot/message.hd ]; then
 rm -f /boot/message
 ln -s message.hd /boot/message
fi
# activate splashy
FROZEN=
[ -f /etc/frozen-rc.d ] && FROZEN=1
[ -r /etc/default/distro ] && . /etc/default/distro
if [ -x /etc/init.d/splashy-init -a "$FLL_DISTRO_MODE" != "live" ]; then
 [ -x /usr/sbin/unfreeze-rc.d ] && /usr/sbin/unfreeze-rc.d
 update-rc.d -f splashy-init remove
 update-rc.d splashy-init start 03 S . stop 01 0 6 .
 [ -n "$FROZEN" -a -x /usr/sbin/freeze-rc.d ] && /usr/sbin/freeze-rc.d
fi
# config splashy
# fix ksplash
if [ -d /usr/share/apps/ksplash/Themes/KanotixClouds ]; then
 for x in /root/.kde/share/config/ksplashrc /home/*/.kde/share/config/ksplashrc; do
  [ -w "$x" ] && perl -pi -e 's/Theme=.*/Theme=KanotixClouds/' "$x"
 done
fi
[ -d /etc/splashy/themes/KanotixPenguins ] && splashy_config -s KanotixPenguins
[ -d /etc/splashy/themes/Kanotix64Penguins ] && splashy_config -s Kanotix64Penguins
# fix kdm
rm -f /etc/kde3/kdm/Xservers
perl -pi -e 's/^(MinShowUID)=.*/\1=500/' /etc/kde3/kdm/kdmrc
if [ -d /usr/share/apps/kdm/themes/KanotixPenguins ]; then
 perl -pi -e 's/^#*(UseTheme)=.*/\1=true/' /etc/kde3/kdm/kdmrc
 perl -pi -e 's|^(Theme)=.*|\1=/usr/share/apps/kdm/themes/KanotixPenguins|' /etc/kde3/kdm/kdmrc
fi
if [ -d /usr/share/apps/kdm/themes/Kanotix64Penguins ]; then
 perl -pi -e 's/^#*(UseTheme)=.*/\1=true/' /etc/kde3/kdm/kdmrc
 perl -pi -e 's|^(Theme)=.*|\1=/usr/share/apps/kdm/themes/Kanotix64Penguins|' /etc/kde3/kdm/kdmrc
fi
# kdm background
[ -r /usr/share/wallpapers/kanotix.png ] && perl -pi -e 's|^(Wallpaper)=.*|\1=/usr/share/wallpapers/kanotix.png|' /etc/kde3/kdm/backgroundrc
# fix udev
rm -f /etc/udev/rules.d/40-prism2.rule
