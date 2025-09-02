# 🚀 咸鱼甘特图快速启动指南

## ⚡ 5分钟快速启动

### 方式一：Docker Compose一键启动（推荐）

```bash
# 1. 启动所有服务（数据库、后端、前端）
./scripts/docker-compose-start.sh

# 2. 等待服务启动完成
# 3. 访问 http://YOUR_IP:9897
```

### 方式二：手动Docker Compose启动

```bash
# 1. 构建并启动所有服务
docker compose up --build -d

# 2. 查看服务状态
docker compose ps

# 3. 查看日志
docker compose logs -f
```

### 方式三：分步启动

```bash
# 1. 启动数据库
docker compose up -d postgres

# 2. 启动后端
cd backend && go run . &

# 3. 启动前端
cd frontend && npm install && npm run dev &

# 4. 访问 http://localhost:9897
```

## 🌐 网络配置

### 获取服务器IP地址
```bash
# 查看本机IP
hostname -I

# 或者
ip addr show | grep "inet.*scope global"
```

### 配置防火墙
```bash
# 配置防火墙规则（需要sudo权限）
sudo ./scripts/firewall-setup.sh

# 测试网络连通性
./scripts/network-test.sh
```

### 访问地址
- **前端**: http://YOUR_SERVER_IP:9897
- **后端**: http://YOUR_SERVER_IP:9898
- **数据库**: localhost:5432

## 🎯 核心功能

- ✅ **项目管理** - 创建、编辑、删除项目
- ✅ **甘特图** - 可视化项目时间线
- ✅ **团队管理** - PM、PO、前端、后端、UI、特效、音频、测试
- ✅ **任务跟踪** - 阶段和任务管理
- ✅ **进度监控** - 实时进度显示

## 🔧 技术栈

- **后端**: Go + Gin + GORM + PostgreSQL
- **前端**: Vue 3 + Element Plus + Vite
- **数据库**: PostgreSQL
- **端口**: 前端9897，后端9898

## 📱 界面预览

- **项目列表页** - 显示所有项目概览
- **项目详情页** - 甘特图 + 团队管理
- **新建项目页** - 项目配置向导

## 🚨 常见问题

### 端口被占用
```bash
# 查看端口占用
lsof -i :9897
lsof -i :9898

# 杀死进程
kill -9 <PID>
```

### 数据库连接失败
```bash
# 检查PostgreSQL状态
docker compose ps | grep postgres

# 重启数据库
docker compose restart postgres
```

### 前端依赖安装失败
```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com
npm install
```

### 外部无法访问
```bash
# 1. 检查防火墙配置
sudo ./scripts/firewall-setup.sh

# 2. 测试网络连通性
./scripts/network-test.sh

# 3. 检查服务状态
docker compose ps
```

### Docker服务启动失败
```bash
# 查看详细错误日志
docker compose logs

# 重新构建并启动
docker compose down
docker compose up --build -d
```

## 🔍 故障排除

### 1. 服务无法启动
```bash
# 检查Docker状态
docker info

# 检查磁盘空间
df -h

# 检查内存使用
free -h
```

### 2. 网络连接问题
```bash
# 检查端口监听
netstat -tlnp | grep -E "9897|9898"

# 检查防火墙状态
sudo ufw status
# 或
sudo iptables -L
```

### 3. 数据库问题
```bash
# 检查数据库容器状态
docker compose exec postgres psql -U postgres -d gantt_excel -c "SELECT version();"

# 查看数据库日志
docker compose logs postgres
```

## 📞 获取帮助

- 查看详细文档: [DEPLOYMENT.md](./DEPLOYMENT.md)
- 运行测试脚本: `./scripts/test.sh`
- 查看服务状态: `./scripts/logs.sh`
- 测试网络连通性: `./scripts/network-test.sh`

## 🎉 成功启动后

1. **访问前端**: http://YOUR_SERVER_IP:9897
2. **创建第一个项目**: 点击"新建项目"按钮
3. **配置项目阶段**: 设置项目时间线和里程碑
4. **添加团队成员**: 分配不同角色和职责
5. **查看甘特图**: 可视化项目进度

---

🎉 **开始使用咸鱼甘特图，让项目管理变得简单高效！**
