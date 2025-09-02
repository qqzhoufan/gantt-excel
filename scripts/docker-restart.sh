#!/bin/bash

# 咸鱼甘特图Docker版本重启脚本

echo "🔄 重启咸鱼甘特图服务 (Docker版本)..."
echo "=================================="

# 停止服务
./scripts/docker-stop.sh

# 等待进程完全结束
sleep 3

# 启动服务
./scripts/docker-start.sh
