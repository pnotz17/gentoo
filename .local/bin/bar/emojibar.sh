#!/bin/sh

LINUX() {
LINUX=$(uname -r)
echo  "🏠 $LINUX"
}

MAIL() {
COUNT=`curl -su USER:PASS https://mail.google.com/mail/feed/atom || echo "<fullcount>unknown number of</fullcount>"`
COUNT=`echo "$COUNT" | grep -oPm1 "(?<=<fullcount>)[^<]+" `
echo  "📫 $COUNT"
}

UPTIME() {
UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
echo "$UPTIME"
}

DISK() {
hddfree="$(df -Ph /dev/sda1 | awk '$3 ~ /[0-9]+/ {print $4}')"
echo  "💾️ $hddfree"
}

CPUTEMP() {
TEMP=`sensors|awk 'BEGIN{i=0;t=0;b=0}/id [0-9]/{b=$4};/Core/{++i;t+=$3}END{if(i>0){printf("%0.1f\n",t/i)}else{sub(/[^0-9.]/,"",b);print b}}'`"C"
echo "🔥 $TEMP"
}

CPUFREQUENCY() {
CPU=$(awk '{u=$2+$4; t=$2+$4+$5;if (NR==1){u1=u; t1=t;} else printf("%d%%", ($2+$4-u1) * 100 / (t-t1) "%");}' <(grep 'cpu ' /proc/stat) <(sleep 0.5; grep 'cpu ' /proc/stat))
echo "🖥️ $CPU"
}

RAM() {
USED=$(free | awk '/^Mem/ { printf("%.2f%\n", $3/$2 * 100.0) }')
echo "💻 $USED"
} 

CLOCK() {
TIME=$(date +"%b %d, %R")
echo "📆 $TIME"
}

WEATHER() {
FORECAST=$(curl 'https://wttr.in/YOURCITY,YOURCOUNTRY?format=%t')
echo "🌈 $FORECAST"
}

ALSA() {
MONO=$(amixer -M sget Master | grep Mono: | awk '{ print $2 }')
if [ -z "$MONO" ]; then
	MUTED=$(amixer -M sget Master | awk 'FNR == 6 { print $7 }' | sed 's/[][]//g')
	VOL=$(amixer -M sget Master | awk 'FNR == 6 { print $5 }' | sed 's/[][]//g; s/%//g')
else
	MUTED=$(amixer -M sget Master | awk 'FNR == 5 { print $6 }' | sed 's/[][]//g')
	VOL=$(amixer -M sget Master | awk 'FNR == 5 { print $4 }' | sed 's/[][]//g; s/%//g')
fi

if [ "$MUTED" = "off" ]; then
	echo "🔇 MUTED"
else
	if [ "$VOL" -ge 65 ]; then
		echo "🔊 $VOL%"
	elif [ "$VOL" -ge 40 ]; then
		echo "🔉 $VOL%"
	elif [ "$VOL" -ge 0 ]; then
		echo "🔈 $VOL%"	
	fi
fi
}

NETWORK() {
conntype=$(ip route | awk '/default/ { print substr($5,1,1) }')
if [ -z "$conntype" ]; then
echo "‼️"
elif [ "$conntype" = "e" ]; then
echo "🔒️"
elif [ "$conntype" = "w" ]; then
echo "📶"  
fi
printf "%s%s\n" "$icon"
}

UPSPEED() {
T1=`cat /sys/class/net/enp2s0/statistics/tx_bytes`
sleep 1
T2=`cat /sys/class/net/enp2s0/statistics/tx_bytes`
TBPS=`expr $T2 - $T1`
TKBPS=`expr $TBPS / 1024`
printf  "⬆️ $TKBPS kb"
}

DOWNSPEED() {
R1=`cat /sys/class/net/enp2s0/statistics/rx_bytes`
sleep 1
R2=`cat /sys/class/net/enp2s0/statistics/rx_bytes`
RBPS=`expr $R2 - $R1`
RKBPS=`expr $RBPS / 1024`
printf  "⬇️ $RKBPS kb"
}

TORRENT() {
torrents=$(transmission-remote -l)
downloading=$(echo "$torrents" | grep "Downloading\|Up & Down" | wc -l)
paused=$(echo "$torrents" | grep "Stopped" | wc -l)
seeding=$(echo "$torrents" | grep "Seeding" | wc -l)
idle=$(echo "$torrents" | grep "Idle" | wc -l)

echo "📥 $downloading 🛑 $paused 📤 $seeding 🗄️ $idle"
}

while true; do
	#xsetroot -name "[  $(UPTIME)  ] [  $(UPSPEED)  ] [  $(DOWNSPEED)  ] [  $(DISK)  ] [  $(CPUTEMP)  ] [  $(CPUFREQUENCY)  ] [  $(RAM)  ] [  $(ALSA)  ] [  $(CLOCK)  ] [  $(NETWORK)  ]"
	xsetroot -name "|  $(DISK)  |  $(CPUTEMP)  |  $(CPUFREQUENCY)  |  $(RAM)  |  $(ALSA)  |  $(UPSPEED)  |  $(DOWNSPEED)  |  $(CLOCK)  |  $(NETWORK)  |"
	#xsetroot -name "/   $(UPSPEED)   /   $(DOWNSPEED)   /   $(CPUTEMP)   /   $(CPUFREQUENCY)   /   $(RAM)   /   $(ALSA)   /   $(CLOCK)  /   $(NETWORK)   /"
	sleep 2
done &


