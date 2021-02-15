#!/bin/bash
# Copyright (C) Konstantin Mukhin Al.

INTERVAL="1"  # update interval in seconds

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BGRED=$(tput setab 4)
# bold traffic is higher than TRESH
THRESH=10000000
# print total bytes statistic every TOTALTIME sec
# don't print if TOTALTIME=0
TOTALTIME=60

IFNAME=$1
: ${IFNAME:=eth0}

if [[ -z "${IFNAME}" ]]; then
        echo
        echo usage: $0 [network-interface]
        echo
        echo e.g. $0 eth0
        echo
        exit
fi

echo "Probing interface: ${IFNAME}"
if ! [[ -d /sys/class/net/${IFNAME} ]] ; then
    echo -e "Device \"${BOLD}${IFNAME}${NORMAL}\" does not exist."
    IFNAME=$(ip -br link | grep -m1 ' UP ' | cut -f1 -d' ')
    echo "Probing interface: ${IFNAME}"
elif ! [[ -d /sys/class/net/${IFNAME} ]] ; then
    echo -e "Device \"${BOLD}${IFNAME}${NORMAL}\" does not exist."
    exit
fi

printheader(){
	printf "%19s %10s %10s %10s\n" "time" "if" "tx bits" "rx bits"
}

IFDEV="/sys/class/net/${IFNAME}"

RLAST=$(cat ${IFDEV}/statistics/rx_bytes)
TLAST=$(cat ${IFDEV}/statistics/tx_bytes)

if [[ ${TOTALTIME} -gt 0 ]]; then
	lasttime=$(date +%s)
	lasttime=$(( ${lasttime}-${lasttime}%${TOTALTIME} ))
fi

printheader
while true
do
	R1=$(cat ${IFDEV}/statistics/rx_bytes)
	T1=$(cat ${IFDEV}/statistics/tx_bytes)
        sleep ${INTERVAL}
	R2=$(cat ${IFDEV}/statistics/rx_bytes)
	T2=$(cat ${IFDEV}/statistics/tx_bytes)
# bits
	TBPS=$(( (${T2} - ${T1})*8 ))
        RBPS=$(( (${R2} - ${R1})*8 ))
        [[ ${TBPS} -ge ${THRESH} ]] && BT=${BOLD} || BT=${NORMAL}
        [[ ${RBPS} -ge ${THRESH} ]] && BR=${BOLD} || BR=${NORMAL}
	printf "%19s %10s ${BT}%10s ${BR}%10s${NORMAL}\n" "$(date +"%F %T")" "${IFNAME}" "$(numfmt --to=si ${TBPS})" "$(numfmt --to=si ${RBPS})"
	if [[ ${TOTALTIME} -gt 0 ]]; then
		curtime=$(date +%s)
		curtime=$(( ${curtime}-${curtime}%${TOTALTIME} ))
		if [[ $curtime -ne $lasttime ]]; then
			TB=$(( $T2-$TLAST )) 
			RB=$(( $R2-$RLAST )) 
			echo '--------------------------'TOTAL BYTES last ${TOTALTIME} sec:
			printf "%19s %10s ${BT}%10s ${BR}%10s${NORMAL}\n" "$(date +"%F %T")" "${IFNAME}" "$(numfmt --to=si ${TB})" "$(numfmt --to=si ${RB})"
			# echo 'send' $(($T2-$TLAST)) 'receive: '$(($R2-$RLAST)) 	
			echo '--------------------------'
			printheader
			TLAST=${T2}
			RLAST=${R2}
			lasttime=${curtime}
		fi
	fi
done

