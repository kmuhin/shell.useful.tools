#!/bin/bash
# Usage: command [address] [timeout]
# Copyright (C) Konstantin Mukhin Al.
# Size of ICMP header = 8 bytes
# Size of IP header is variable 20-60  bytes. Normally it is 20 bytes.

address=127.0.0.1
[[ -n $1 ]] && address=$1
timeout=100
[[ -n $2 ]] && timeout=$2

pinger=$(which fping || echo fping)

if ! command -v ${pinger} &>/dev/null; then
 echo "Command '${pinger}' not found" >&2
 exit 1
fi

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
BGRED=$(tput setab 4)
FRED=$(tput setf 4)

count=0
cols=$(tput cols)
#width=$(echo $cols / 11 | bc)
let width=cols/11

echo "address: ${address}"
for i in {1..200}; do
 ((count++))
# mtu=$(echo "1450+$i" | bc)
 let mtu=i+1450
 printf "%s" $mtu
 if ret=$(${pinger} -t${timeout} -c1 -b${mtu} ${address} 2>/dev/null); then
    printf "_%s" pass
 elif ret=$(${pinger} -t${timeout} -c1 -b${mtu} ${address} 2>/dev/null); then
    printf "_%s" pass
 else
    printf "${BGRED}_%s${NORMAL}"  fail
 fi
 if [[ ${count} -ge ${width} ]] ; then
   printf "\n"
   count=0
 else
   printf " "
 fi
done
echo
