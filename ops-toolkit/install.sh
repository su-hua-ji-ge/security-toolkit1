#!/bin/bash
set -euo pipefail
# install.sh —— 运维工具箱一键安装脚本 【直接复制】

TOOLKIT_DIR="/root/ops-toolkit"
echo "========== 运维工具箱 v3.0 安装 =========="

# 1. 创建目录结构 【需要理解——mkdir -p 递归创建】
mkdir -p "${TOOLKIT_DIR}/scripts"
mkdir -p "${TOOLKIT_DIR}/config"
mkdir -p "${TOOLKIT_DIR}/logs"

# 2. 复制脚本到 scripts/ 【-n 不覆盖已存在的文件，防止冲掉手工修复】
cp -n ~/day每日/day46/扫描登录.sh	"${TOOLKIT_DIR}/scripts/ssh_monitor.sh"
cp -n ~/day每日/day48/html报表.sh	"${TOOLKIT_DIR}/scripts/nginx_report.sh"
cp -n ~/day每日/day49/系统资源巡检脚本.sh	"${TOOLKIT_DIR}/scripts/sys_monitor.sh"

# 3. 赋予执行权限 【需要记忆——chmod +x 加执行权限】
chmod +x "${TOOLKIT_DIR}/scripts/"*.sh

# 4. 检查配置文件 【需要理解——提醒用户必须填 SendKey】
if [ -f "${TOOLKIT_DIR}/config/config.conf" ]; then
    echo "✅ 配置文件已就位"
    echo "⚠️  请确认 config/config.conf 中的 SENDKEY 已填写"
else
    echo "❌ 缺少 config/config.conf，请先创建配置文件"
    exit 1
fi

# 5. 配置 crontab 【先过滤旧行再追加，防止重复】
CRON_JOB="*/10 * * * * ${TOOLKIT_DIR}/scripts/sys_monitor.sh >> ${TOOLKIT_DIR}/logs/cron.log 2>&1"
(crontab -l 2>/dev/null | grep -vF "$CRON_JOB" || true; echo "$CRON_JOB") | crontab -

echo ""
echo "========== 安装完成 =========="
echo "工具箱路径：${TOOLKIT_DIR}"
echo "配置文件：  ${TOOLKIT_DIR}/config/config.conf"
echo "日志目录：  ${TOOLKIT_DIR}/logs"
echo "定时任务已配置：crontab -l 查看"


