# 使用Node.js镜像作为构建环境
FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装所有依赖（包括开发依赖，构建时需要）
RUN npm ci

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 使用nginx镜像运行
FROM nginx:alpine

# 复制构建产物到nginx目录
COPY --from=builder /app/dist /usr/share/nginx/html

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

# 暴露端口
EXPOSE 3000

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
