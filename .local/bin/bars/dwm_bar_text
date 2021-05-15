#!/bin/sh

mail() {
	mail=`curl -su USER:PASSWD https://mail.google.com/mail/feed/atom || echo "<fullcount>unknown number of</fullcount>"`
	mail=`echo "$mail" | grep -oPm1 "(?<=<fullcount>)[^<]+" `
	echo "inb: $mail"
}

 updates() {
	updates=$(checkupdates 2> /dev/null | wc -l )  
	echo "pcm: $updates"
}

weather() {
	weather=$(curl 'https://wttr.in/YOURCITY,YOURCOUNTRY?format=%t')
	echo "wea: $weather"
}

cputemp() {
	cputemp=$(sensors | grep Core | awk '{print substr($3, 2, length($3)-5)}' | tr "\\n" " " | sed 's/ /°C  /g' | sed 's/  $//')
	echo "tem: $cputemp"
}

cpufrequency() {
	cpu=$(awk '{u=$2+$4; t=$2+$4+$5;if (NR==1){u1=u; t1=t;} else printf("%d%%", ($2+$4-u1) * 100 / (t-t1) "%");}' <(grep 'cpu ' /proc/stat) <(sleep 0.5; grep 'cpu ' /proc/stat))
	echo "cpu: $cpu"%
}

ram() {
	mem=$(free -h | awk '/Mem:/ { print $3 }' | cut -f1 -d 'i')
	echo "mem: $mem"
}

alsa() {
    volume="$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')" 
	echo "vol: $volume"
}

upspeed() {
	T1=`cat /sys/class/net/enp2s0/statistics/tx_bytes`
	sleep 1
	T2=`cat /sys/class/net/enp2s0/statistics/tx_bytes`
	TBPS=`expr $T2 - $T1`
	TKBPS=`expr $TBPS / 1024`
	printf  "up: $TKBPS kb"
}

downspeed() {
	R1=`cat /sys/class/net/enp2s0/statistics/rx_bytes`
	sleep 1
	R2=`cat /sys/class/net/enp2s0/statistics/rx_bytes`
	RBPS=`expr $R2 - $R1`
	RKBPS=`expr $RBPS / 1024`
	printf  "do: $RKBPS kb"
}

clock() {
	time=$(date +"%b %d, %R")
	echo "$time"
}

while true; do
	xsetroot -name "$(updates) | $(mail) | $(cpufrequency) | $(ram) | $(alsa) | $(upspeed) | $(downspeed) | $(clock) |" #xsetroot -name "^c#3AFF00^$(updates) | ^c#B5B5B5^$(mail) | ^c#3AFF00^$(cpufrequency) | ^c#B5B5B5^$(ram) | ^c#3AFF00^$(upspeed) | ^c#B5B5B5^$(downspeed) | ^c#3AFF00^$(alsa) | ^c#B5B5B5^$(clock) |"
	sleep 2
done &


