#!/bin/bash
# VPS自动部署脚本 - ARM64 Ubuntu 22.04
# 适用于 Neoverse-N1 4核 24GB内存

set -e

echo "🚀 甘特图项目 VPS 部署脚本"
echo "📋 系统信息检查..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查系统架构
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo -e "${RED}❌ 警告: 此脚本专为ARM64架构优化，当前架构: $ARCH${NC}"
fi

# 检查操作系统
if [ ! -f /etc/lsb-release ] || ! grep -q "Ubuntu" /etc/lsb-release; then
    echo -e "${RED}❌ 警告: 此脚本专为Ubuntu系统优化${NC}"
fi

echo -e "${BLUE}🔍 系统信息:${NC}"
echo "   CPU: $(nproc) 核心"
echo "   内存: $(free -h | awk '/^Mem:/ {print $2}')"
echo "   架构: $(uname -m)"
echo "   系统: $(lsb_release -d | cut -f2)"

# 检查Docker
echo -e "\n${BLUE}🐳 检查Docker环境...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker未安装${NC}"
    read -p "是否安装Docker? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 安装Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        echo -e "${GREEN}✅ Docker安装完成${NC}"
    else
        echo -e "${RED}❌ Docker是必需的，退出部署${NC}"
        exit 1
    fi
fi

# 检查docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "📦 安装Docker Compose (ARM64版本)..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose安装完成${NC}"
fi

echo "Docker版本: $(docker --version)"
echo "Docker Compose版本: $(docker-compose --version)"

# 项目目录
PROJECT_DIR="$HOME/gantt-excel"

# 克隆或更新项目
echo -e "\n${BLUE}📥 获取项目代码...${NC}"
if [ -d "$PROJECT_DIR" ]; then
    echo "项目目录已存在，更新代码..."
    cd "$PROJECT_DIR"
    git pull origin main
else
    echo "克隆项目..."
    git clone https://github.com/qqzhoufan/gantt-excel.git "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# 配置环境变量
echo -e "\n${BLUE}⚙️ 配置环境变量...${NC}"

# 后端配置
if [ ! -f "backend/.env" ]; then
    cp backend/env.example backend/.env
    
    # 生成随机密码
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-12)
    
    # 替换配置
    sed -i "s/DB_PASSWORD=password/DB_PASSWORD=$DB_PASSWORD/" backend/.env
    sed -i "s/ADMIN_PASSWORD=admin123/ADMIN_PASSWORD=$ADMIN_PASSWORD/" backend/.env
    
    echo -e "${GREEN}✅ 后端配置已生成${NC}"
    echo -e "${YELLOW}📝 管理员密码: $ADMIN_PASSWORD${NC}"
    echo -e "${YELLOW}📝 数据库密码: $DB_PASSWORD${NC}"
else
    echo "后端配置文件已存在"
fi

# 前端配置
if [ ! -f "frontend/.env.local" ]; then
    cp frontend/env.example frontend/.env.local
    
    # 获取公网IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "localhost")
    
    # 配置API地址
    sed -i "s|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=http://$PUBLIC_IP:8080/api/v1|" frontend/.env.local
    
    echo -e "${GREEN}✅ 前端配置已生成${NC}"
    echo -e "${YELLOW}📝 API地址: http://$PUBLIC_IP:8080/api/v1${NC}"
else
    echo "前端配置文件已存在"
fi

# 创建ARM64优化的docker-compose.yml
echo -e "\n${BLUE}🔧 创建ARM64优化配置...${NC}"
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    platform: linux/arm64
    container_name: gantt-postgres
    environment:
      POSTGRES_DB: gantt_excel
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD:-password}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    ports:
      - "5432:5432"
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 4G
        reservations:
          cpus: '0.5'
          memory: 2G
    command: |
      postgres
      -c shared_buffers=1GB
      -c effective_cache_size=8GB
      -c maintenance_work_mem=256MB
      -c checkpoint_completion_target=0.9
      -c wal_buffers=16MB
      -c default_statistics_target=100

  backend:
    build: 
      context: ./backend
      platform: linux/arm64
    container_name: gantt-backend
    environment:
      - PORT=8080
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=${DB_PASSWORD:-password}
      - DB_NAME=gantt_excel
      - DB_SSL_MODE=disable
      - ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin123}
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build: 
      context: ./frontend
      platform: linux/arm64
    container_name: gantt-frontend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - backend
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

volumes:
  postgres_data:
    driver: local

networks:
  default:
    name: gantt-network
EOF

echo -e "${GREEN}✅ ARM64优化配置已创建${NC}"

# 配置防火墙
echo -e "\n${BLUE}🔥 配置防火墙...${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw allow 22    # SSH
    sudo ufw allow 3000  # 前端
    sudo ufw allow 8080  # 后端API
    sudo ufw --force enable
    echo -e "${GREEN}✅ 防火墙配置完成${NC}"
else
    echo -e "${YELLOW}⚠️ UFW未安装，请手动配置防火墙${NC}"
fi

# 停止现有服务
echo -e "\n${BLUE}🛑 停止现有服务...${NC}"
docker-compose down 2>/dev/null || true

# 构建和启动服务
echo -e "\n${BLUE}🏗️ 构建和启动服务...${NC}"
echo "这可能需要几分钟时间..."

# 设置环境变量
export DB_PASSWORD=$(grep DB_PASSWORD backend/.env | cut -d'=' -f2)
export ADMIN_PASSWORD=$(grep ADMIN_PASSWORD backend/.env | cut -d'=' -f2)

# 构建并启动
docker-compose up -d --build

# 等待服务启动
echo -e "\n${BLUE}⏳ 等待服务启动...${NC}"
sleep 30

# 检查服务状态
echo -e "\n${BLUE}📊 检查服务状态...${NC}"
docker-compose ps

# 健康检查
echo -e "\n${BLUE}🏥 健康检查...${NC}"

# 检查前端
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常${NC}"
else
    echo -e "${RED}❌ 前端服务异常${NC}"
fi

# 检查后端
if curl -s http://localhost:8080/api/v1/health > /dev/null; then
    echo -e "${GREEN}✅ 后端API正常${NC}"
else
    echo -e "${RED}❌ 后端API异常${NC}"
fi

# 检查数据库
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 数据库连接正常${NC}"
else
    echo -e "${RED}❌ 数据库连接异常${NC}"
fi

# 获取公网IP
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "你的服务器IP")

# 部署完成
echo -e "\n${GREEN}🎉 部署完成！${NC}"
echo -e "\n${BLUE}📱 访问地址:${NC}"
echo -e "   前端应用: ${YELLOW}http://$PUBLIC_IP:3000${NC}"
echo -e "   后端API:  ${YELLOW}http://$PUBLIC_IP:8080${NC}"
echo -e "   测试页面: ${YELLOW}http://$PUBLIC_IP:3000/test/gantt${NC}"

echo -e "\n${BLUE}🔐 登录信息:${NC}"
echo -e "   管理员密码: ${YELLOW}$(grep ADMIN_PASSWORD backend/.env | cut -d'=' -f2)${NC}"

echo -e "\n${BLUE}🛠️ 管理命令:${NC}"
echo -e "   查看日志: ${YELLOW}cd $PROJECT_DIR && docker-compose logs -f${NC}"
echo -e "   重启服务: ${YELLOW}cd $PROJECT_DIR && docker-compose restart${NC}"
echo -e "   停止服务: ${YELLOW}cd $PROJECT_DIR && docker-compose down${NC}"
echo -e "   更新项目: ${YELLOW}cd $PROJECT_DIR && git pull && docker-compose up -d --build${NC}"

echo -e "\n${BLUE}🧪 测试甘特图修复:${NC}"
echo -e "   1. 访问测试页面验证时间对齐修复效果"
echo -e "   2. 切换不同视图模式测试一致性"
echo -e "   3. 查看浏览器控制台调试信息"

echo -e "\n${GREEN}✨ 享受你的甘特图项目管理系统！${NC}"