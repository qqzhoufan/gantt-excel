# VPS部署指南 - ARM64 Ubuntu 22.04

## 🖥️ 服务器环境信息
- **CPU**: Neoverse-N1 (4核心)
- **内存**: 23.4GB
- **架构**: ARM64 (aarch64)
- **系统**: Ubuntu 22.04.5 LTS
- **内核**: 6.8.0-1030-oracle
- **Docker**: ✅ 已安装

## 🚀 快速部署步骤

### 1. 克隆项目到VPS
```bash
# SSH登录到你的VPS
ssh your-user@your-vps-ip

# 克隆最新代码
git clone https://github.com/qqzhoufan/gantt-excel.git
cd gantt-excel
```

### 2. 检查Docker环境
```bash
# 检查Docker版本
docker --version
docker-compose --version

# 如果没有docker-compose，安装它
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3. 配置环境变量
```bash
# 后端配置
cp backend/env.example backend/.env
# 编辑配置文件
nano backend/.env
```

**backend/.env 配置内容：**
```env
PORT=8080
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_secure_password
DB_NAME=gantt_excel
DB_SSL_MODE=disable
ADMIN_PASSWORD=your_admin_password
```

```bash
# 前端配置
cp frontend/env.example frontend/.env.local
nano frontend/.env.local
```

**frontend/.env.local 配置内容：**
```env
VITE_API_BASE_URL=http://your-vps-ip:8080/api/v1
VITE_APP_TITLE=甘特图项目管理系统
```

### 4. 启动服务
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 5. 验证部署
```bash
# 检查服务是否正常
curl http://localhost:3000  # 前端
curl http://localhost:8080/api/v1/health  # 后端API

# 检查数据库连接
docker-compose exec postgres psql -U postgres -d gantt_excel -c "SELECT version();"
```

## 🔧 ARM64专用Docker配置

由于你使用ARM64架构，确保Docker镜像支持该架构。检查 `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine  # 支持ARM64
    platform: linux/arm64
    environment:
      POSTGRES_DB: gantt_excel
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

  backend:
    build: 
      context: ./backend
      platform: linux/arm64
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=gantt_excel
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    restart: unless-stopped

  frontend:
    build: 
      context: ./frontend
      platform: linux/arm64
    ports:
      - "3000:3000"
    environment:
      - VITE_API_BASE_URL=http://your-vps-ip:8080/api/v1
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
```

## 🌐 访问配置

### 防火墙设置
```bash
# 开放必要端口
sudo ufw allow 3000  # 前端
sudo ufw allow 8080  # 后端API
sudo ufw allow 22    # SSH
sudo ufw enable
```

### Nginx反向代理（可选）
```bash
# 安装Nginx
sudo apt update
sudo apt install nginx

# 创建配置文件
sudo nano /etc/nginx/sites-available/gantt-excel
```

**Nginx配置内容：**
```nginx
server {
    listen 80;
    server_name your-domain.com your-vps-ip;

    # 前端
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 后端API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# 启用配置
sudo ln -s /etc/nginx/sites-available/gantt-excel /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## 📊 性能优化建议

### 针对你的4核ARM64系统：
```bash
# 在docker-compose.yml中添加资源限制
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
  
  frontend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

### PostgreSQL优化：
```sql
-- 连接到数据库后执行
ALTER SYSTEM SET shared_buffers = '2GB';
ALTER SYSTEM SET effective_cache_size = '16GB';
ALTER SYSTEM SET maintenance_work_mem = '512MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
SELECT pg_reload_conf();
```

## 🧪 测试甘特图修复效果

### 1. 访问应用
```
http://your-vps-ip:3000
```

### 2. 访问测试页面
```
http://your-vps-ip:3000/test/gantt
```

### 3. 验证修复效果
- ✅ 甘特图条与时间轴精确对齐
- ✅ 日/周/月视图切换一致性
- ✅ 边界情况正确处理
- ✅ 项目时间范围准确显示

## 🔍 故障排除

### 常见问题：

**1. 容器启动失败**
```bash
# 查看详细日志
docker-compose logs backend
docker-compose logs frontend
docker-compose logs postgres
```

**2. ARM64架构兼容性**
```bash
# 检查镜像架构
docker image inspect postgres:15-alpine | grep Architecture
```

**3. 内存不足**
```bash
# 监控资源使用
docker stats
htop
```

**4. 数据库连接问题**
```bash
# 测试数据库连接
docker-compose exec postgres psql -U postgres -d gantt_excel
```

## 📋 部署检查清单

- [ ] Git代码已克隆
- [ ] Docker和docker-compose已安装
- [ ] 环境变量已配置
- [ ] 防火墙端口已开放
- [ ] 服务已启动 (`docker-compose ps`)
- [ ] 前端可访问 (`curl localhost:3000`)
- [ ] 后端API可访问 (`curl localhost:8080`)
- [ ] 数据库连接正常
- [ ] 甘特图测试页面工作正常
- [ ] 时间对齐修复效果验证通过

## 🚀 自动化部署脚本

创建一键部署脚本：

```bash
#!/bin/bash
# deploy.sh - 一键部署脚本

echo "🚀 开始部署甘特图项目到ARM64 VPS..."

# 更新系统
sudo apt update

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

# 克隆或更新代码
if [ -d "gantt-excel" ]; then
    cd gantt-excel
    git pull origin main
else
    git clone https://github.com/qqzhoufan/gantt-excel.git
    cd gantt-excel
fi

# 配置环境变量
if [ ! -f "backend/.env" ]; then
    cp backend/env.example backend/.env
    echo "⚠️  请编辑 backend/.env 配置数据库密码"
fi

if [ ! -f "frontend/.env.local" ]; then
    cp frontend/env.example frontend/.env.local
    echo "⚠️  请编辑 frontend/.env.local 配置API地址"
fi

# 启动服务
docker-compose down
docker-compose up -d --build

echo "✅ 部署完成！"
echo "📱 前端地址: http://$(curl -s ifconfig.me):3000"
echo "🔧 后端API: http://$(curl -s ifconfig.me):8080"
echo "🧪 测试页面: http://$(curl -s ifconfig.me):3000/test/gantt"
```

你的VPS配置很棒，完全可以流畅运行这个甘特图项目！需要我帮你生成具体的部署脚本吗？