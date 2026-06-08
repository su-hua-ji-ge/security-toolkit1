#!/bin/bash

set -euo pipefail

dip() {
	local ip="$1"  #使用#@可以收到所有的参数
	local sd="$2"
	shift
	for sd in "$@"; do
		if timeout 5 bash -c "echo >/dev/tcp/${ip}/${sd}" 2>/dev/null; then
			echo "ip：$ip,端口$sd通过"
		else
			echo "ip：$ip,端口$sd未开通"
		fi
	done
}

#dip 127.0.0.1 22 80 3306 8080

MAX=3
cs=0
all_ports=$(awk '{print $1}' /tmp/port_list.txt | tr '\n' ' ')
while read sdd; do
	if [ -z "$sdd" ]; then
        continue
    fi
    
    if [ -z "$all_ports" ]; then
            echo "端口文件不存在"
            continue
    fi
    
    if [ "$cs" -ge "$MAX" ]; then
    	wait -n
        cs=$((cs - 1))
    fi
        cs=$((cs + 1))
        dip "$sdd" $all_ports &
done < /tmp/ip_list.txt
wait
