#!/bin/bash

# 咸鱼甘特图 - 生产环境一键部署脚本

set -e

echo "🚀 开始部署咸鱼甘特图到生产环境..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

# 创建环境变量文件（如果不存在）
if [ ! -f .env.production ]; then
    echo "📝 创建生产环境配置文件..."
    cp env.production.example .env.production
    echo "⚠️  请编辑 .env.production 文件，设置安全的数据库密码"
    echo "⚠️  然后重新运行此脚本"
    exit 1
fi

# 拉取最新镜像
echo "📥 拉取最新Docker镜像..."
docker compose -f docker-compose.production.yml pull

# 停止现有服务
echo "🛑 停止现有服务..."
docker compose -f docker-compose.production.yml down

# 启动服务
echo "🚀 启动生产环境服务..."
docker compose -f docker-compose.production.yml --env-file .env.production up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "🔍 检查服务状态..."
docker compose -f docker-compose.production.yml ps

# 健康检查
echo "🏥 执行健康检查..."
if curl -f http://localhost:9898/health > /dev/null 2>&1; then
    echo "✅ 后端服务健康检查通过"
else
    echo "❌ 后端服务健康检查失败"
fi

if curl -f http://localhost:9897 > /dev/null 2>&1; then
    echo "✅ 前端服务健康检查通过"
else
    echo "❌ 前端服务健康检查失败"
fi

echo "🎉 部署完成！"
echo "📱 前端访问地址: http://YOUR_SERVER_IP:9897"
echo "🔧 后端API地址: http://YOUR_SERVER_IP:9898"
echo "🔐 默认密码: zwl"
echo ""
echo "📋 管理命令:"
echo "  查看日志: docker compose -f docker-compose.production.yml logs -f"
echo "  停止服务: docker compose -f docker-compose.production.yml down"
echo "  重启服务: docker compose -f docker-compose.production.yml restart"
echo "  更新服务: docker compose -f docker-compose.production.yml pull && docker compose -f docker-compose.production.yml --env-file .env.production up -d"
