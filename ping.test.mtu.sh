#!/bin/bash
# Usage: command [address] [timeout]
# Copyright (C) Konstantin Mukhin Al.
# Size of ICMP header = 8 bytes
# Size of IP header is variable 20-60  bytes. Normally it is 20 bytes.

address=127.0.0.1
[[ -n $1 ]] && address=$1
timeout=1
[[ -n $2 ]] && timeout=$2

for i in {1..200}; do
# mtu=$(echo "1450+$i" | bc)
 let mtu=i+1450
 printf "%5d " ${mtu}
 if ret=$(ping -w${timeout} -q -c1 -s${mtu} ${address} 2>/dev/null); then
    echo pass;
 else
    echo failed;
 fi
done
