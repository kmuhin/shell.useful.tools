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

# looking for up interfaces
# list all interfaces in dict
declare -A aif
while IFS=" " read -r iif istate iip; do
    aif[${iif}]=${iip}
done < <(ip -4 -br addr)

echo "Interfaces in UP:"
listinterfaces=$(ip -4 -br addr | grep ' UP ')
echo "${listinterfaces}"

# xargs - removes multiple spaces
listinterfaces=$(echo "${listinterfaces}" | head -n1 | xargs)
ipaddr=${listinterfaces##* }
prefix=$(echo ${ipaddr} | cut -d'.' -f1,2,3)
interface=${listinterfaces%% *}
if [[ -n $2 ]]; then
    prefix=$2
elif [[ -n $1 ]]; then
    interface=$1
    ipaddr=${aif[${interface}]}
    prefix=$(echo ${ipaddr} | cut -d'.' -f1,2,3)
fi
echo "Will be used: ${interface}, ${prefix}"

arptimeout=2
arpcount=1
range=$(echo {1..254})
numthreads=16

if ! [[ -d /sys/class/net/${interface} ]] ; then
    echo -e "Device '${interface}' does not exist."
    exit 1
fi

function arping_host()
{
    #ipaddr=${1}
    if ret=$(${cmd} -w${arptimeout:-1} -c${arpcount:-1} -I ${interface} ${ipaddr}); then
        mac=`echo $ret | grep -m1 -oP "((?:[0-9a-fA-F]{2}[:-]?){5}[0-9a-fA-F]{2})"`
	dnsname=$(dnsquery ${ipaddr})
        echo -en "\r\033[K" >&2
        printf "%-15s %-18s %s\n" "${ipaddr}" "${mac}" "${dnsname}"
    fi
}


# \r - return caret
# \033[K - clear line

for i in ${range}; do
    ipaddr=${prefix}.${i}
    echo -en "\r\033[K${ipaddr}" >&2
    arping_host ${ipaddr} &

    while (( $(jobs | wc -l) >=${numthreads} )); do
       sleep 0.1
       jobs > /dev/null
    done
done

wait
echo -e "\r\033[KDone!" >&2
