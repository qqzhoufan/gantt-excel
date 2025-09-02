# 🚀 生产环境部署指南

## 📋 快速部署

### 1. 在VPS上部署

```bash
# 克隆项目
git clone https://github.com/qqzhoufan/gantt-excel.git
cd gantt-excel

# 配置环境变量
cp env.production.example .env.production
nano .env.production  # 设置数据库密码

# 一键部署
./deploy-production.sh
```

### 2. 访问应用

- **前端**: http://YOUR_VPS_IP:9897
- **后端API**: http://YOUR_VPS_IP:9898
- **默认密码**: zwl

## 🔧 管理命令

```bash
# 查看服务状态
docker compose -f docker-compose.production.yml ps

# 查看日志
docker compose -f docker-compose.production.yml logs -f

# 停止服务
docker compose -f docker-compose.production.yml down

# 重启服务
docker compose -f docker-compose.production.yml restart

# 更新服务
docker compose -f docker-compose.production.yml pull
docker compose -f docker-compose.production.yml --env-file .env.production up -d
```

## 🔄 自动更新

```bash
# 更新到最新版本
cd gantt-excel
git pull origin main
./deploy-production.sh
```

## 🛡️ 安全配置

### 1. 设置强密码
编辑 `.env.production` 文件：
```bash
DB_PASSWORD=your_very_secure_password_here
```

### 2. 配置防火墙
```bash
# Ubuntu/Debian
sudo ufw allow 9897/tcp
sudo ufw allow 9898/tcp
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=9897/tcp
sudo firewall-cmd --permanent --add-port=9898/tcp
sudo firewall-cmd --reload
```

### 3. 使用Nginx反向代理（可选）
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:9897;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /api/ {
        proxy_pass http://localhost:9898/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📊 监控和维护

### 1. 查看资源使用
```bash
docker stats
```

### 2. 备份数据
```bash
# 备份数据库
docker compose -f docker-compose.production.yml exec postgres pg_dump -U postgres gantt_excel > backup.sql

# 恢复数据库
docker compose -f docker-compose.production.yml exec -T postgres psql -U postgres gantt_excel < backup.sql
```

### 3. 查看日志
```bash
# 查看所有服务日志
docker compose -f docker-compose.production.yml logs -f

# 查看特定服务日志
docker compose -f docker-compose.production.yml logs -f app
docker compose -f docker-compose.production.yml logs -f postgres
```

## ❓ 常见问题

### Q: 端口被占用怎么办？
A: 修改 `docker-compose.production.yml` 中的端口映射：
```yaml
ports:
  - "8080:9897"  # 前端
  - "8081:9898"  # 后端
```

### Q: 如何修改应用密码？
A: 需要修改前端代码中的密码验证逻辑，然后重新构建镜像。

### Q: 如何添加SSL证书？
A: 使用Nginx反向代理并配置SSL证书。

### Q: 数据库数据丢失怎么办？
A: 使用备份文件恢复，或重新初始化数据库。

---

**现在您可以在任何VPS上快速部署咸鱼甘特图了！** 🎉
