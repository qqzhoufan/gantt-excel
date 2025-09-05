#!/bin/bash
# Docker Compose 修复脚本
# 解决架构不匹配和二进制文件错误

set -e

echo "🔧 Docker Compose 修复脚本"
echo "解决 'cannot execute binary file: Exec format error' 问题"

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

# 检查架构
ARCH=$(uname -m)
echo -e "${BLUE}当前架构: $ARCH${NC}"

# 清理有问题的docker-compose
echo -e "\n${YELLOW}🧹 清理有问题的docker-compose文件...${NC}"
$SUDO rm -f /usr/local/bin/docker-compose
$SUDO rm -f /usr/bin/docker-compose

# 检查Docker内置的compose
echo -e "\n${BLUE}🔍 检查Docker内置compose...${NC}"
if docker compose version &> /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker内置compose可用${NC}"
    COMPOSE_CMD="docker compose"
    echo "推荐使用: docker compose"
else
    echo -e "${YELLOW}⚠️  Docker内置compose不可用${NC}"
    
    # 尝试安装docker-compose-plugin
    echo -e "\n${BLUE}📦 尝试安装docker-compose-plugin...${NC}"
    
    # 检测包管理器
    if command -v apt &> /dev/null; then
        $SUDO apt update
        if $SUDO apt install -y docker-compose-plugin; then
            echo -e "${GREEN}✅ docker-compose-plugin安装成功${NC}"
            COMPOSE_CMD="docker compose"
        fi
    elif command -v yum &> /dev/null; then
        if $SUDO yum install -y docker-compose-plugin; then
            echo -e "${GREEN}✅ docker-compose-plugin安装成功${NC}"
            COMPOSE_CMD="docker compose"
        fi
    elif command -v dnf &> /dev/null; then
        if $SUDO dnf install -y docker-compose-plugin; then
            echo -e "${GREEN}✅ docker-compose-plugin安装成功${NC}"
            COMPOSE_CMD="docker compose"
        fi
    fi
    
    # 如果plugin安装失败，尝试pip
    if [ -z "$COMPOSE_CMD" ]; then
        echo -e "\n${BLUE}🐍 尝试使用pip安装docker-compose...${NC}"
        
        # 安装pip
        if command -v apt &> /dev/null; then
            $SUDO apt install -y python3-pip
        elif command -v yum &> /dev/null; then
            $SUDO yum install -y python3-pip
        elif command -v dnf &> /dev/null; then
            $SUDO dnf install -y python3-pip
        fi
        
        if command -v pip3 &> /dev/null; then
            $SUDO pip3 install docker-compose
            if command -v docker-compose &> /dev/null; then
                echo -e "${GREEN}✅ pip安装docker-compose成功${NC}"
                COMPOSE_CMD="docker-compose"
            fi
        fi
    fi
fi

# 验证安装结果
echo -e "\n${BLUE}🧪 验证安装结果...${NC}"
if [ -n "$COMPOSE_CMD" ]; then
    echo -e "${GREEN}✅ Docker Compose可用: $COMPOSE_CMD${NC}"
    echo "版本信息: $($COMPOSE_CMD version)"
    
    # 创建一个简单的配置文件来测试
    echo -e "\n${BLUE}🧪 测试Docker Compose...${NC}"
    cat > test-compose.yml << 'EOF'
version: '3.8'
services:
  test:
    image: hello-world
EOF
    
    if $COMPOSE_CMD -f test-compose.yml config > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker Compose工作正常${NC}"
    else
        echo -e "${RED}❌ Docker Compose配置测试失败${NC}"
    fi
    
    rm -f test-compose.yml
    
    echo -e "\n${GREEN}🎉 修复完成！${NC}"
    echo -e "现在可以使用以下命令："
    echo -e "  ${YELLOW}$COMPOSE_CMD up -d${NC}"
    echo -e "  ${YELLOW}$COMPOSE_CMD down${NC}"
    echo -e "  ${YELLOW}$COMPOSE_CMD ps${NC}"
    
else
    echo -e "${RED}❌ 无法安装可用的Docker Compose${NC}"
    echo -e "\n${YELLOW}手动解决方案:${NC}"
    echo "1. 确保Docker版本足够新 (20.10+)"
    echo "2. 尝试更新Docker: curl -fsSL https://get.docker.com | sh"
    echo "3. 或手动安装docker-compose-plugin"
    exit 1
fi

# 如果在甘特图项目目录中，提供重新部署建议
if [ -f "docker-compose.yml" ] || [ -f "docker-compose.fixed.yml" ]; then
    echo -e "\n${BLUE}💡 检测到甘特图项目，建议重新部署:${NC}"
    echo -e "  ${YELLOW}$COMPOSE_CMD down${NC}"
    echo -e "  ${YELLOW}$COMPOSE_CMD up -d --build${NC}"
    
    # 如果有fixed版本，建议使用
    if [ -f "docker-compose.fixed.yml" ]; then
        echo -e "\n${BLUE}或使用修复版本:${NC}"
        echo -e "  ${YELLOW}$COMPOSE_CMD -f docker-compose.fixed.yml down${NC}"
        echo -e "  ${YELLOW}$COMPOSE_CMD -f docker-compose.fixed.yml up -d --build${NC}"
    fi
fi