#!/bin/bash
# Copyright (C) Konstantin Mukhin Al.
#
# Usage: command [address] [interface]

function dnsquery()
{
    if  dnsret=$(getent hosts $1); then
#remove ip
      dnsret=${dnsret##* }
    fi
    echo ${dnsret}
#set exit code
    [[ -n ${dnsret} ]] && true || false
}


# check program existence
cmd='arping'
if ! command -v ${cmd} &>/dev/null; then
 echo "Command '${cmd}' not found" >&2
 exit 1
fi

echo "found interfaces:"
listinterfaces=$(ip -4 -br addr | grep ' UP ')
echo "${listinterfaces}"

listinterfaces=$(echo "${listinterfaces}" | head -n1 | xargs)
ipaddr=${listinterfaces##* }
interface=${listinterfaces%% *}
#prefix="172.16.9"
#interface="eth0"
prefix=$(echo ${ipaddr} | cut -d'.' -f1,2,3)
[[ -n $1 ]] && interface=$1
[[ -n $2 ]] && prefix=$2

timeout=0.5
range=$(echo {1..254})

if ! [[ -d /sys/class/net/${interface} ]] ; then
    echo -e "Device '${interface}' does not exist."
    exit 1
fi

# \r - return caret
# \033[K - clear line

for i in ${range}; do
    ipaddr=${prefix}.${i}
    echo -en "\r\033[K${ipaddr}" >&2
    
    if ret=$(${cmd} -w${timeout} -c1 -I ${interface} ${ipaddr}); then
        mac=`echo $ret | grep -oP "((?:[0-9a-fA-F]{2}[:-]?){5}[0-9a-fA-F]{2})"`
	dnsname=$(dnsquery ${ipaddr})
        echo -en "\r\033[K" >&2
        printf "%-15s %-18s %s\n" "${ipaddr}" "${mac}" "${dnsname}"
    fi
done

echo -e "\r\033[KDone!" >&2
