# 🐳 Docker一体化部署指南

## 📋 概述

咸鱼甘特图现在支持前后端一体化Docker部署，只需要一个镜像就能运行完整的应用。

## 🚀 快速部署

### 1. 在Docker Hub创建仓库
1. 访问 https://hub.docker.com
2. 创建仓库：`zhouwl/gantt-excel`

### 2. 配置GitHub Secrets
在GitHub仓库设置中添加：
- `DOCKER_USERNAME`: 您的Docker Hub用户名
- `DOCKER_PASSWORD`: 您的Docker Hub密码

### 3. 自动构建
推送代码到GitHub后，会自动构建并推送到Docker Hub。

### 4. 生产环境部署

#### 方法一：使用Docker Compose（推荐）
```bash
# 克隆项目
git clone https://github.com/qqzhoufan/gantt-excel.git
cd gantt-excel

# 创建环境配置
echo "DB_PASSWORD=your_secure_password" > .env.prod

# 部署
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

#### 方法二：直接使用Docker
```bash
# 拉取镜像
docker pull zhouwl/gantt-excel:latest

# 启动数据库
docker run -d \
  --name gantt-postgres \
  -e POSTGRES_DB=gantt_excel \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=your_password \
  -p 5432:5432 \
  postgres:15

# 启动应用
docker run -d \
  --name gantt-app \
  --link gantt-postgres:postgres \
  -e DB_HOST=postgres \
  -e DB_PASSWORD=your_password \
  -p 9897:9897 \
  -p 9898:9898 \
  zhouwl/gantt-excel:latest
```

## 🔧 服务架构

```
┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │   Gantt App     │
│   (数据库)       │◄───┤   (前后端一体)   │
│   Port: 5432    │    │   Port: 9897/8  │
└─────────────────┘    └─────────────────┘
```

## 📱 访问地址

- **前端应用**: http://YOUR_SERVER_IP:9897
- **后端API**: http://YOUR_SERVER_IP:9898
- **默认密码**: zwl

## 🛠️ 管理命令

```bash
# 查看服务状态
docker compose -f docker-compose.prod.yml ps

# 查看日志
docker compose -f docker-compose.prod.yml logs -f

# 停止服务
docker compose -f docker-compose.prod.yml down

# 重启服务
docker compose -f docker-compose.prod.yml restart

# 更新服务
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

## 🔄 自动更新流程

1. **开发**: 在本地修改代码
2. **提交**: 推送到GitHub
3. **构建**: GitHub Actions自动构建Docker镜像
4. **推送**: 自动推送到Docker Hub
5. **部署**: 在生产服务器上拉取最新镜像并重启

```bash
# 生产服务器更新命令
cd /opt/gantt-excel
git pull origin main
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

## 🎯 优势

- **简化部署**: 只需要一个镜像
- **减少复杂性**: 不需要管理多个容器
- **自动构建**: GitHub Actions自动构建和推送
- **易于维护**: 统一的部署流程
- **资源优化**: 减少容器数量

## ⚠️ 注意事项

1. **数据库密码**: 请设置强密码
2. **端口冲突**: 确保9897和9898端口未被占用
3. **防火墙**: 开放相应端口
4. **备份**: 定期备份数据库数据

---

**现在您只需要一个Docker镜像就能运行完整的咸鱼甘特图应用！** 🎉
