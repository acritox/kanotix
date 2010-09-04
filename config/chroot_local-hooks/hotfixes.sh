#!/bin/sh
if [ "$(id -u)" != 0 ]; then
 echo Error: You must be root to run this script!
 exit 1
fi

# re-enable powerbutton
if [ -f /etc/powersave/events ]; then
 sed -i 's/^\(EVENT_BUTTON_POWER=\).*/\1"wm_shutdown"/' /etc/powersave/events
 pidof powersaved >/dev/null && /etc/init.d/powersaved restart
fi

# vim tuning
if [ -d /etc/vim ]; then
 rm -f /etc/vim/vimrc.local
cat <<EOT > /etc/vim/vimrc.local
syntax on
set background=dark
set showmatch          " Show matching brackets.
set pastetoggle=<F10>
EOT
fi

# fix kdm/gdm/xdm/wdm startup
for x in kdm gdm xdm wdm; do
 if [ -x /etc/init.d/$x ]; then
  update-rc.d -f $x remove
  update-rc.d $x start 99 5 . stop 01 0 1 2 3 4 6 .
 fi
done

# init 5 as default
sed -i s/id:.:initdefault:/id:5:initdefault:/ /etc/inittab

# enable textlogins for runlevel 4/5
sed -i 's/\([1-6]:23\):/\145:/' /etc/inittab

insserv live-config
insserv -r console-setup # we don't want to run console-setup - console-setup is only installed because we need its setupcon-binary for keyboard-configuration

# workarounds to fix old kanotix installs
rm -f /etc/profile /etc/environment
cp /usr/share/base-files/profile /etc
rm -rf /etc/sysconfig

# rm/cp/mv aliases and bash completion for login shell
cat <<EOT >> /etc/profile

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOT
