#!/bin/bash

# 咸鱼甘特图项目停止脚本

echo "🛑 停止咸鱼甘特图服务..."
echo "=================================="

# 停止后端服务
if [ -f "logs/backend.pid" ]; then
    BACKEND_PID=$(cat logs/backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        kill $BACKEND_PID
        echo "✅ 后端服务已停止 (PID: $BACKEND_PID)"
    else
        echo "⚠️  后端服务未运行"
    fi
    rm -f logs/backend.pid
else
    echo "⚠️  未找到后端服务PID文件"
fi

# 停止前端服务
if [ -f "logs/frontend.pid" ]; then
    FRONTEND_PID=$(cat logs/frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        kill $FRONTEND_PID
        echo "✅ 前端服务已停止 (PID: $FRONTEND_PID)"
    else
        echo "⚠️  前端服务未运行"
    fi
    rm -f logs/frontend.pid
else
    echo "⚠️  未找到前端服务PID文件"
fi

# 清理可能残留的进程
pkill -f "go run"
pkill -f "npm run dev"
pkill -f "vite"

echo ""
echo "🏁 咸鱼甘特图服务已全部停止"
