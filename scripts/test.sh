#!/bin/bash

# 咸鱼甘特图项目测试脚本

echo "🧪 咸鱼甘特图项目测试"
echo "=================================="

# 检查项目结构
echo "📁 检查项目结构..."
if [ -d "backend" ] && [ -d "frontend" ] && [ -d "database" ]; then
    echo "✅ 项目目录结构完整"
else
    echo "❌ 项目目录结构不完整"
    exit 1
fi

# 检查后端Go文件
echo "🔧 检查后端代码..."
if [ -f "backend/main.go" ] && [ -f "backend/go.mod" ]; then
    echo "✅ 后端代码文件完整"
else
    echo "❌ 后端代码文件缺失"
    exit 1
fi

# 检查前端Vue文件
echo "🎨 检查前端代码..."
if [ -f "frontend/package.json" ] && [ -f "frontend/src/App.vue" ]; then
    echo "✅ 前端代码文件完整"
else
    echo "❌ 前端代码文件缺失"
    exit 1
fi

# 检查数据库脚本
echo "🗄️  检查数据库脚本..."
if [ -f "database/init.sql" ]; then
    echo "✅ 数据库脚本完整"
else
    echo "❌ 数据库脚本缺失"
    exit 1
fi

# 检查启动脚本
echo "🚀 检查启动脚本..."
if [ -x "scripts/start.sh" ] && [ -x "scripts/docker-start.sh" ]; then
    echo "✅ 启动脚本完整且可执行"
else
    echo "❌ 启动脚本缺失或不可执行"
    exit 1
fi

# 检查Docker配置
echo "🐳 检查Docker配置..."
if [ -f "docker-compose.yml" ]; then
    echo "✅ Docker配置完整"
else
    echo "❌ Docker配置缺失"
    exit 1
fi

# 检查端口占用
echo "🔌 检查端口占用..."
if lsof -i :9897 > /dev/null 2>&1; then
    echo "⚠️  端口9897已被占用"
else
    echo "✅ 端口9897可用"
fi

if lsof -i :9898 > /dev/null 2>&1; then
    echo "⚠️  端口9898已被占用"
else
    echo "✅ 端口9898可用"
fi

if lsof -i :5432 > /dev/null 2>&1; then
    echo "⚠️  端口5432已被占用"
else
    echo "✅ 端口5432可用"
fi

# 检查依赖
echo "📦 检查依赖..."

# 检查Go
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    echo "✅ Go已安装: $GO_VERSION"
else
    echo "❌ Go未安装"
fi

# 检查Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js已安装: $NODE_VERSION"
else
    echo "❌ Node.js未安装"
fi

# 检查npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm已安装: $NPM_VERSION"
else
    echo "❌ npm未安装"
fi

# 检查Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    echo "✅ Docker已安装: $DOCKER_VERSION"
else
    echo "❌ Docker未安装"
fi

# 检查Docker Compose
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | awk '{print $3}' | sed 's/,//')
    echo "✅ Docker Compose已安装: $COMPOSE_VERSION"
else
    echo "❌ Docker Compose未安装"
fi

echo ""
echo "🎉 项目测试完成！"
echo "=================================="
echo "📋 下一步操作:"
echo "  1. 启动PostgreSQL数据库"
echo "  2. 运行 ./scripts/start.sh 启动服务"
echo "  3. 或者运行 ./scripts/docker-start.sh (Docker版本)"
echo "  4. 访问 http://localhost:9897"
