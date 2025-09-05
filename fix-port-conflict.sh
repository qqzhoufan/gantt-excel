#!/bin/bash
# 端口冲突修复脚本
# 解决Docker容器端口占用问题

set -e

echo "🔧 端口冲突修复脚本"
echo "解决 'address already in use' 问题"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查是否为root
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# 检查端口占用情况
echo -e "\n${BLUE}🔍 检查端口占用情况...${NC}"

check_port() {
    local port=$1
    local service_name=$2
    
    echo -e "\n${BLUE}检查端口 $port ($service_name):${NC}"
    
    # 检查端口占用
    if $SUDO netstat -tlnp 2>/dev/null | grep ":$port " > /dev/null; then
        echo -e "${RED}❌ 端口 $port 被占用${NC}"
        
        # 显示占用进程
        echo "占用进程信息:"
        $SUDO netstat -tlnp 2>/dev/null | grep ":$port " | while read line; do
            echo "  $line"
        done
        
        # 使用lsof获取更详细信息
        if command -v lsof &> /dev/null; then
            echo "详细进程信息:"
            $SUDO lsof -i :$port 2>/dev/null | while read line; do
                echo "  $line"
            done
        fi
        
        return 1
    else
        echo -e "${GREEN}✅ 端口 $port 可用${NC}"
        return 0
    fi
}

# 检查关键端口
PORTS_OK=true

if ! check_port 3000 "前端"; then
    PORTS_OK=false
    PORT_3000_CONFLICT=true
fi

if ! check_port 8080 "后端API"; then
    PORTS_OK=false
    PORT_8080_CONFLICT=true
fi

if ! check_port 5432 "数据库"; then
    PORTS_OK=false
    PORT_5432_CONFLICT=true
fi

# 如果有端口冲突，提供解决方案
if [ "$PORTS_OK" = false ]; then
    echo -e "\n${YELLOW}⚠️  检测到端口冲突，提供以下解决方案:${NC}"
    
    echo -e "\n${BLUE}方案一: 停止占用端口的进程${NC}"
    
    if [ "${PORT_3000_CONFLICT:-false}" = true ]; then
        PID_3000=$(sudo lsof -t -i:3000 2>/dev/null | head -1)
        if [ -n "$PID_3000" ]; then
            echo -e "停止占用3000端口的进程: ${YELLOW}sudo kill -9 $PID_3000${NC}"
        fi
    fi
    
    if [ "${PORT_8080_CONFLICT:-false}" = true ]; then
        PID_8080=$(sudo lsof -t -i:8080 2>/dev/null | head -1)
        if [ -n "$PID_8080" ]; then
            echo -e "停止占用8080端口的进程: ${YELLOW}sudo kill -9 $PID_8080${NC}"
        fi
    fi
    
    if [ "${PORT_5432_CONFLICT:-false}" = true ]; then
        PID_5432=$(sudo lsof -t -i:5432 2>/dev/null | head -1)
        if [ -n "$PID_5432" ]; then
            echo -e "停止占用5432端口的进程: ${YELLOW}sudo kill -9 $PID_5432${NC}"
        fi
    fi
    
    echo -e "\n${BLUE}方案二: 使用不同端口部署${NC}"
    echo "创建使用不同端口的docker-compose配置..."
    
    # 创建使用不同端口的配置
    cat > docker-compose.alt-ports.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: gantt-postgres-alt
    environment:
      POSTGRES_DB: gantt_excel
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD:-password}
    volumes:
      - postgres_data_alt:/var/lib/postgresql/data
    ports:
      - "15432:5432"  # 使用15432端口
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
      - DB_PASSWORD=${DB_PASSWORD:-password}
      - DB_NAME=gantt_excel
      - DB_SSL_MODE=disable
      - ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin123}
    ports:
      - "18080:8080"  # 使用18080端口
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

  frontend:
    build: 
      context: ./frontend
    container_name: gantt-frontend-alt
    ports:
      - "13000:3000"  # 使用13000端口
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
    
    echo -e "${GREEN}✅ 创建了替代端口配置: docker-compose.alt-ports.yml${NC}"
    echo -e "使用方法:"
    echo -e "  ${YELLOW}docker compose -f docker-compose.alt-ports.yml up -d --build${NC}"
    echo -e "访问地址:"
    echo -e "  前端: ${YELLOW}http://localhost:13000${NC}"
    echo -e "  后端: ${YELLOW}http://localhost:18080${NC}"
    
    echo -e "\n${BLUE}方案三: 停止现有Docker容器${NC}"
    echo "如果端口被其他Docker容器占用:"
    
    # 查找占用端口的Docker容器
    for port in 3000 8080 5432; do
        CONTAINER=$(docker ps --format "table {{.Names}}\t{{.Ports}}" | grep ":$port->" | cut -f1 2>/dev/null || true)
        if [ -n "$CONTAINER" ]; then
            echo -e "停止容器 $CONTAINER: ${YELLOW}docker stop $CONTAINER${NC}"
        fi
    done
    
    # 提供自动修复选项
    echo -e "\n${YELLOW}是否自动修复端口冲突? (y/n):${NC}"
    read -r AUTO_FIX
    
    if [[ $AUTO_FIX =~ ^[Yy]$ ]]; then
        echo -e "\n${BLUE}🔧 自动修复端口冲突...${NC}"
        
        # 停止占用端口的Docker容器
        for port in 3000 8080 5432; do
            CONTAINERS=$(docker ps -q --filter "publish=$port")
            if [ -n "$CONTAINERS" ]; then
                echo "停止占用端口$port的容器..."
                docker stop $CONTAINERS 2>/dev/null || true
            fi
        done
        
        # 停止占用端口的系统进程 (谨慎操作)
        echo -e "\n${YELLOW}⚠️  是否停止占用端口的系统进程? 这可能影响其他服务 (y/n):${NC}"
        read -r KILL_PROCESSES
        
        if [[ $KILL_PROCESSES =~ ^[Yy]$ ]]; then
            for port in 3000 8080; do  # 不自动杀死5432，可能是系统PostgreSQL
                PID=$(sudo lsof -t -i:$port 2>/dev/null | head -1)
                if [ -n "$PID" ]; then
                    echo "停止占用端口$port的进程 PID:$PID"
                    $SUDO kill -9 $PID 2>/dev/null || true
                fi
            done
        fi
        
        # 等待端口释放
        echo "等待端口释放..."
        sleep 5
        
        # 重新检查端口
        echo -e "\n${BLUE}🔍 重新检查端口状态...${NC}"
        if check_port 3000 "前端" && check_port 8080 "后端API"; then
            echo -e "\n${GREEN}✅ 端口冲突已解决！${NC}"
            echo -e "现在可以重新部署甘特图项目:"
            echo -e "  ${YELLOW}docker compose up -d --build${NC}"
        else
            echo -e "\n${YELLOW}⚠️  部分端口仍被占用，建议使用替代端口配置${NC}"
            echo -e "  ${YELLOW}docker compose -f docker-compose.alt-ports.yml up -d --build${NC}"
        fi
    fi
    
else
    echo -e "\n${GREEN}✅ 所有端口都可用，可以正常部署${NC}"
fi

echo -e "\n${BLUE}💡 部署建议:${NC}"
echo "1. 如果端口冲突已解决，使用标准配置:"
echo -e "   ${YELLOW}docker compose up -d --build${NC}"
echo ""
echo "2. 如果仍有端口冲突，使用替代端口:"
echo -e "   ${YELLOW}docker compose -f docker-compose.alt-ports.yml up -d --build${NC}"
echo -e "   访问地址: ${YELLOW}http://localhost:13000${NC}"
echo ""
echo "3. 查看详细日志:"
echo -e "   ${YELLOW}docker compose logs -f${NC}"