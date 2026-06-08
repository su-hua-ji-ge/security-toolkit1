#!/bin/bash
set -euo pipefail
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
#------------------------------------------------------
rzfx_1() {
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
	cat << EOF
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
}



#-----------------------------------------------------
SQL_3() {
	LSQJ="/tmp/batch_sqli_$$.tmp"
	trap 'rm -rf "$LSQJ"; echo "异常退出，已清理临时文件" >> /tmp/sqli_cron.log ' EXIT

	yx() {
		local lj="$1"
		local sjg=0
		local cjg=0
		nrong=$(curl -s "$1" --connect-timeout 5 2>/dev/null)
		#将参数递给tj函数让tj函数加-pi来判断响应是否正确
		for tj in "SQL syntax" "mysql_fetch" "MYSQL"; do
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
}


#------------------------------------------------------
dksm_2() {
	dip(){
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
}


LSWJ="/tmp/分析_$(date +%Y%m%d).txt"
echo "--------------------夜间自动分析脚本$(date)-----------------------" | tee -a "$LSWJ"
echo "[模块1 日志分析]" | tee -a "$LSWJ"
if rzfx_1 | tee -a "$LSWJ"; then
	echo "分析成功" | tee -a "$LSWJ"
else
	echo "分析失败" | tee -a "$LSWJ"
fi

echo "[模块2 端口扫描]" | tee -a "$LSWJ"
if dksm_2 | tee -a "$LSWJ"; then
	echo "分析成功" | tee -a "$LSWJ"
else
	echo "分析失败" | tee -a "$LSWJ"
fi

echo "[模块3 SQL注入扫描]" | tee -a "$LSWJ"
if SQL_3 | tee -a "$LSWJ"; then
	echo "分析成功" | tee -a "$LSWJ"
else
	echo "分析失败" | tee -a "$LSWJ"
fi
echo "----------------------结束时间$(date)---------------------------------" | tee -a "$LSWJ"


