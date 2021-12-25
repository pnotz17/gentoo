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
	mutt	st -e mutt
	transmission	transmission-gtk
System 
	look & feel	lxappearance
	top	st -e top
	alsamixer	st -e alsamixer
Exit
	kill	xkill
	killx	pkill -KILL -u $USER
	reboot	doas reboot
	shutdown	doas poweroff
EOF


