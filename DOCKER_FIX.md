# Docker构建问题修复说明

## 🐛 问题描述

在ARM64 VPS上运行 `docker-compose up -d` 时遇到前端构建错误：
```
ERROR: process "/bin/sh -c npm run build" did not complete successfully: exit code: 127
sh: vite: not found
```

## 🔧 问题原因

1. **前端Dockerfile问题**：使用了 `npm ci --only=production` 只安装生产依赖，但构建时需要vite等开发依赖
2. **端口配置不一致**：Dockerfile和docker-compose.yml中的端口配置不匹配
3. **nginx配置复杂**：原nginx配置过于复杂，可能导致构建问题

## ✅ 修复方案

### 1. 前端Dockerfile修复

**修复前**：
```dockerfile
# 只安装生产依赖 - 这会导致vite找不到
RUN npm ci --only=production
```

**修复后**：
```dockerfile
# 安装所有依赖（包括开发依赖，构建时需要）
RUN npm ci
```

### 2. 简化nginx配置

**修复前**：使用复杂的nginx.conf文件

**修复后**：在Dockerfile中内嵌简化的nginx配置
```dockerfile
# 创建简化的nginx配置，监听3000端口
RUN echo 'events { worker_connections 1024; } ...' > /etc/nginx/nginx.conf
```

### 3. 统一端口配置

- **前端**：3000端口（标准端口）
- **后端**：8080端口（标准端口）
- **数据库**：5432端口（PostgreSQL默认端口）

### 4. 优化docker-compose.yml

- 添加健康检查
- 改进服务依赖关系
- 统一容器命名
- 添加网络配置

## 🚀 使用修复后的配置

### 方法一：使用修复后的compose文件
```bash
# 使用修复版本
docker-compose -f docker-compose.fixed.yml up -d
```

### 方法二：手动修复现有文件
1. 更新 `frontend/Dockerfile`（已修复）
2. 更新 `backend/Dockerfile`（已修复）
3. 使用新的docker-compose配置

### 方法三：重新运行部署脚本
```bash
# 重新下载并运行修复后的部署脚本
wget https://raw.githubusercontent.com/qqzhoufan/gantt-excel/main/deploy-vps.sh
chmod +x deploy-vps.sh
./deploy-vps.sh
```

## 🧪 验证修复效果

### 1. 检查服务状态
```bash
docker-compose -f docker-compose.fixed.yml ps
```

### 2. 查看构建日志
```bash
docker-compose -f docker-compose.fixed.yml logs frontend
docker-compose -f docker-compose.fixed.yml logs backend
```

### 3. 测试访问
```bash
# 前端
curl http://localhost:3000

# 后端API
curl http://localhost:8080/api/v1/health

# 测试页面
curl http://localhost:3000/test/gantt
```

## 📱 访问地址更新

修复后的访问地址：
- **前端应用**: `http://你的VPS-IP:3000`
- **甘特图测试**: `http://你的VPS-IP:3000/test/gantt`
- **后端API**: `http://你的VPS-IP:8080`

## 🔍 故障排除

### 如果仍然遇到构建问题：

1. **清理Docker缓存**
```bash
docker system prune -a
docker-compose -f docker-compose.fixed.yml build --no-cache
```

2. **检查系统资源**
```bash
free -h  # 检查内存
df -h    # 检查磁盘空间
```

3. **逐个构建服务**
```bash
# 先构建后端
docker-compose -f docker-compose.fixed.yml build backend

# 再构建前端
docker-compose -f docker-compose.fixed.yml build frontend

# 最后启动所有服务
docker-compose -f docker-compose.fixed.yml up -d
```

4. **查看详细错误**
```bash
docker-compose -f docker-compose.fixed.yml up --build
```

## 📋 修复文件清单

- ✅ `frontend/Dockerfile` - 修复npm依赖安装和nginx配置
- ✅ `backend/Dockerfile` - 修复端口配置
- ✅ `docker-compose.fixed.yml` - 新的compose配置文件
- ✅ `deploy-vps.sh` - 更新部署脚本

## 🎯 预期结果

修复后，你应该能够：
1. 成功构建所有Docker镜像
2. 正常启动所有服务
3. 访问前端应用和测试页面
4. 验证甘特图时间对齐修复效果

如果还有问题，请查看具体的错误日志并告诉我！