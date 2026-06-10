#!/bin/bash

set -euo pipefail
read -p "输入要扫描的ip" ip
read -p "输入要扫描的文件" mbiao
echo "========== 信息收集报告：$ip =========="
echo "[子域名]"
xh() {
	local file="$1"
	while read su; do
		hz=$(curl -s -I --connect-timeout 5 "http://$su" | grep "HTTP" | awk '{print $2}' | tr -d '\r' || true)
		SE=$(curl -s -I "$su" | grep -i "^Server:" | awk '{print $2}' | tr -d '\r' || true)
		for port in 22 80 443 8080 3306; do
		    if timeout 2 bash -c "echo >/dev/tcp/${su}/${port}" 2>/dev/null; then 
		    #>/dev/tcp/这里是IP/这里是目标端口
		    	ports=""
		        ports="${ports} ${port}"  #这里不明白
		    fi
		done
		if [ "${hz:-0}" = "200" ]; then
			echo "$su --> $hz Ser:$SE __端口${ports:-端口未开放} | 成功"
		else
			echo "$su --> $hz $SE __${ports:-端口未开放} | 该目标拒绝了访问"
		fi
	done < "$file"
}
xh "$mbiao"
echo "============================================="
