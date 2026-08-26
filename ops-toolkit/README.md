# ops-toolkit —— 运维脚本工具箱 v3.0

面向 IDC 数据中心运维的 Shell 脚本集合。覆盖安全监控、自动封禁、日志分析、资源巡检、告警推送五大场景。

## 核心功能

| 脚本 | 功能 | 场景 |
|------|------|------|
| ssh_monitor.sh | SSH 暴力破解监控 + 自动封禁 | 安全运维 |
| nginx_report.sh | Nginx 访问日志分析 + HTML 报表 | 客户报告 |
| sys_monitor.sh | 系统资源巡检（CPU/内存/磁盘） + 微信告警 | 日常巡检 |

## 系统要求

- Rocky Linux 9 / CentOS Stream / Ubuntu 20.04+
- Bash 4.0+
- curl（告警推送）
- bc 或 awk（浮点运算）

## 一键安装

\`\`\`bash
git clone https://github.com/su-hua-ji-ge/security-toolkit1.git
cd security-toolkit1
chmod +x install.sh
sudo ./install.sh
\`\`\`

## 配置说明

编辑 `config/config.conf`：

\`\`\`bash
SENDKEY="你的key"    # 必填！获取地址：https://sct.ftqq.com
CPU_THRESHOLD=80                 # CPU 告警阈值（%）
MEM_THRESHOLD=90                 # 内存告警阈值（%）
DISK_THRESHOLD=85                # 磁盘告警阈值（%）
SSH_BAN_THRESHOLD=10             # SSH 封禁阈值（次）
\`\`\`

## 目录结构

\`\`\`
ops-toolkit/
├── scripts/          # 所有脚本
│   ├── ssh_monitor.sh
│   ├── nginx_report.sh
│   └── sys_monitor.sh
├── config/
│   └── config.conf   # 配置文件（阈值/Webhook/路径）
├── logs/             # 运行日志
├── install.sh        # 一键安装脚本
└── README.md         # 本文件
\`\`\`

## 告警截图

> 此处插入手机微信收到 Server 酱告警的截图

## HTML 报表截图

> 此处插入浏览器打开 HTML 巡检报表的截图

## 作者

山西水利职业技术学院 · 计算机应用技术
GitHub: https://github.com/su-hua-ji-ge/security-toolkit1

