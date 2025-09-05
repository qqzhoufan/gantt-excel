#!/bin/bash
# 甘特图项目快速部署修复脚本
# 解决目录和端口问题

set -e

echo "🚀 甘特图项目快速部署修复"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查当前位置
echo -e "${BLUE}📍 当前目录: $(pwd)${NC}"

# 如果不在项目目录中，克隆项目
if [ ! -f "docker-compose.yml" ] && [ ! -f "docker-compose.fixed.yml" ]; then
    echo -e "${YELLOW}⚠️  未检测到甘特图项目文件${NC}"
    
    # 检查是否在/opt/gantt目录
    if [ "$(basename $(pwd))" = "gantt" ]; then
        echo "当前在/opt/gantt目录，但项目文件不完整"
        echo "重新克隆项目..."
        cd ..
        sudo rm -rf gantt 2>/dev/null || true
    fi
    
    echo -e "${BLUE}📥 克隆甘特图项目...${NC}"
    git clone https://github.com/qqzhoufan/gantt-excel.git
    cd gantt-excel
    
    echo -e "${GREEN}✅ 项目克隆完成${NC}"
else
    echo -e "${GREEN}✅ 检测到甘特图项目文件${NC}"
fi

# 检查项目文件完整性
echo -e "\n${BLUE}🔍 检查项目文件完整性...${NC}"

REQUIRED_FILES=("backend/Dockerfile" "frontend/Dockerfile" "backend/main.go" "frontend/package.json")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${RED}❌ 缺少关键文件:${NC}"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    
    echo -e "\n${BLUE}📥 重新克隆完整项目...${NC}"
    cd ..
    PROJECT_NAME=$(basename $(pwd))
    if [ "$PROJECT_NAME" = "gantt-excel" ]; then
        cd ..
    fi
    
    sudo rm -rf gantt-excel gantt 2>/dev/null || true
    git clone https://github.com/qqzhoufan/gantt-excel.git
    cd gantt-excel
    echo -e "${GREEN}✅ 完整项目已克隆${NC}"
else
    echo -e "${GREEN}✅ 项目文件完整${NC}"
fi

# 检查端口占用
echo -e "\n${BLUE}🔍 检查端口占用...${NC}"

check_port() {
    local port=$1
    if sudo netstat -tlnp 2>/dev/null | grep ":$port " > /dev/null; then
        echo -e "${RED}❌ 端口 $port 被占用${NC}"
        
        # 显示占用进程
        PROCESS=$(sudo netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | head -1)
        echo "  占用进程: $PROCESS"
        
        return 1
    else
        echo -e "${GREEN}✅ 端口 $port 可用${NC}"
        return 0
    fi
}

PORT_3000_OK=true
PORT_8080_OK=true

if ! check_port 3000; then
    PORT_3000_OK=false
fi

if ! check_port 8080; then
    PORT_8080_OK=false
fi

# 决定使用哪个配置文件
if [ "$PORT_3000_OK" = true ] && [ "$PORT_8080_OK" = true ]; then
    echo -e "\n${GREEN}✅ 端口可用，使用标准配置${NC}"
    COMPOSE_FILE="docker-compose.yml"
    FRONTEND_PORT="3000"
    BACKEND_PORT="8080"
else
    echo -e "\n${YELLOW}⚠️  端口被占用，使用替代端口配置${NC}"
    
    # 创建替代端口配置
    cat > docker-compose.ports.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: gantt-postgres-alt
    environment:
      POSTGRES_DB: gantt_excel
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD:-password123}
    volumes:
      - postgres_data_alt:/var/lib/postgresql/data
    ports:
      - "15432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5

  backend:
    build: 
      context: ./backend
    container_name: gantt-backend-alt
    environment:
      - PORT=8080
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=${DB_PASSWORD:-password123}
      - DB_NAME=gantt_excel
      - DB_SSL_MODE=disable
      - ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin123}
    ports:
      - "18080:8080"
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

  frontend:
    build: 
      context: ./frontend
    container_name: gantt-frontend-alt
    ports:
      - "13000:3000"
    depends_on:
      - backend
    restart: unless-stopped
    environment:
      - NODE_ENV=production

volumes:
  postgres_data_alt:
    driver: local

networks:
  default:
    name: gantt-network-alt
EOF
    
    COMPOSE_FILE="docker-compose.ports.yml"
    FRONTEND_PORT="13000"
    BACKEND_PORT="18080"
    
    echo -e "${GREEN}✅ 创建替代端口配置${NC}"
fi

# 配置环境变量
echo -e "\n${BLUE}⚙️ 配置环境变量...${NC}"

if [ ! -f "backend/.env" ]; then
    cp backend/env.example backend/.env 2>/dev/null || {
        echo "创建基本的后端配置..."
        cat > backend/.env << 'EOF'
PORT=8080
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password123
DB_NAME=gantt_excel
DB_SSL_MODE=disable
ADMIN_PASSWORD=admin123
EOF
    }
fi

if [ ! -f "frontend/.env.local" ]; then
    cp frontend/env.example frontend/.env.local 2>/dev/null || {
        echo "创建基本的前端配置..."
        cat > frontend/.env.local << EOF
VITE_API_BASE_URL=http://localhost:${BACKEND_PORT}/api/v1
VITE_APP_TITLE=甘特图项目管理系统
EOF
    }
fi

# 检查Docker Compose命令
COMPOSE_CMD=""
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null && docker-compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}❌ 找不到可用的Docker Compose命令${NC}"
    echo "请先运行: wget https://raw.githubusercontent.com/qqzhoufan/gantt-excel/main/fix-docker-compose.sh && chmod +x fix-docker-compose.sh && ./fix-docker-compose.sh"
    exit 1
fi

echo -e "${GREEN}✅ 使用Docker Compose命令: $COMPOSE_CMD${NC}"

# 停止现有服务
echo -e "\n${BLUE}🛑 停止现有服务...${NC}"
$COMPOSE_CMD -f $COMPOSE_FILE down 2>/dev/null || true

# 设置环境变量
export DB_PASSWORD="password123"
export ADMIN_PASSWORD="admin123"

# 构建和启动服务
echo -e "\n${BLUE}🏗️ 构建和启动服务...${NC}"
echo "配置文件: $COMPOSE_FILE"
echo "这可能需要几分钟时间，请耐心等待..."

$COMPOSE_CMD -f $COMPOSE_FILE up -d --build

# 等待服务启动
echo -e "\n${BLUE}⏳ 等待服务启动...${NC}"
sleep 20

# 检查服务状态
echo -e "\n${BLUE}📊 检查服务状态...${NC}"
$COMPOSE_CMD -f $COMPOSE_FILE ps

# 健康检查
echo -e "\n${BLUE}🏥 健康检查...${NC}"

if curl -s http://localhost:$FRONTEND_PORT > /dev/null; then
    echo -e "${GREEN}✅ 前端服务正常 (端口:$FRONTEND_PORT)${NC}"
else
    echo -e "${RED}❌ 前端服务异常${NC}"
fi

if curl -s http://localhost:$BACKEND_PORT/api/v1/health > /dev/null; then
    echo -e "${GREEN}✅ 后端API正常 (端口:$BACKEND_PORT)${NC}"
else
    echo -e "${RED}❌ 后端API异常${NC}"
fi

# 获取公网IP
PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 ipinfo.io/ip 2>/dev/null || echo "your-server-ip")

# 部署完成
echo -e "\n${GREEN}🎉 部署完成！${NC}"
echo -e "\n${BLUE}📱 访问地址:${NC}"
echo -e "   前端应用: ${YELLOW}http://$PUBLIC_IP:$FRONTEND_PORT${NC}"
echo -e "   后端API:  ${YELLOW}http://$PUBLIC_IP:$BACKEND_PORT${NC}"
echo -e "   测试页面: ${YELLOW}http://$PUBLIC_IP:$FRONTEND_PORT/test/gantt${NC}"

echo -e "\n${BLUE}🔐 登录信息:${NC}"
echo -e "   管理员密码: ${YELLOW}admin123${NC}"

echo -e "\n${BLUE}🛠️ 管理命令:${NC}"
echo -e "   查看日志: ${YELLOW}$COMPOSE_CMD -f $COMPOSE_FILE logs -f${NC}"
echo -e "   重启服务: ${YELLOW}$COMPOSE_CMD -f $COMPOSE_FILE restart${NC}"
echo -e "   停止服务: ${YELLOW}$COMPOSE_CMD -f $COMPOSE_FILE down${NC}"

echo -e "\n${GREEN}✨ 甘特图项目部署成功！${NC}"
echo -e "现在可以访问 ${YELLOW}http://$PUBLIC_IP:$FRONTEND_PORT${NC} 开始使用"