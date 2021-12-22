#!/bin/sh

#cat <<EOF | xmenu -r | sh >$HOME/log 2>&1 &
cat <<EOF | xmenu -r | sh &
Applications
	spacefm
	st
	firefox	firefox-bin	
	feh	feh ~/multi/wallpapers/*
	sxiv	sxiv -t  ~/multi/wallpapers/*
	vim	st -e vim
	geany	geany
	gimp	gimp
	waterfox	waterfox
	mutt	st -e mutt
	transmission	transmission-gtk
	alsa mixer	st -e alsamixer
System 
	Look & Feel	lxappearance
	Resources	st -e top
Leave
	Kill	xkill
	Exit	pkill -KILL -u $USER
	Reboot	doas reboot
	Shutdown	doas poweroff
EOF


