#!/bin/bash
caozuo() {
	local mb="$1"
	ztm=${ztm:-000}   # 如果状态码为空，设为 000（连接失败）

	local zong=$(curl -s -I --connect-timeout 5 "$mb" 2>/dev/null | tr -d '\r')
	local ztm=$(echo "$zong" | head -1 | awk '{print $2}')
	local Sers=$(echo "$zong" | grep -i "^Server:" | awk '{print $2}')
	local Types=$(echo "$zong"| grep -i "^Content-Type" |  cut -d' ' -f2-)
	case "$ztm" in
		200)
			echo "一切正常，Server:$Sers,Content-Type:$Types"
			;;
		301)
			echo "重新定向中~，Server:$Sers,Content-Type:$Types"
			;;
		302)
			echo "重新定向中~,Server:$Sers,Content-Type:$Types"
			;;
		403)
			echo "页面禁止访问，Server:$Sers,Content-Type:$Types"
			;;
		404)
			echo "页面不存在，Server:$Sers,Content-Type:$Types"
			;;
		500)
			echo "页面+错误，Server:$Sers,Content-Type:$Types"
			;;
		*)
			echo "❌ 连接失败或无响应 (状态码: ${ztm})"
			;;
	esac
}

sx=3
xhcs=0
while read ips; do
	if [ $xhcs -ge $sx ]; then
		wait -n
		xhcs=$((xhcs - 1))
	fi
	safe_name=$(echo "$ips" | tr ':/' '__')
	caozuo "$ips" -timeout 3 > "/tmp/htm_${safe_name}.txt" &
	xhcs=$(( xhcs + 1 ))
done < /tmp/url_list.txt
wait
echo ""
