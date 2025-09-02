#!/bin/bash

# 咸鱼甘特图项目重启脚本

echo "🔄 重启咸鱼甘特图服务..."
echo "=================================="

# 停止服务
./scripts/stop.sh

# 等待进程完全结束
sleep 3

# 启动服务
./scripts/start.sh
