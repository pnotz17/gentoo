#!/bin/sh

#cat <<EOF | xmenu -r | sh >$HOME/log 2>&1 &
cat <<EOF | xmenu -r | sh &
File manager	spacefm
Terminal 	st
Web browser	firefox-bin	
Accessories
	feh	feh ~/media/wallpapers/*
	sxiv	sxiv -t  ~/media/wallpapers/*
	vim	st -e nvim
Development
	geany	geany
Graphics
	gimp	gimp
Network
	firefox	firefox
	mutt	st -e mutt
	transmission	transmission-gtk
Multimedia
	alsa mixer	st -e alsamixer
Office
Settings 
	Customize Look & Feel	lxappearance
System 
	htop	st -e htop
Kill	xkill

Leave
	Exit		pkill -KILL -u pnotz17
	Reboot			doas reboot
	Shutdown		doas poweroff
EOF


