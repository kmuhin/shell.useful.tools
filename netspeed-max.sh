#!/bin/bash
# Copyright (C) Konstantin Mukhin Al.

INTERVAL="1"  # update interval in seconds

IFNAME=$1
: ${IFNAME:=eth0}

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BGRED=$(tput setab 4)
FRED=$(tput setf 4)

if [ -z "${IFNAME}" ]; then
        echo
        echo usage: $0 [network-interface]
        echo
        echo e.g. $0 eth0
        echo
        exit
fi

echo "Probing interface: ${IFNAME}"
if ! [[ -d /sys/class/net/${IFNAME} ]] ; then
    echo -e "Device \"${BOLD}${IFNAME}${NORMAL}\" does not exist. Trying to find interfaces."
    if IFNAME=$(ip -br link | grep ' UP ' | cut -f1 -d' '); then
	    echo "Found UP interfaces: ${IFNAME//$'\n'/, }. Use first one."
	    IFNAME=${IFNAME%$'\n'*}
	    echo "Probing interface: ${IFNAME}"
    fi
elif ! [[ -d /sys/class/net/${IFNAME} ]] ; then
    echo -e "Device \"${BOLD}${IFNAME}${NORMAL}\" does not exist."
    exit
fi

TBPSMAX=0
RBPSMAX=0

printf "%19s %10s %20s %20s\n" "time" "if" "tx bits" "rx bits"
while true
do
        R1=`cat /sys/class/net/${IFNAME}/statistics/rx_bytes`
        T1=`cat /sys/class/net/${IFNAME}/statistics/tx_bytes`
        sleep $INTERVAL
        R2=`cat /sys/class/net/${IFNAME}/statistics/rx_bytes`
        T2=`cat /sys/class/net/${IFNAME}/statistics/tx_bytes`
# bits
        TBPS=`echo "($T2 - $T1)*8" | bc`
        RBPS=`echo "($R2 - $R1)*8" | bc`
        [[ ${TBPS} -ge 100000000 ]] && BT=${BOLD} || BT=${NORMAL}
        [[ ${RBPS} -ge 100000000 ]] && BR=${BOLD} || BR=${NORMAL}
        if [[ ${TBPS} -gt ${TBPSMAX} ]] ; then
    	    TBPSMAX=${TBPS}
	    redraw=1
	fi
        if [[ ${RBPS} -gt ${RBPSMAX} ]] ; then
    	    RBPSMAX=${RBPS}
    	    redraw=1
    	fi
    	if [[ "${redraw}" = 1 ]] ; then
    	    redraw=0
    	    echo -en "\033[1A\r\033[K"
    	    printf "%19s %10s %20s %20s\n" "time" "if" "tx bits $(numfmt --to=si ${TBPSMAX})" "rx bits $(numfmt --to=si ${RBPSMAX})"
    	fi
# bytes
#        TBPS=`expr ($T2 - $T1)*8`
#        RBPS=`expr ($R2 - $R1)*8`
#        TKBPS=`expr $TBPS / 1024`
#        RKBPS=`expr $RBPS / 1024`
#        echo "TX ${IFNAME}: $TKBPS kB/s RX ${IFNAME}: $RKBPS kB/s"

#        printf "\r\033[K%5s %10s %10s" "${IFNAME}" "$(numfmt --to=iec ${TBPS})" "$(numfmt --to=iec ${RBPS})"
	 echo -en "\r\033[K"
	 printf "%19s %10s ${BT}%20s ${BR}%20s${NORMAL}" "$(date +"%F %T")" "${IFNAME}" "$(numfmt --to=si ${TBPS})" "$(numfmt --to=si ${RBPS})"
done
