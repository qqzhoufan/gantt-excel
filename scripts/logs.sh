#!/bin/bash

# 咸鱼甘特图日志查看脚本

echo "📋 咸鱼甘特图服务日志"
echo "=================================="

if [ "$1" = "backend" ]; then
    echo "🔧 后端服务日志:"
    echo "=================================="
    if [ -f "logs/backend.log" ]; then
        tail -f logs/backend.log
    else
        echo "❌ 后端日志文件不存在"
    fi
elif [ "$1" = "frontend" ]; then
    echo "🎨 前端服务日志:"
    echo "=================================="
    if [ -f "logs/frontend.log" ]; then
        tail -f logs/frontend.log
    else
        echo "❌ 前端日志文件不存在"
    fi
else
    echo "📋 使用方法:"
    echo "  查看后端日志: ./scripts/logs.sh backend"
    echo "  查看前端日志: ./scripts/logs.sh frontend"
    echo ""
    echo "📊 服务状态:"
    echo "--------------------------------"
    
    # 检查后端服务
    if [ -f "logs/backend.pid" ]; then
        BACKEND_PID=$(cat logs/backend.pid)
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            echo "🔧 后端服务: ✅ 运行中 (PID: $BACKEND_PID)"
        else
            echo "🔧 后端服务: ❌ 已停止"
        fi
    else
        echo "🔧 后端服务: ❌ 未启动"
    fi
    
    # 检查前端服务
    if [ -f "logs/frontend.pid" ]; then
        FRONTEND_PID=$(cat logs/frontend.pid)
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            echo "🎨 前端服务: ✅ 运行中 (PID: $FRONTEND_PID)"
        else
            echo "🎨 前端服务: ❌ 已停止"
        fi
    else
        echo "🎨 前端服务: ❌ 未启动"
    fi
    
    echo ""
    echo "🌐 访问地址:"
    echo "  前端: http://localhost:9897"
    echo "  后端: http://localhost:9898"
    echo "  健康检查: http://localhost:9898/health"
fi
