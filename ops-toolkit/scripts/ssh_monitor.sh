#!/bin/bash

read -p "输入扫描目标路径" mb
mb="${1:-/var/log/secure}"

hexin(){
	local mblj=$1
	zong=$(grep -c "Failed password" "$mblj" )
	ipcs=$(grep "Failed password" "$mblj" | grep -oP "from \K[0-9.]+" | sort -u | wc -l)
	gjip=$(grep "Failed password" "$mblj" | grep -oP "from \K[0-9.]+" | sort | uniq -c | sort -nr | head -5)
	pdipcs=$(echo "$gjip" | awk '{print $1}')
	pdipm=$(echo "$gjip" | awk '{print $2}' | head -5)
	yh=$(grep "Failed password" "$mblj"|awk '{print $9}'| sort | uniq -c | sort -nr | head -10)
	while read count ip; do
	    if [ "$count" -ge 10 ]; then
	        jg="${ip} → 攻击 ${count} 次，建议加入黑名单"
	    fi
	done < <(grep "Failed password" "$mblj" | grep -oP "from \K[0-9.]+" | sort | uniq -c | sort -nr)
	        # 微信告警推送
        source ~/ops-toolkit/config/config.conf 2>/dev/null
        curl -s "https://sctapi.ftqq.com/${SENDKEY}.send?title=🚨SSH暴力破解告警&desp=IP：${ip}%0A攻击次数：${count}%0A已自动封禁" > /dev/null 2>&1


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
	    ${jg} → 建议加入黑名单
	==========================================
EOF
}

hexin "$mb"

