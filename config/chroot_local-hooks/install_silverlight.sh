#!/bin/bash
[ -x /opt/wine-compholio/bin/wine ] || exit 0
export WINE=/opt/wine-compholio/bin/wine
export WINEARCH=win32
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEPREFIX="/etc/skel/.wine-pipelight/"
export DISPLAY=:1
Xvfb :1 -screen 0 1024x768x16 &
/usr/share/wine-browser-installer/download-missing-files wine-silverlight5.1-installer
/usr/share/wine-browser-installer/install-dependency wine-silverlight5.1-installer
kill $!
apt-get --yes --purge remove xvfb
apt-get --yes --purge autoremove
