#!/bin/bash

# 咸鱼甘特图Docker Compose启动脚本

echo "🐟 欢迎使用咸鱼甘特图 (Docker Compose版本)！"
echo "=============================================="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    echo "Ubuntu/Debian: sudo apt-get install docker.io docker-compose"
    echo "CentOS/RHEL: sudo yum install docker docker-compose"
    exit 1
fi

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo "❌ Docker服务未运行，请先启动Docker服务"
    echo "Ubuntu/Debian: sudo systemctl start docker"
    echo "CentOS/RHEL: sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker服务正在运行"

# 获取本机IP地址
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "🌐 本机IP地址: $LOCAL_IP"

# 停止现有服务
echo "🛑 停止现有服务..."
docker compose down

# 构建并启动所有服务
echo "🚀 构建并启动所有服务..."
docker compose up --build -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "🔍 检查服务状态..."
docker compose ps

# 检查服务健康状态
echo "💚 检查服务健康状态..."
echo "数据库状态:"
docker compose exec postgres pg_isready -U postgres

echo "后端服务状态:"
if curl -s http://localhost:9898/health > /dev/null; then
    echo "✅ 后端服务运行正常"
else
    echo "❌ 后端服务未响应"
fi

echo "前端服务状态:"
if curl -s http://localhost:9897 > /dev/null; then
    echo "✅ 前端服务运行正常"
else
    echo "❌ 前端服务未响应"
fi

echo ""
echo "🎉 咸鱼甘特图启动成功！"
echo "=============================================="
echo "📱 前端地址: http://$LOCAL_IP:9897"
echo "🔧 后端地址: http://$LOCAL_IP:9898"
echo "🗄️  数据库: PostgreSQL (Docker容器)"
echo ""
echo "📋 管理命令:"
echo "  查看服务状态: docker compose ps"
echo "  查看日志: docker compose logs -f"
echo "  停止服务: docker compose down"
echo "  重启服务: docker compose restart"
echo ""
echo "💡 提示: 如果无法访问，请检查防火墙设置"
echo "   确保端口9897和9898已开放"
