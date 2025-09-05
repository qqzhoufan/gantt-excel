# 甘特图项目管理系统 - 部署指南

## 📋 系统要求

### 硬件要求
- **CPU**: 2核心以上 (推荐4核心)
- **内存**: 4GB以上 (推荐8GB)
- **存储**: 20GB可用空间
- **网络**: 稳定的互联网连接

### 软件要求
- **操作系统**: Ubuntu 20.04+ / CentOS 8+ / Debian 11+
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **端口**: 3000(前端), 8080(后端), 5432(数据库)

### 支持的架构
- ✅ **x86_64** (Intel/AMD)
- ✅ **ARM64** (Apple Silicon, ARM服务器)

## 🚀 快速部署

### 方法一: 一键部署脚本 (推荐)

```bash
# 下载部署脚本
wget https://raw.githubusercontent.com/qqzhoufan/gantt-excel/main/deploy-vps.sh

# 添加执行权限
chmod +x deploy-vps.sh

# 运行部署脚本
./deploy-vps.sh
```

**脚本功能**:
- 自动检测系统环境和架构
- 安装Docker和Docker Compose (如需要)
- 克隆最新代码
- 自动配置环境变量
- 生成安全密码
- 构建和启动所有服务
- 配置防火墙规则
- 运行健康检查

### 方法二: 手动部署

#### 1. 准备环境
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker (如未安装)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. 克隆项目
```bash
git clone https://github.com/qqzhoufan/gantt-excel.git
cd gantt-excel
```

#### 3. 配置环境变量

**后端配置** (`backend/.env`):
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

**前端配置** (`frontend/.env.local`):
```env
VITE_API_BASE_URL=http://your-server-ip:8080/api/v1
VITE_APP_TITLE=甘特图项目管理系统
```

#### 4. 启动服务
```bash
# 使用优化的配置文件
docker-compose -f docker-compose.fixed.yml up -d

# 查看服务状态
docker-compose -f docker-compose.fixed.yml ps
```

## 🔧 详细配置

### Docker Compose 配置

**标准版本** (`docker-compose.fixed.yml`):
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: gantt-postgres
    environment:
      POSTGRES_DB: gantt_excel
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD:-password}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5

  backend:
    build: 
      context: ./backend
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
      postgres:
        condition: service_healthy
    restart: unless-stopped

  frontend:
    build: 
      context: ./frontend
    container_name: gantt-frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
    restart: unless-stopped
    environment:
      - NODE_ENV=production

volumes:
  postgres_data:
    driver: local

networks:
  default:
    name: gantt-network
```

### Nginx 反向代理 (可选)

如果需要使用域名或SSL，可以配置Nginx:

```nginx
server {
    listen 80;
    server_name your-domain.com;

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
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔒 安全配置

### 防火墙设置
```bash
# 开放必要端口
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP (如使用Nginx)
sudo ufw allow 443   # HTTPS (如使用SSL)
sudo ufw allow 3000  # 前端 (直接访问)
sudo ufw allow 8080  # 后端API (直接访问)

# 启用防火墙
sudo ufw enable
```

### SSL证书配置 (推荐)
```bash
# 使用Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 密码安全
- 使用强密码 (至少12位，包含大小写字母、数字和特殊字符)
- 定期更换系统密码
- 限制数据库访问权限

## 📊 性能优化

### 针对不同硬件配置

**小型部署** (2核4GB):
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
  frontend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
  postgres:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 2G
```

**标准部署** (4核8GB):
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
  frontend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
  postgres:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 4G
```

### PostgreSQL 优化
```sql
-- 连接到数据库执行
ALTER SYSTEM SET shared_buffers = '25% of RAM';
ALTER SYSTEM SET effective_cache_size = '75% of RAM';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
SELECT pg_reload_conf();
```

## 🔍 监控和维护

### 健康检查
```bash
# 检查服务状态
docker-compose -f docker-compose.fixed.yml ps

# 检查日志
docker-compose -f docker-compose.fixed.yml logs -f

# 检查资源使用
docker stats

# 测试API连接
curl http://localhost:8080/api/v1/health
curl http://localhost:3000/api/v1/health
```

### 备份策略
```bash
# 数据库备份
docker-compose -f docker-compose.fixed.yml exec postgres pg_dump -U postgres gantt_excel > backup.sql

# 恢复数据库
docker-compose -f docker-compose.fixed.yml exec -T postgres psql -U postgres gantt_excel < backup.sql

# 定期备份脚本
echo "0 2 * * * cd /path/to/gantt-excel && docker-compose exec postgres pg_dump -U postgres gantt_excel > backups/backup-\$(date +\%Y\%m\%d).sql" | crontab -
```

### 更新维护
```bash
# 更新到最新版本
cd gantt-excel
git pull origin main
docker-compose -f docker-compose.fixed.yml down
docker-compose -f docker-compose.fixed.yml build --no-cache
docker-compose -f docker-compose.fixed.yml up -d

# 清理旧镜像
docker system prune -f
```

## 🐛 故障排除

### 常见问题

**1. 服务启动失败**
```bash
# 查看详细错误
docker-compose -f docker-compose.fixed.yml logs service-name

# 检查端口占用
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :8080
```

**2. 数据库连接失败**
```bash
# 检查数据库状态
docker-compose -f docker-compose.fixed.yml exec postgres pg_isready

# 查看数据库日志
docker-compose -f docker-compose.fixed.yml logs postgres
```

**3. 前端无法访问后端**
```bash
# 检查容器网络
docker network ls
docker network inspect gantt-network

# 测试容器间连接
docker-compose -f docker-compose.fixed.yml exec frontend ping backend
```

**4. 内存不足**
```bash
# 检查内存使用
free -h
docker stats

# 清理缓存
sync && echo 3 > /proc/sys/vm/drop_caches
```

### 日志分析
```bash
# 实时查看所有日志
docker-compose -f docker-compose.fixed.yml logs -f

# 查看特定服务日志
docker-compose -f docker-compose.fixed.yml logs frontend
docker-compose -f docker-compose.fixed.yml logs backend
docker-compose -f docker-compose.fixed.yml logs postgres

# 查看系统日志
journalctl -f
```

## 📱 访问地址

部署完成后的访问地址:
- **前端应用**: `http://your-server-ip:3000`
- **后端API**: `http://your-server-ip:8080`
- **测试页面**: `http://your-server-ip:3000/test/gantt`
- **健康检查**: `http://your-server-ip:3000/api/v1/health`

## 📋 部署检查清单

- [ ] 系统环境满足要求
- [ ] Docker和Docker Compose已安装
- [ ] 项目代码已克隆
- [ ] 环境变量已配置
- [ ] 防火墙端口已开放
- [ ] 服务已启动并运行正常
- [ ] 前端页面可以正常访问
- [ ] 后端API响应正常
- [ ] 数据库连接正常
- [ ] 甘特图功能工作正常
- [ ] Excel导出功能正常
- [ ] 测试页面功能正常

---

**版本**: v1.2.0  
**更新日期**: 2024年12月  
**支持**: 查看GitHub仓库获取技术支持