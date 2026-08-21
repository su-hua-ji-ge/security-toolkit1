#!/bin/bash
set -euo pipefail

mb="${1:-/var/log/secure}"

hexin(){
	local mblj=$1
	zong=$(grep -c "Failed password" "$mblj")
	ipcs=$(grep "Failed password" "$mblj" | grep -oP "from \K[0-9.]+" | sort -u | wc -l)
	gjip=$(grep "Failed password" "$mblj" | grep -oP "from \K[0-9.]+" | sort | uniq -c | sort -nr | head -5)
	yh=$(grep "Failed password" "$mblj" | awk '{print $9}' | sort | uniq -c | sort -nr | head -10)
	source ~/ops-toolkit/config/config.conf 2>/dev/null || true
	BAN_THRESHOLD="${SSH_BAN_THRESHOLD:-10}"

	jg=""
	while read count ip; do
	    if [ "$count" -ge "$BAN_THRESHOLD" ]; then
	        jg+="${ip} → 攻击 ${count} 次，已自动封禁"
	        sudo firewall-cmd --add-rich-rule="rule family='ipv4' source address='${ip}' drop" --permanent > /dev/null 2>&1
	        curl -s "https://sctapi.ftqq.com/${SENDKEY}.send?title=🚨SSH暴力破解告警&desp=IP：${ip}%0A攻击次数：${count}%0A已自动封禁" > /dev/null 2>&1
	    fi
	done < <(grep "Failed password" "$mblj" | grep -oP "from \K[0-9.]+" | sort | uniq -c | sort -nr)
	[ -z "$jg" ] && jg="无高危IP"
	sudo firewall-cmd --reload > /dev/null 2>&1

	cat <<EOF
	========== SSH 暴力破解监控报告 ==========
	扫描时间：$(date +%Y年%m月%d日)
	日志文件：$mb

	[总体统计]
	总失败登录：$zong 次
	独立攻击 IP：$ipcs

	[Top 5 攻击 IP]
	  	${gjip}

	[被攻击用户名 Top 5]
	    次数 | 用户名
	    ${yh}

	[高危 IP 列表]
	    ${jg}
	==========================================
EOF
}

hexin "$mb"
