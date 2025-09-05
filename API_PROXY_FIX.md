# API访问问题修复指南

## 🐛 问题分析

### 问题1: 创建项目失败 - 405 Not Allowed
```
Failed to load resource: the server responded with a status of 405 (Not Allowed)
```

**原因分析**：
1. 前端使用相对路径 `/api/v1` 访问后端API
2. 在Docker容器环境中，前端nginx没有正确代理到后端服务
3. 前端直接访问nginx，但nginx没有配置API代理

### 问题2: 职责选择没有选项

**原因分析**：
1. 角色数据没有正确从后端加载
2. API请求失败导致角色列表为空

## 🔧 修复方案

### 方案一: 修复nginx代理配置

更新前端Dockerfile，添加API代理：

```dockerfile
# 创建包含API代理的nginx配置
RUN echo 'events { worker_connections 1024; } \
http { \
    include /etc/nginx/mime.types; \
    default_type application/octet-stream; \
    sendfile on; \
    keepalive_timeout 65; \
    gzip on; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript; \
    \
    upstream backend { \
        server backend:8080; \
    } \
    \
    server { \
        listen 3000; \
        server_name localhost; \
        root /usr/share/nginx/html; \
        index index.html; \
        \
        # 前端路由 \
        location / { \
            try_files $uri $uri/ /index.html; \
        } \
        \
        # API代理到后端 \
        location /api/ { \
            proxy_pass http://backend; \
            proxy_http_version 1.1; \
            proxy_set_header Upgrade $http_upgrade; \
            proxy_set_header Connection "upgrade"; \
            proxy_set_header Host $host; \
            proxy_set_header X-Real-IP $remote_addr; \
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
            proxy_set_header X-Forwarded-Proto $scheme; \
            proxy_cache_bypass $http_upgrade; \
        } \
        \
        # 健康检查代理 \
        location /health { \
            proxy_pass http://backend; \
            proxy_set_header Host $host; \
        } \
        \
        # 静态资源缓存 \
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { \
            expires 1y; \
            add_header Cache-Control "public, immutable"; \
        } \
    } \
}' > /etc/nginx/nginx.conf
```

### 方案二: 使用环境变量配置API地址

修改前端API配置，支持环境变量：

```javascript
// frontend/src/utils/api.js
const getBaseURL = () => {
  // 在生产环境中，如果设置了环境变量，使用环境变量
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL
  }
  
  // 开发环境或容器环境使用相对路径
  if (import.meta.env.DEV) {
    return 'http://localhost:8080/api/v1'
  }
  
  // 生产环境使用相对路径（通过nginx代理）
  return '/api/v1'
}

const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})
```

### 方案三: 添加健康检查和调试

在前端添加API连接检查：

```javascript
// frontend/src/utils/health-check.js
export const checkAPIConnection = async () => {
  try {
    const response = await fetch('/api/v1/health')
    if (response.ok) {
      console.log('✅ API连接正常')
      return true
    } else {
      console.error('❌ API连接失败:', response.status)
      return false
    }
  } catch (error) {
    console.error('❌ API连接错误:', error)
    return false
  }
}
```

## 🚀 立即修复

### 步骤1: 更新前端Dockerfile
```bash
# 在你的VPS上
cd gantt-excel
git pull origin main
```

### 步骤2: 重新构建服务
```bash
# 停止现有服务
docker-compose -f docker-compose.fixed.yml down

# 清理缓存并重新构建
docker system prune -f
docker-compose -f docker-compose.fixed.yml build --no-cache

# 启动服务
docker-compose -f docker-compose.fixed.yml up -d
```

### 步骤3: 验证修复
```bash
# 检查服务状态
docker-compose -f docker-compose.fixed.yml ps

# 检查后端健康
curl http://localhost:8080/health

# 检查前端代理
curl http://localhost:3000/api/v1/health

# 检查角色API
curl http://localhost:3000/api/v1/roles
```

## 🔍 调试步骤

### 1. 检查容器网络
```bash
# 查看容器网络
docker network ls
docker network inspect gantt-network

# 检查容器间连接
docker-compose -f docker-compose.fixed.yml exec frontend ping backend
```

### 2. 查看nginx日志
```bash
# 查看前端nginx日志
docker-compose -f docker-compose.fixed.yml logs frontend

# 实时查看日志
docker-compose -f docker-compose.fixed.yml logs -f frontend
```

### 3. 检查后端API
```bash
# 直接测试后端
docker-compose -f docker-compose.fixed.yml exec backend curl http://localhost:8080/health

# 查看后端日志
docker-compose -f docker-compose.fixed.yml logs backend
```

## 📱 预期结果

修复后，你应该能够：
1. ✅ 成功创建项目（不再出现405错误）
2. ✅ 在团队成员角色选择中看到所有职责选项
3. ✅ 正常访问所有API功能
4. ✅ 前端和后端正常通信

## 🎯 测试清单

- [ ] 访问 `http://VPS-IP:3000` 前端正常加载
- [ ] 访问 `http://VPS-IP:3000/api/v1/health` 返回健康状态
- [ ] 访问 `http://VPS-IP:3000/api/v1/roles` 返回角色列表
- [ ] 创建新项目功能正常
- [ ] 添加团队成员时角色选择有选项
- [ ] 测试页面 `http://VPS-IP:3000/test/gantt` 正常工作