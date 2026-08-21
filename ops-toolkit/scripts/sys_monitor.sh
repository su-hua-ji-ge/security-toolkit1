#!/bin/bash
set -euo pipefail
source ~/ops-toolkit/config/config.conf 2>/dev/null || true

echo "========== 系统资源巡检报告 =========="
echo "巡检时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "主机名：$(hostname)"
echo ""

# CPU
cpu_used=$(awk '/^cpu / {idle=$5; total=0; for(i=2;i<=NF;i++) total+=$i; printf "%.0f", (1-idle/total)*100}' /proc/stat)
echo "[CPU]"
echo "  使用率：${cpu_used}%"
if [ "${cpu_used:-0}" -gt "${CPU_THRESHOLD:-80}" ]; then
    echo "  ⚠️ 告警：CPU 使用率超过 80%！"
fi
echo ""

# 内存
mem_pct=$(free -k | awk '/^Mem:/ {printf "%d", $3/$2*100}')
echo "[内存]"
echo "  使用率：${mem_pct}%"
if [ "${mem_pct:-0}" -gt "${MEM_THRESHOLD:-90}" ]; then
    echo "  ⚠️ 告警：内存使用率超过 90%！"
fi
echo ""

# 磁盘
disk_use=$(df -P -h / | tail -1 | awk '{print $5}' | tr -d '%')
echo "[磁盘]"
echo "  使用率：${disk_use}%"
if [ "${disk_use:-0}" -gt "${DISK_THRESHOLD:-85}" ]; then
    echo "  ⚠️ 告警：磁盘使用率超过 85%！"
fi
echo ""

# 负载
load=$(uptime | awk -F'load average:' '{print $2}')
echo "[系统负载]"
echo "  1/5/15分钟：${load}"
echo ""

# 僵尸进程
zombie=$(ps aux | awk '$8 ~ /Z/' | wc -l)
echo "[僵尸进程]"
echo "  数量：${zombie}"
if [ "${zombie:-0}" -gt 0 ]; then
    echo "  ⚠️ 告警：发现 ${zombie} 个僵尸进程！"
fi

echo ""
echo "========== 巡检结束 =========="
