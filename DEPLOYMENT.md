# 🚀 咸鱼甘特图部署指南

## 📋 部署前准备

### 系统要求
- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+, Debian 9+)
- **内存**: 最少 2GB RAM，推荐 4GB+
- **磁盘**: 最少 10GB 可用空间
- **网络**: 开放端口 9897 和 9898

### 软件要求
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Git**: 最新版本

### 访问说明
- **默认密码**: `zwl`
- **会话有效期**: 24小时
- **首次访问**: 需要输入密码进行身份验证

## 🔧 安装Docker

### Ubuntu/Debian
```bash
# 更新包索引
sudo apt-get update

# 安装必要的包
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加Docker仓库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

### CentOS/RHEL
```bash
# 安装必要的包
sudo yum install -y yum-utils

# 添加Docker仓库
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
```

## 📥 获取项目代码

```bash
# 克隆项目
git clone <repository-url>
cd gantt-excel

# 或者下载ZIP包并解压
wget <download-url>
unzip gantt-excel.zip
cd gantt-excel
```

## 🚀 部署步骤

### 1. 配置环境变量

#### 后端配置
```bash
# 复制环境变量模板
cp backend/env.example backend/.env

# 编辑配置文件
nano backend/.env
```

配置内容：
```env
# 服务端口
PORT=9898

# 数据库配置
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=gantt_excel
DB_SSLMODE=disable
```

#### 前端配置
```bash
# 复制环境变量模板
cp frontend/env.example frontend/.env

# 编辑配置文件
nano frontend/.env
```

配置内容：
```env
# API基础URL - 修改为您的服务器IP地址
VITE_API_BASE_URL=http://YOUR_SERVER_IP:9898/api/v1

# 应用标题
VITE_APP_TITLE=咸鱼甘特图

# 开发模式
VITE_DEV_MODE=false
```

### 2. 启动服务

#### 使用Docker Compose（推荐）
```bash
# 构建并启动所有服务
docker compose up --build -d

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
```

#### 使用启动脚本
```bash
# 给脚本添加执行权限
chmod +x scripts/docker-compose-start.sh

# 运行启动脚本
./scripts/docker-compose-start.sh
```

### 3. 配置防火墙

```bash
# 给脚本添加执行权限
chmod +x scripts/firewall-setup.sh

# 运行防火墙配置脚本（需要sudo权限）
sudo ./scripts/firewall-setup.sh
```

### 4. 测试部署

```bash
# 给脚本添加执行权限
chmod +x scripts/network-test.sh

# 运行网络测试脚本
./scripts/network-test.sh
```

## 🌐 网络配置详解

### 端口说明
- **9897**: 前端服务端口（HTTP）
- **9898**: 后端服务端口（HTTP）
- **5432**: PostgreSQL数据库端口（TCP）

### 防火墙配置

#### UFW (Ubuntu/Debian)
```bash
# 安装UFW
sudo apt-get install ufw

# 开放必要端口
sudo ufw allow 9897/tcp
sudo ufw allow 9898/tcp
sudo ufw allow 5432/tcp

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

#### iptables (通用)
```bash
# 开放端口
sudo iptables -A INPUT -p tcp --dport 9897 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 9898 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT

# 保存规则
sudo iptables-save > /etc/iptables/rules.v4
```

#### firewalld (CentOS/RHEL)
```bash
# 开放端口
sudo firewall-cmd --permanent --add-port=9897/tcp
sudo firewall-cmd --permanent --add-port=9898/tcp
sudo firewall-cmd --permanent --add-port=5432/tcp

# 重新加载配置
sudo firewall-cmd --reload

# 查看开放的端口
sudo firewall-cmd --list-ports
```

### 云服务器配置

#### 阿里云ECS
1. 登录阿里云控制台
2. 进入ECS实例详情
3. 点击"安全组" → "配置规则"
4. 添加入方向规则：
   - 端口范围：9897/9897
   - 授权对象：0.0.0.0/0
   - 优先级：1
5. 重复上述步骤添加端口9898

#### 腾讯云CVM
1. 登录腾讯云控制台
2. 进入CVM实例详情
3. 点击"安全组" → "修改规则"
4. 添加入站规则：
   - 类型：自定义
   - 来源：0.0.0.0/0
   - 协议端口：TCP:9897,9898
   - 策略：允许

#### AWS EC2
1. 登录AWS控制台
2. 进入EC2实例详情
3. 点击"安全组"
4. 添加入站规则：
   - 类型：自定义TCP
   - 端口：9897,9898
   - 来源：0.0.0.0/0

## 🔍 故障排除

### 服务无法启动
```bash
# 检查Docker状态
docker info

# 检查磁盘空间
df -h

# 检查内存使用
free -h

# 查看详细错误日志
docker compose logs
```

### 外部无法访问
```bash
# 1. 检查服务状态
docker compose ps

# 2. 检查端口监听
netstat -tlnp | grep -E "9897|9898"

# 3. 检查防火墙
sudo ufw status
# 或
sudo iptables -L

# 4. 测试本地访问
curl http://localhost:9897
curl http://localhost:9898/health
```

### 数据库连接问题
```bash
# 检查数据库容器状态
docker compose exec postgres pg_isready -U postgres

# 查看数据库日志
docker compose logs postgres

# 测试数据库连接
docker compose exec postgres psql -U postgres -d gantt_excel -c "SELECT version();"
```

### 前后端通信问题
```bash
# 检查前端代理配置
cat frontend/vite.config.js

# 测试API接口
curl http://localhost:9898/api/v1/roles

# 检查CORS配置
curl -H "Origin: http://localhost:9897" -H "Access-Control-Request-Method: GET" -H "Access-Control-Request-Headers: X-Requested-With" -X OPTIONS http://localhost:9898/api/v1/roles
```

## 📊 性能优化

### 数据库优化
```bash
# 调整PostgreSQL配置
docker compose exec postgres bash -c "echo 'max_connections = 100' >> /var/lib/postgresql/data/postgresql.conf"
docker compose exec postgres bash -c "echo 'shared_buffers = 256MB' >> /var/lib/postgresql/data/postgresql.conf"
docker compose restart postgres
```

### 前端优化
```bash
# 构建生产版本
cd frontend
npm run build

# 使用nginx服务静态文件
docker compose up -d frontend
```

### 监控和日志
```bash
# 查看实时日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f postgres

# 监控资源使用
docker stats
```

## 🔒 安全配置

### 修改默认密码

#### 修改应用访问密码
```bash
# 修改前端密码验证逻辑
# 编辑 frontend/src/components/PasswordAuth.vue 文件
# 将密码 'zwl' 修改为您想要的密码
# 重新构建前端容器
docker compose build --no-cache frontend
docker compose up -d frontend
```

#### 修改数据库密码
```bash
# 修改数据库密码
docker compose exec postgres psql -U postgres -c "ALTER USER postgres PASSWORD 'your_secure_password';"

# 更新环境变量
sed -i 's/DB_PASSWORD=password/DB_PASSWORD=your_secure_password/' backend/.env
docker compose restart backend
```

### 限制访问IP
```bash
# 修改nginx配置，限制访问IP
# 编辑 frontend/nginx.conf 文件
# 在server块中添加：
# allow 192.168.1.0/24;
# deny all;
```

### 启用HTTPS
```bash
# 获取SSL证书
sudo certbot certonly --standalone -d your-domain.com

# 配置nginx使用HTTPS
# 编辑 frontend/nginx.conf 文件
```

## 📈 扩展部署

### 负载均衡
```bash
# 使用nginx作为负载均衡器
# 创建 nginx-lb.conf 配置文件
# 配置多个后端实例
```

### 数据库集群
```bash
# 配置PostgreSQL主从复制
# 使用Docker Swarm或Kubernetes
```

### 监控系统
```bash
# 集成Prometheus + Grafana
# 监控应用性能和资源使用
```

## 📞 获取帮助

- 查看项目文档: [README.md](./README.md)
- 运行测试脚本: `./scripts/test.sh`
- 查看服务状态: `./scripts/logs.sh`
- 测试网络连通性: `./scripts/network-test.sh`
- 提交Issue: [GitHub Issues]

---

🎉 **部署完成！现在您可以通过 http://YOUR_SERVER_IP:9897 访问咸鱼甘特图了！**
