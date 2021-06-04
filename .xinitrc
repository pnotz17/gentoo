#!/bin/sh

# X settings
xrandr --output VGA1 --mode 1408x792_60.00 --scale-from 1920x1080 &
xset r rate 400 100

# dbus
if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
 eval `dbus-launch --sh-syntax`
 echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi

# Autostart
~/.local/bin/bars/gentoo_bar &
~/.local/bin/xsession_destroyah &
~/.fehbg &
xclickroot -r ~/git/xmenu/xmenu.sh &
dunst & 

#dwm start loop
while true; do
	exec dbus-launch --exit-with-session dwm >/tmp/wm.log 2>&1
done

