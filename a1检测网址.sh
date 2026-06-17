#!/bin/bash

set -euo pipefail
read -p "输入要扫描的ip:" ip
read -p "输入要扫描的文件:" mbiao
mbiao="${mbiao/#\~/$HOME}"
REPORT="/tmp/report_${ip}_$(date +%Y%m%d).md"
echo "========== 信息收集报告：$ip ==========" > "$REPORT"
echo "[子域名]" >> "$REPORT"
echo "| 域名 | 状态码 | 服务器 | 开放端口 | 后台探测 |" >> "$REPORT"
xh() {
	local file="$1"
	while read su; do
		su=$(echo "$su" | tr -d '\r')
		hz=$(curl -s -I --connect-timeout 5 "http://$su" | grep "HTTP" | awk '{print $2}' | tr -d '\r' || true)
		SE=$(curl -s -I --connect-timeout 3 "http://$su" | grep -i "^Server:" | awk '{print $2}' | tr -d '\r' || true)
		ports=""
		htlj=""
		for port in 22 80 443 8080 3306; do
		    if timeout 2 bash -c "echo >/dev/tcp/${su}/${port}" 2>/dev/null; then 
		    #>/dev/tcp/这里是IP/这里是目标端口
		        ports="${ports} ${port}"
		    fi
		done
		
		for path in admin login manager default.aspx; do
			RE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://${su}/${path}" 2>/dev/null || true)
			htlj="${htlj} ${path} --> ${RE}"
		done
	
		if [ "${hz:-0}" = "200" ]; then
			shuchu="$su --> $hz | 成功"
		elif [ "${hz:-0}" = "301" ] || [ "${hz:-0}" = "302" ]; then
			shuchu="$su --> $hz | 失败"
		else
			shuchu="$su --> $hz | 失败"
		fi
		echo "| $su | ${hz:-?} | ${SE:-无} | ${ports:-无} | ${htlj:-无} |" >> "$REPORT"
	done < "$file"
	# 在 done < "$file" 之后加上
	echo "" >> "$REPORT"
	echo "## 漏洞分析" >> "$REPORT"
	echo "> 以下内容需手工补充" >> "$REPORT"
	echo "" >> "$REPORT"
	echo "### 发现1：老旧服务器版本泄露" >> "$REPORT"
	echo "- 目标：" >> "$REPORT"
	echo "- 服务器版本：" >> "$REPORT"
	echo "- 风险：已停止安全更新，存在已知 CVE 漏洞" >> "$REPORT"
	echo "- 修复建议：升级至当前支持版本" >> "$REPORT"
	echo "" >> "$REPORT"
	echo "### 发现2：内网 IP 泄露" >> "$REPORT"
	echo "- 目标：" >> "$REPORT"
	echo "- 泄露路径：" >> "$REPORT"
	echo "- 风险：攻击者可结合 SSRF 对内网进行横向渗透" >> "$REPORT"
	echo "- 修复建议：修改重定向逻辑，不在 Location 头中暴露内网 IP" >> "$REPORT"
	echo "" >> "$REPORT"
	echo "### 发现3：后台入口暴露" >> "$REPORT"
	echo "- 目标：" >> "$REPORT"
	echo "- 后台路径：" >> "$REPORT"
	echo "- 风险：可被暴力破解或撞库攻击" >> "$REPORT"
	echo "- 修复建议：限制后台访问 IP、启用验证码或多因素认证" >> "$REPORT"
	echo "" >> "$REPORT"
	echo "## 修复优先级建议" >> "$REPORT"
	echo "1. 高优先级：隐藏 Server 头 + ASP.NET 版本信息" >> "$REPORT"
	echo "2. 中优先级：修复内网 IP 泄露" >> "$REPORT"
	echo "3 低优先级：自定义错误页面" >> "$REPORT"
	echo "" >> "$REPORT"
	echo "---" >> "$REPORT"
	echo "*报告由 recon.sh 自动生成，漏洞分析部分需手工补充*" >> "$REPORT"

}
xh "$mbiao"

echo "============================================="

