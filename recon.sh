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
		if [ "${hz:-0}" = "200" ]; then
			echo "$su --> $hz $SE __| 成功"
		else
			echo "$su --> $hz $SE __| 该目标拒绝了访问"
		fi
	done < "$file"
}
xh "$mbiao"
echo "============================================="


