#!/bin/bash
set -euo pipefail

LOG="${1:-/tmp/nginx_access.log}"
OUTPUT="/tmp/nginx_report_$(date +%Y%m%d_%H%M%S).html"

if [ ! -f "$LOG" ]; then
    echo "❌ 日志文件不存在：$LOG"
    exit 1
fi

# 统计数据
TOTAL=$(wc -l < "$LOG")
UNIQUE_IP=$(awk '{print $1}' "$LOG" | sort -u | wc -l)
TOP_IP=$(awk '{print $1}' "$LOG" | sort | uniq -c | sort -nr | head -10)
SQLI_IP=$(grep -iE "(UNION|SELECT|SLEEP|sqlmap)" "$LOG" | awk '{print $1}' | sort | uniq -c | sort -nr) || true
XSS_IP=$(grep -iE "(<script>|alert\(|onerror=)" "$LOG" | awk '{print $1}' | sort | uniq -c | sort -nr) || true

# 生成 HTML 报告
cat > "$OUTPUT" << EOF
<html>
<head><title>Nginx 访问日志分析报告</title></head>
<body>
<h1>Nginx 访问日志分析报告</h1>
<p>生成时间：$(date)</p>
<p>日志文件：${LOG}</p>

<h2>总体统计</h2>
<table border=1>
<tr><td>总请求数</td><td>${TOTAL}</td></tr>
<tr><td>独立 IP 数</td><td>${UNIQUE_IP}</td></tr>
</table>

<h2>Top 10 请求 IP</h2>
<table border=1>
<tr><th>次数</th><th>IP</th></tr>
$(echo "$TOP_IP" | awk '{printf "<tr><td>%s</td><td>%s</td></tr>\n", $1, $2}')
</table>

<h2>SQL注入攻击 IP</h2>
<table border=1>
<tr><th>次数</th><th>IP</th></tr>
$(echo "$SQLI_IP" | awk '{printf "<tr><td>%s</td><td>%s</td></tr>\n", $1, $2}')
</table>

<h2>XSS攻击 IP</h2>
<table border=1>
<tr><th>次数</th><th>IP</th></tr>
$(echo "$XSS_IP" | awk '{printf "<tr><td>%s</td><td>%s</td></tr>\n", $1, $2}')
</table>
</body>
</html>
EOF

echo "报告已生成：$OUTPUT"
