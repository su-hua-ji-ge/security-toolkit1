#!/bin/bash

# 1. 接收一个参数：日志文件路径
# 2. 检查文件是否存在
# 3. 输出以下报告：
#    - 总请求数
#    - 独立 IP 数
#    - SQL 注入攻击 TOP 5 IP
#    - XSS 攻击 TOP 5 IP
#    - 目录扫描 TOP 5 IP
#    - 每个 IP 的攻击类型分布（攻击画像）
# 4. 用 here-doc 排版输出
set -euo pipefail

#接受路径
lj="${1:-/tmp/nginx_access.log}"
#检查文件是否存在
if [ ! -f "$lj" ]; then
	echo "路径不存在，检查是否输入正确"
	exit 1
fi
#获取ip
ip=$(cat "$lj" | wc -l)
#echo "- 总请求数"
zhoq=$(wc -l < "$lj")
#echo "- 独立 IP 数"
dlip=$(awk '{print $1}' "$lj" | sort -u | wc -l)
#echo "- SQL 注入攻击 TOP 5 IP"
sqlg=$(grep -E "UNION|SELECT|SLEEP|sqlmap" "$lj" | awk '{print $1}' | sort | uniq -c | head -5)
#echo "- XSS 攻击 TOP 5 IP"
XSSg=$(grep -E "(<script>|alert\(|onerror=)" "$lj" | awk '{print $1}'| sort | uniq -c | sort -nr)
#echo "- 目录扫描 TOP 5 IP"
saom=$(grep -E "nmap|wp-admin|phpmyadmin|\.env" "$lj" | awk '{print $1}' | uniq -c | head -5)
#echo "- 每个 IP 的攻击类型分布（攻击画像）"
#js=$()

#juxi(){
#
#       for ip in ; do
#                echo "IP: $ip | SQLi:$sqli | XSS:$xss | 扫描:$scan | 正常:$normal"
#        done
#}
cat <<EOF
	- 总请求数
	${zhoq}
        - 独立 IP 数
	${dlip}
        - SQL 注入攻击 TOP 5 IP
	${sqlg}
        - XSS 攻击 TOP 5 IP
	${XSSg}
        - 目录扫描 TOP 5 IP
	${saom}
	
EOF
