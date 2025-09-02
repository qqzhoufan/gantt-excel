#!/bin/bash

# 咸鱼甘特图项目启动脚本

echo "🐟 欢迎使用咸鱼甘特图！"
echo "=================================="

# 检查PostgreSQL是否运行
echo "检查PostgreSQL服务..."
if ! pgrep -x "postgres" > /dev/null; then
    echo "❌ PostgreSQL未运行，请先启动PostgreSQL服务"
    echo "Ubuntu/Debian: sudo systemctl start postgresql"
    echo "CentOS/RHEL: sudo systemctl start postgresql"
    echo "macOS: brew services start postgresql"
    echo ""
    echo "或者使用Docker启动:"
    echo "docker compose up -d postgres"
    exit 1
fi

echo "✅ PostgreSQL服务正在运行"

# 检查数据库是否存在
echo "检查数据库..."
DB_EXISTS=$(psql -U postgres -lqt | cut -d \| -f 1 | grep -qw gantt_excel; echo $?)

if [ $DB_EXISTS -ne 0 ]; then
    echo "📝 初始化数据库..."
    psql -U postgres -f database/init.sql
    if [ $? -eq 0 ]; then
        echo "✅ 数据库初始化完成"
    else
        echo "❌ 数据库初始化失败"
        exit 1
    fi
else
    echo "✅ 数据库已存在"
fi

# 启动后端服务
echo "🚀 启动后端服务 (端口: 9898)..."
cd backend
if [ ! -f "go.sum" ]; then
    echo "📦 下载Go依赖..."
    go mod tidy
fi

# 设置环境变量
export PORT=9898
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=password
export DB_NAME=gantt_excel
export DB_SSLMODE=disable

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
echo "🗄️  数据库: PostgreSQL (gantt_excel)"
echo ""
echo "📋 管理命令:"
echo "  停止服务: ./scripts/stop.sh"
echo "  查看日志: ./scripts/logs.sh"
echo "  重启服务: ./scripts/restart.sh"
echo ""
echo "💡 提示: 请等待几秒钟让服务完全启动"
