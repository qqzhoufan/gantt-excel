# 多阶段构建 - 前后端一体化镜像
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# 复制package文件
COPY frontend/package*.json ./

# 安装依赖（包括devDependencies，因为构建需要）
RUN npm install

# 复制前端源码
COPY frontend/ ./

# 构建前端
RUN npm run build

FROM golang:1.19-alpine AS backend-builder

WORKDIR /app/backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest

# 安装必要的工具
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# 复制后端二进制文件
COPY --from=backend-builder /app/backend/main .
COPY --from=backend-builder /app/backend/env.example .env

# 复制前端构建文件
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# 复制数据库初始化脚本
COPY database/init.sql ./database/

# 创建启动脚本
RUN echo '#!/bin/sh' > start.sh && \
    echo 'echo "🚀 启动咸鱼甘特图..."' >> start.sh && \
    echo 'echo "📱 前端服务: http://localhost:9897"' >> start.sh && \
    echo 'echo "🔧 后端API: http://localhost:9898"' >> start.sh && \
    echo 'echo "🔐 默认密码: zwl"' >> start.sh && \
    echo 'echo "⏳ 启动后端服务..."' >> start.sh && \
    echo './main &' >> start.sh && \
    echo 'echo "⏳ 启动前端服务..."' >> start.sh && \
    echo 'cd frontend && python3 -m http.server 9897 --directory dist &' >> start.sh && \
    echo 'echo "✅ 服务启动完成！"' >> start.sh && \
    echo 'wait' >> start.sh && \
    chmod +x start.sh

# 安装Python用于前端服务
RUN apk --no-cache add python3

# 暴露端口
EXPOSE 9897 9898

# 启动命令
CMD ["./start.sh"]
