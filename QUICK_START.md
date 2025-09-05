# 快速启动指南 - 无Docker环境

由于当前环境没有Docker，这里提供几种替代方案来运行甘特图项目。

## 🎯 方案一：仅前端测试（推荐）

这种方式可以直接测试甘特图时间对齐修复效果：

### 1. 启动前端服务
```bash
cd frontend
npm install
npm run dev
```

### 2. 访问测试页面
打开浏览器访问：
- 测试页面：http://localhost:5173/test/gantt
- 这个页面包含完整的测试数据，可以验证甘特图对齐修复效果

### 3. 测试功能
- 切换正常/边界测试数据
- 切换日/周/月视图
- 查看甘特图条与时间轴的精确对齐
- 在浏览器控制台查看调试信息

## 🎯 方案二：使用SQLite数据库

修改后端配置使用SQLite而不是PostgreSQL：

### 1. 修改后端配置
```bash
cd backend
cp env.example .env
```

编辑 `.env` 文件：
```env
# 使用SQLite数据库
DB_TYPE=sqlite
DB_PATH=./gantt.db
PORT=8080
ADMIN_PASSWORD=admin123
```

### 2. 修改Go代码支持SQLite
在 `backend/database.go` 中添加SQLite支持：

```go
import (
    "gorm.io/driver/sqlite"
    // 其他导入...
)

// 在InitDatabase函数中添加
if config.DBType == "sqlite" {
    DB, err = gorm.Open(sqlite.Open(config.DBPath), &gorm.Config{})
} else {
    // 原有的PostgreSQL连接代码
}
```

### 3. 启动服务
```bash
# 启动后端
cd backend
go mod tidy
go run .

# 启动前端
cd frontend
npm run dev
```

## 🎯 方案三：在线演示

如果本地环境配置困难，可以：

1. **查看代码修复**: 直接查看GitHub上的代码变更
2. **查看文档**: 阅读 `GANTT_ALIGNMENT_FIX.md` 了解修复细节
3. **部署到云平台**: 使用Vercel、Netlify等平台部署前端

## 🎯 方案四：Docker安装（如果需要）

如果你想安装Docker来使用完整功能：

### Ubuntu/Debian
```bash
# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 启动项目
docker-compose up -d
```

## 🧪 测试甘特图修复效果

无论使用哪种方案，都可以通过以下方式验证修复效果：

### 1. 访问测试页面
`http://localhost:5173/test/gantt`

### 2. 验证项目
- **正常测试数据**: 项目时间 2024-09-01 至 2024-09-30
- **边界测试数据**: 项目时间 2024-09-15 至 2024-09-25

### 3. 检查对齐
- 甘特图条的开始位置应该精确对应时间轴上的开始日期
- 甘特图条的结束位置应该精确对应时间轴上的结束日期
- 切换视图模式时保持一致的对齐效果

### 4. 查看调试信息
打开浏览器开发者工具控制台，可以看到详细的调试信息：
- 时间轴生成过程
- 甘特图条位置计算
- 边界调整记录

## 📋 推荐测试流程

1. **启动前端服务** (最简单)
   ```bash
   cd frontend && npm run dev
   ```

2. **访问测试页面**
   ```
   http://localhost:5173/test/gantt
   ```

3. **验证修复效果**
   - 查看正常测试数据的时间对齐
   - 切换到边界测试数据验证边界处理
   - 切换不同视图模式确认一致性

4. **查看技术细节**
   - 阅读 `GANTT_ALIGNMENT_FIX.md`
   - 查看浏览器控制台调试信息

这样就可以完整验证甘特图时间对齐问题的修复效果了！