#!/bin/bash

hashu() {
	local cmd="$1"
	local mbnr=$(curl -s --connect-timeout 5 2>/dev/null "$cmd")
	local jishu=0
	for a in "SQL syntax" "mysql_fetch" "You have an error" "ORA-" "MySQL"; do
		if echo "$mbnr" | grep -qi "$a"; then
			jishu=$((jishu + 1))
		fi
		done
	echo "$jishu"
}

reshuis=$(hashu "https://0ae200a40488ae1580f521140013009b.web-security-academy.net/filter?category=Gifts'")
if  [ $reshuis -gt 0 ];then
	echo "检测到可疑目标，疑似SQL注入"
else
	echo "暂无可疑目标"
fi

mbne1=$(curl -s --connect-timeout 5 2>/dev/null "https://0ae200a40488ae1580f521140013009b.web-security-academy.net/filter?category=Gifts'")
mbne2=$(curl -s --connect-timeout 5 2>/dev/null "https://0ae200a40488ae1580f521140013009b.web-security-academy.net/filter?category=Gifts")
if [ "$mbne2" == "$mbne1" ]; then
	echo "一切正常"
else
	echo "疑似SQL注入"
fi

