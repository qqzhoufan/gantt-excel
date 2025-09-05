#!/bin/bash
# 通用甘特图项目部署脚本
# 支持多种系统架构和Linux发行版

set -e

echo "🚀 甘特图项目通用部署脚本"
echo "📋 系统信息检查..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查系统信息
ARCH=$(uname -m)
OS_ID=""
OS_VERSION=""

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_VERSION=$VERSION_ID
elif [ -f /etc/debian_version ]; then
    OS_ID="debian"
    OS_VERSION=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; then
    OS_ID="rhel"
    OS_VERSION=$(cat /etc/redhat-release)
fi

echo -e "${BLUE}🔍 系统信息:${NC}"
echo "   CPU架构: $ARCH"
echo "   操作系统: $OS_ID $OS_VERSION"
echo "   内核版本: $(uname -r)"
echo "   CPU核心: $(nproc)"
echo "   内存: $(free -h | awk '/^Mem:/ {print $2}')"

# 架构支持检查
case $ARCH in
    x86_64|amd64)
        echo -e "${GREEN}✅ 支持的架构: x86_64${NC}"
        DOCKER_ARCH="amd64"
        ;;
    aarch64|arm64)
        echo -e "${GREEN}✅ 支持的架构: ARM64${NC}"
        DOCKER_ARCH="arm64"
        ;;
    *)
        echo -e "${RED}❌ 不支持的架构: $ARCH${NC}"
        echo "支持的架构: x86_64, ARM64"
        exit 1
        ;;
esac

# 系统支持检查
case $OS_ID in
    ubuntu|debian)
        echo -e "${GREEN}✅ 支持的系统: $OS_ID${NC}"
        PKG_MANAGER="apt"
        ;;
    centos|rhel|fedora|rocky|almalinux)
        echo -e "${GREEN}✅ 支持的系统: $OS_ID${NC}"
        PKG_MANAGER="yum"
        if command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
        fi
        ;;
    *)
        echo -e "${YELLOW}⚠️  未测试的系统: $OS_ID，尝试继续...${NC}"
        # 尝试检测包管理器
        if command -v apt &> /dev/null; then
            PKG_MANAGER="apt"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
        else
            echo -e "${RED}❌ 无法检测包管理器${NC}"
            exit 1
        fi
        ;;
esac

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  建议使用root用户运行此脚本${NC}"
    SUDO="sudo"
else
    SUDO=""
fi

# 检查Docker
echo -e "\n${BLUE}🐳 检查Docker环境...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker未安装${NC}"
    read -p "是否安装Docker? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 安装Docker..."
        
        case $PKG_MANAGER in
            apt)
                $SUDO apt update
                $SUDO apt install -y curl
                ;;
            yum|dnf)
                $SUDO $PKG_MANAGER update -y
                $SUDO $PKG_MANAGER install -y curl
                ;;
        esac
        
        # 安装Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        $SUDO sh get-docker.sh
        rm get-docker.sh
        
        # 添加用户到docker组
        if [ "$EUID" -ne 0 ]; then
            $SUDO usermod -aG docker $USER
            echo -e "${YELLOW}⚠️  请重新登录以应用Docker组权限${NC}"
        fi
        
        echo -e "${GREEN}✅ Docker安装完成${NC}"
    else
        echo -e "${RED}❌ Docker是必需的，退出部署${NC}"
        exit 1
    fi
fi

# 检查docker-compose
echo "📦 检查Docker Compose..."

# 首先检查Docker内置的compose命令
if docker compose version &> /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Compose (内置版本)已可用${NC}"
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    # 检查现有的docker-compose是否可用
    if docker-compose version &> /dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker Compose (独立版本)已可用${NC}"
        COMPOSE_CMD="docker-compose"
    else
        echo -e "${YELLOW}⚠️  现有docker-compose不可用，重新安装...${NC}"
        $SUDO rm -f /usr/local/bin/docker-compose
        COMPOSE_CMD=""
    fi
else
    COMPOSE_CMD=""
fi

# 如果没有可用的compose命令，尝试安装
if [ -z "$COMPOSE_CMD" ]; then
    echo "📦 安装Docker Compose..."
    
    # 优先尝试使用包管理器安装
    case $PKG_MANAGER in
        apt)
            if $SUDO apt install -y docker-compose-plugin 2>/dev/null; then
                echo -e "${GREEN}✅ 通过APT安装Docker Compose Plugin${NC}"
                COMPOSE_CMD="docker compose"
            fi
            ;;
        yum|dnf)
            if $SUDO $PKG_MANAGER install -y docker-compose-plugin 2>/dev/null; then
                echo -e "${GREEN}✅ 通过$PKG_MANAGER安装Docker Compose Plugin${NC}"
                COMPOSE_CMD="docker compose"
            fi
            ;;
    esac
    
    # 如果包管理器安装失败，尝试下载二进制文件
    if [ -z "$COMPOSE_CMD" ]; then
        echo "尝试下载Docker Compose二进制文件..."
        COMPOSE_VERSION="v2.24.0"
        
        case $ARCH in
            x86_64)
                COMPOSE_ARCH="x86_64"
                ;;
            aarch64)
                COMPOSE_ARCH="aarch64"
                ;;
            *)
                echo -e "${RED}❌ 不支持的架构: $ARCH${NC}"
                exit 1
                ;;
        esac
        
        COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${COMPOSE_ARCH}"
        
        if $SUDO curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose 2>/dev/null; then
            $SUDO chmod +x /usr/local/bin/docker-compose
            
            # 验证下载的文件是否可执行
            if /usr/local/bin/docker-compose version &> /dev/null; then
                echo -e "${GREEN}✅ Docker Compose二进制文件安装完成${NC}"
                COMPOSE_CMD="docker-compose"
            else
                echo -e "${RED}❌ Docker Compose二进制文件不兼容${NC}"
                $SUDO rm -f /usr/local/bin/docker-compose
            fi
        fi
    fi
    
    # 最后尝试：使用pip安装旧版本docker-compose
    if [ -z "$COMPOSE_CMD" ]; then
        echo "尝试使用pip安装docker-compose..."
        
        # 安装pip
        case $PKG_MANAGER in
            apt)
                $SUDO apt install -y python3-pip
                ;;
            yum|dnf)
                $SUDO $PKG_MANAGER install -y python3-pip
                ;;
        esac
        
        if command -v pip3 &> /dev/null; then
            $SUDO pip3 install docker-compose
            if command -v docker-compose &> /dev/null; then
                echo -e "${GREEN}✅ 通过pip安装docker-compose完成${NC}"
                COMPOSE_CMD="docker-compose"
            fi
        fi
    fi
    
    # 如果所有方法都失败了
    if [ -z "$COMPOSE_CMD" ]; then
        echo -e "${RED}❌ 无法安装Docker Compose${NC}"
        echo "请手动安装Docker Compose后重新运行脚本"
        exit 1
    fi
fi

# 显示Docker版本信息
echo "Docker版本: $(docker --version)"
echo "Docker Compose版本: $($COMPOSE_CMD version)"

# 项目目录
PROJECT_DIR="/opt/gantt-excel"
if [ -d "$PROJECT_DIR" ]; then
    echo -e "\n${YELLOW}⚠️  项目目录已存在: $PROJECT_DIR${NC}"
    read -p "是否更新现有项目? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$PROJECT_DIR"
        echo "📥 更新项目代码..."
        git pull origin main || {
            echo -e "${RED}❌ Git更新失败，尝试重新克隆...${NC}"
            cd ..
            $SUDO rm -rf "$PROJECT_DIR"
            git clone https://github.com/qqzhoufan/gantt-excel.git "$PROJECT_DIR"
            cd "$PROJECT_DIR"
        }
    else
        cd "$PROJECT_DIR"
    fi
else
    echo -e "\n${BLUE}📥 克隆项目代码...${NC}"
    $SUDO mkdir -p /opt
    cd /opt
    $SUDO git clone https://github.com/qqzhoufan/gantt-excel.git
    $SUDO chown -R $USER:$USER gantt-excel 2>/dev/null || true
    cd gantt-excel
    PROJECT_DIR="/opt/gantt-excel"
fi

# 配置环境变量
echo -e "\n${BLUE}⚙️ 配置环境变量...${NC}"

# 后端配置
if [ ! -f "backend/.env" ]; then
    cp backend/env.example backend/.env
    
    # 生成随机密码
    if command -v openssl &> /dev/null; then
        DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-12)
    else
        # 如果没有openssl，使用简单的随机字符串
        DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 25 | head -n 1)
        ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    fi
    
    # 替换配置
    sed -i "s/DB_PASSWORD=password/DB_PASSWORD=$DB_PASSWORD/" backend/.env
    sed -i "s/ADMIN_PASSWORD=admin123/ADMIN_PASSWORD=$ADMIN_PASSWORD/" backend/.env
    
    echo -e "${GREEN}✅ 后端配置已生成${NC}"
    echo -e "${YELLOW}📝 管理员密码: $ADMIN_PASSWORD${NC}"
    echo -e "${YELLOW}📝 数据库密码: $DB_PASSWORD${NC}"
else
    echo "后端配置文件已存在"
    ADMIN_PASSWORD=$(grep ADMIN_PASSWORD backend/.env | cut -d'=' -f2)
    DB_PASSWORD=$(grep DB_PASSWORD backend/.env | cut -d'=' -f2)
fi

# 前端配置
if [ ! -f "frontend/.env.local" ]; then
    cp frontend/env.example frontend/.env.local
    
    # 获取公网IP
    PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 ipinfo.io/ip 2>/dev/null || echo "localhost")
    
    # 配置API地址
    sed -i "s|VITE_API_BASE_URL=.*|VITE_API_BASE_URL=http://$PUBLIC_IP:8080/api/v1|" frontend/.env.local
    
    echo -e "${GREEN}✅ 前端配置已生成${NC}"
    echo -e "${YELLOW}📝 API地址: http://$PUBLIC_IP:8080/api/v1${NC}"
else
    echo "前端配置文件已存在"
    PUBLIC_IP=$(grep VITE_API_BASE_URL frontend/.env.local | cut -d'/' -f3 | cut -d':' -f1)
fi

# 创建适配的docker-compose配置
echo -e "\n${BLUE}🔧 创建Docker配置...${NC}"
cat > docker-compose.override.yml << EOF
version: '3.8'

services:
  postgres:
    platform: linux/${DOCKER_ARCH}
    
  backend:
    platform: linux/${DOCKER_ARCH}
    
  frontend:
    platform: linux/${DOCKER_ARCH}
EOF

# 配置防火墙
echo -e "\n${BLUE}🔥 配置防火墙...${NC}"
if command -v ufw &> /dev/null; then
    $SUDO ufw allow 22    # SSH
    $SUDO ufw allow 3000  # 前端
    $SUDO ufw allow 8080  # 后端API
    echo "y" | $SUDO ufw enable 2>/dev/null || true
    echo -e "${GREEN}✅ UFW防火墙配置完成${NC}"
elif command -v firewall-cmd &> /dev/null; then
    $SUDO firewall-cmd --permanent --add-port=3000/tcp
    $SUDO firewall-cmd --permanent --add-port=8080/tcp
    $SUDO firewall-cmd --reload
    echo -e "${GREEN}✅ Firewalld防火墙配置完成${NC}"
else
    echo -e "${YELLOW}⚠️ 未检测到防火墙，请手动开放端口 3000 和 8080${NC}"
fi

# 停止现有服务
echo -e "\n${BLUE}🛑 停止现有服务...${NC}"
$COMPOSE_CMD down 2>/dev/null || true

# 构建和启动服务
echo -e "\n${BLUE}🏗️ 构建和启动服务...${NC}"
echo "这可能需要几分钟时间，请耐心等待..."

# 设置环境变量
export DB_PASSWORD
export ADMIN_PASSWORD

# 构建并启动 (COMPOSE_CMD已在前面定义)
$COMPOSE_CMD up -d --build

# 等待服务启动
echo -e "\n${BLUE}⏳ 等待服务启动...${NC}"
sleep 30

# 检查服务状态
echo -e "\n${BLUE}📊 检查服务状态...${NC}"
$COMPOSE_CMD ps

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
if $COMPOSE_CMD exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 数据库连接正常${NC}"
else
    echo -e "${RED}❌ 数据库连接异常${NC}"
fi

# 部署完成
echo -e "\n${GREEN}🎉 部署完成！${NC}"
echo -e "\n${BLUE}📱 访问地址:${NC}"
echo -e "   前端应用: ${YELLOW}http://$PUBLIC_IP:3000${NC}"
echo -e "   后端API:  ${YELLOW}http://$PUBLIC_IP:8080${NC}"
echo -e "   测试页面: ${YELLOW}http://$PUBLIC_IP:3000/test/gantt${NC}"

echo -e "\n${BLUE}🔐 登录信息:${NC}"
echo -e "   管理员密码: ${YELLOW}$ADMIN_PASSWORD${NC}"

echo -e "\n${BLUE}🛠️ 管理命令:${NC}"
echo -e "   查看日志: ${YELLOW}cd $PROJECT_DIR && $COMPOSE_CMD logs -f${NC}"
echo -e "   重启服务: ${YELLOW}cd $PROJECT_DIR && $COMPOSE_CMD restart${NC}"
echo -e "   停止服务: ${YELLOW}cd $PROJECT_DIR && $COMPOSE_CMD down${NC}"
echo -e "   更新项目: ${YELLOW}cd $PROJECT_DIR && git pull && $COMPOSE_CMD up -d --build${NC}"

echo -e "\n${BLUE}🧪 测试甘特图修复:${NC}"
echo -e "   1. 访问测试页面验证时间对齐修复效果"
echo -e "   2. 切换不同视图模式测试一致性"
echo -e "   3. 查看浏览器控制台调试信息"

echo -e "\n${GREEN}✨ 享受你的甘特图项目管理系统！${NC}"

# 显示系统资源使用情况
echo -e "\n${BLUE}📊 系统资源使用:${NC}"
echo "   CPU: $(nproc) 核心"
echo "   内存: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
echo "   磁盘: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"

# 如果是非root用户且添加了docker组，提醒重新登录
if [ "$EUID" -ne 0 ] && groups | grep -q docker; then
    echo -e "\n${YELLOW}⚠️  如果遇到Docker权限问题，请重新登录或运行: newgrp docker${NC}"
fi