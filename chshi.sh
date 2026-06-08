#!/bin/bash

set -euo pipefail
LSQJ="/tmp/batch_sqli_$$.tmp"
trap 'rm -rf "$LSQJ"; echo "异常退出，已清理临时文件" >> /tmp/sqli_cron.log ' EXIT

yx() {
	local lj="$1"
	local cshu=2
	local shu=0
	local sjg=0
	nrong=$(curl -s "$1" --connect-timeout 5 2>/dev/null)
	#将参数递给tj函数让tj函数加-pi来判断响应是否正确
	for tj in "SQL syntax" "mysql_fetch" "MYSQL"; do
		shu=$((shu + 1))
		    if echo "$nrong" | grep -qi "$tj"; then
        sjg=1
        break
    fi
	done
	zcs=$(curl -s "$1" --connect-timeout 5 | wc -c)
	xcs=$(curl -s "$1'" --connect-timeout 5 | wc -c)
	if [ "$zcs" == "$xcs" ]; then
		cjg=0
	else
		cjg=1
	fi
	sz=$((sjg + cjg))
	az=$(($xcs - $zcs))
	if [ "$sz" -ge 1 ]; then
		if [ "$az" -ge 50 ]; then
			echo "关键字命中 / 响应差异异常 → 可能存在SQL注入"
		fi
	else
		echo "一切正常"
	fi
}

zds=3
ds=0
while read mb; do
	if [ $ds -ge $zds ]; then
		wait -n
		ds=$((ds - 1))
	fi
	yx "$mb" &
	ds=$((ds + 1))
done < /tmp/sqli_urls.txt
wait

echo "扫描正常结束" >> /tmp/sqli_cron.log

