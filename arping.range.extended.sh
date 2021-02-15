#!/bin/bash
# Copyright (C) Konstantin Mukhin Al.
# This script uses nonstandard tool from 
# http://www.habets.pp.se/synscan/programs.php?prog=arping
# https://github.com/ThomasHabets/arping
#
# Usage: command [address] [interface]

prefix="172.16.9"
[[ -n $1 ]] && prefix=$1
interface="eth0"
[[ -n $2 ]] && interface=$2
timeout=0.1
range=$(echo {1..254})


if ! [[ -d /sys/class/net/${interface} ]] ; then
    echo -e "Device '${interface}' does not exist."
    exit 1
fi

# check program existence
cmd='arping'
if ! command -v ${cmd} &>/dev/null; then
 echo "Command '${cmd}' not found" >&2
 exit 1
fi

if ! ret=$(arping -h 2>&1 | fgrep Thomas) ; then
    echo "Incorrect version arping" >&2
    exit 1;
fi

# \r - return caret
# \033[K - clear line
for i in ${range}; do
    ipaddr=${prefix}.${i}
    echo -en "\r\033[K${ipaddr}" >&2
    
    if ret=$(arping -r -W${timeout} -c1 -0 -i ${interface} ${ipaddr}); then
        echo -en "\r\033[K" >&2
        printf "%-15s %s\n" "${ipaddr}" "${ret}"
    fi
done

echo -e "\r\033[KDone!" >&2
