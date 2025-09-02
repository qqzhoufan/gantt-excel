#!/bin/bash

# 咸鱼甘特图Docker版本启动脚本

echo "🐟 欢迎使用咸鱼甘特图 (Docker版本)！"
echo "=================================="

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

# 启动PostgreSQL数据库
echo "🗄️  启动PostgreSQL数据库..."
docker compose up -d postgres

# 等待数据库启动
echo "⏳ 等待数据库启动..."
sleep 10

# 检查数据库连接
echo "🔍 检查数据库连接..."
until docker exec gantt-excel-postgres pg_isready -U postgres; do
    echo "等待数据库就绪..."
    sleep 2
done

echo "✅ 数据库启动成功"

# 启动后端服务
echo "🚀 启动后端服务 (端口: 9898)..."
cd backend

# 设置环境变量
export PORT=9898
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=password
export DB_NAME=gantt_excel
export DB_SSLMODE=disable

# 下载Go依赖
if [ ! -f "go.sum" ]; then
    echo "📦 下载Go依赖..."
    go mod tidy
fi

# 后台启动Go服务
nohup go run . > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo "✅ 后端服务已启动 (PID: $BACKEND_PID)"

cd ..

# 启动前端服务
echo "🎨 启动前端服务 (端口: 9897)..."
cd frontend

if [ ! -d "node_modules" ]; then
    echo "📦 安装前端依赖..."
    npm install
fi

# 后台启动前端服务
nohup npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
echo "✅ 前端服务已启动 (PID: $FRONTEND_PID)"

cd ..

# 创建日志目录
mkdir -p logs

# 保存PID到文件
echo $BACKEND_PID > logs/backend.pid
echo $FRONTEND_PID > logs/frontend.pid

echo ""
echo "🎉 咸鱼甘特图启动成功！"
echo "=================================="
echo "📱 前端地址: http://localhost:9897"
echo "🔧 后端地址: http://localhost:9898"
echo "🗄️  数据库: PostgreSQL (Docker容器)"
echo ""
echo "📋 管理命令:"
echo "  停止服务: ./scripts/docker-stop.sh"
echo "  查看日志: ./scripts/logs.sh"
echo "  重启服务: ./scripts/docker-restart.sh"
echo "  停止数据库: docker compose down"
echo ""
echo "💡 提示: 请等待几秒钟让服务完全启动"
