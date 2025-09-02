# 咸鱼甘特图 - 开发指南

## 📖 目录

1. [开发环境搭建](#开发环境搭建)
2. [项目结构说明](#项目结构说明)
3. [技术栈详解](#技术栈详解)
4. [开发流程](#开发流程)
5. [代码规范](#代码规范)
6. [调试指南](#调试指南)
7. [常见问题](#常见问题)

## 🛠️ 开发环境搭建

### 系统要求

- **操作系统**: Linux/macOS/Windows
- **Go**: 1.19+
- **Node.js**: 16+
- **PostgreSQL**: 12+
- **Docker**: 20.10+ (可选，用于容器化开发)
- **Git**: 最新版本

### 环境安装

#### 1. 安装Go
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install golang-go

# macOS (使用Homebrew)
brew install go

# Windows
# 下载并安装 https://golang.org/dl/

# 验证安装
go version
```

#### 2. 安装Node.js
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS (使用Homebrew)
brew install node

# Windows
# 下载并安装 https://nodejs.org/

# 验证安装
node --version
npm --version
```

#### 3. 安装PostgreSQL
```bash
# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# macOS (使用Homebrew)
brew install postgresql

# Windows
# 下载并安装 https://www.postgresql.org/download/windows/

# 启动服务
sudo systemctl start postgresql  # Linux
brew services start postgresql   # macOS
```

### 项目初始化

```bash
# 1. 克隆项目
git clone <repository-url>
cd gantt-excel

# 2. 安装后端依赖
cd backend
go mod tidy

# 3. 安装前端依赖
cd ../frontend
npm install

# 4. 配置环境变量
cp backend/env.example backend/.env
cp frontend/env.example frontend/.env

# 5. 启动数据库
docker compose up -d postgres

# 6. 运行数据库迁移
cd backend
go run . migrate

# 7. 启动后端服务
go run .

# 8. 启动前端服务 (新终端)
cd frontend
npm run dev
```

## 📁 项目结构说明

```
gantt-excel/
├── backend/                 # Go后端服务
│   ├── main.go             # 主程序入口
│   ├── models.go           # 数据模型定义
│   ├── handlers.go         # HTTP处理器
│   ├── database.go         # 数据库连接和配置
│   ├── config.go           # 配置管理
│   ├── Dockerfile          # 后端容器配置
│   ├── go.mod              # Go模块依赖
│   ├── go.sum              # Go模块校验和
│   └── .env                # 环境变量配置
├── frontend/               # Vue前端应用
│   ├── src/
│   │   ├── components/     # Vue组件
│   │   │   ├── GanttChart.vue      # 甘特图组件
│   │   │   ├── PasswordAuth.vue    # 密码验证组件
│   │   │   └── ...
│   │   ├── views/          # 页面组件
│   │   │   ├── Home.vue            # 首页
│   │   │   ├── ProjectDetail.vue   # 项目详情页
│   │   │   └── ...
│   │   ├── stores/         # Pinia状态管理
│   │   │   └── project.js          # 项目状态管理
│   │   ├── router/         # Vue Router配置
│   │   │   └── index.js            # 路由配置
│   │   ├── utils/          # 工具函数
│   │   │   └── api.js              # API请求工具
│   │   ├── App.vue         # 根组件
│   │   └── main.js         # 应用入口
│   ├── public/             # 静态资源
│   ├── package.json        # 前端依赖配置
│   ├── vite.config.js      # Vite构建配置
│   ├── Dockerfile          # 前端容器配置
│   ├── nginx.conf          # Nginx配置
│   └── .env                # 环境变量配置
├── database/               # 数据库相关
│   └── init.sql           # 数据库初始化脚本
├── scripts/               # 管理脚本
│   ├── docker-compose-start.sh  # Docker Compose启动脚本
│   ├── docker-start.sh          # Docker启动脚本
│   ├── firewall-setup.sh        # 防火墙配置脚本
│   ├── network-test.sh          # 网络测试脚本
│   └── test.sh                  # 测试脚本
├── docs/                  # 项目文档
│   ├── API.md            # API接口文档
│   ├── USER_GUIDE.md     # 用户使用手册
│   └── DEVELOPMENT.md    # 开发指南
├── docker-compose.yml    # Docker Compose配置
├── README.md            # 项目说明
├── DEPLOYMENT.md        # 部署指南
└── QUICKSTART.md        # 快速开始指南
```

## 🔧 技术栈详解

### 后端技术栈

#### Go + Gin
- **Gin**: 高性能HTTP Web框架
- **GORM**: Go语言ORM库，用于数据库操作
- **Excelize**: Excel文件生成库
- **CORS**: 跨域资源共享中间件

#### 核心文件说明

**main.go** - 应用入口
```go
// 主要功能：
// 1. 加载配置
// 2. 初始化数据库
// 3. 配置CORS
// 4. 注册路由
// 5. 启动HTTP服务器
```

**models.go** - 数据模型
```go
// 定义的数据模型：
// - Project: 项目
// - Stage: 项目阶段
// - Task: 任务
// - TeamMember: 团队成员
// - Role: 角色
```

**handlers.go** - HTTP处理器
```go
// 主要接口：
// - 项目管理: CRUD操作
// - 阶段管理: 创建、查询、更新
// - 任务管理: 创建、更新
// - 团队管理: 创建、查询、更新
// - Excel导出: 生成Excel文件
```

**database.go** - 数据库配置
```go
// 主要功能：
// 1. 数据库连接配置
// 2. 自动迁移
// 3. 连接池配置
```

### 前端技术栈

#### Vue 3 + Vite
- **Vue 3**: 渐进式JavaScript框架
- **Vite**: 快速构建工具
- **Vue Router**: 客户端路由
- **Pinia**: 状态管理
- **Element Plus**: UI组件库
- **Day.js**: 日期处理库

#### 核心文件说明

**main.js** - 应用入口
```javascript
// 主要功能：
// 1. 创建Vue应用实例
// 2. 配置路由
// 3. 配置状态管理
// 4. 挂载应用
```

**router/index.js** - 路由配置
```javascript
// 路由配置：
// - 密码验证页面
// - 项目列表页面
// - 项目详情页面
// - 新建项目页面
// - 路由守卫（密码验证）
```

**components/GanttChart.vue** - 甘特图组件
```javascript
// 主要功能：
// 1. 甘特图数据渲染
// 2. 时间线计算
// 3. 任务和阶段编辑
// 4. 进度条显示
// 5. 交互功能
```

**components/PasswordAuth.vue** - 密码验证组件
```javascript
// 主要功能：
// 1. 密码输入表单
// 2. 密码验证逻辑
// 3. 登录状态管理
// 4. 会话过期处理
```

## 🔄 开发流程

### 1. 功能开发流程

```bash
# 1. 创建功能分支
git checkout -b feature/new-feature

# 2. 后端开发
cd backend
# 修改相关文件
go run .  # 测试后端

# 3. 前端开发
cd frontend
# 修改相关文件
npm run dev  # 测试前端

# 4. 集成测试
docker compose up --build -d
# 测试完整功能

# 5. 提交代码
git add .
git commit -m "feat: 添加新功能"
git push origin feature/new-feature

# 6. 创建Pull Request
```

### 2. 数据库变更流程

```bash
# 1. 修改models.go中的数据结构
# 2. 运行自动迁移
cd backend
go run . migrate

# 3. 测试数据库操作
go run .  # 启动服务测试

# 4. 更新API文档
# 修改docs/API.md
```

### 3. 前端组件开发流程

```bash
# 1. 创建新组件
cd frontend/src/components
touch NewComponent.vue

# 2. 编写组件代码
# 使用Vue 3 Composition API

# 3. 在页面中使用组件
# 导入并注册组件

# 4. 测试组件功能
npm run dev
```

## 📝 代码规范

### Go代码规范

#### 1. 命名规范
```go
// 包名：小写，简短
package handlers

// 函数名：驼峰命名
func createProject(c *gin.Context) {}

// 变量名：驼峰命名
var projectName string

// 常量：全大写，下划线分隔
const DEFAULT_PASSWORD = "zwl"
```

#### 2. 错误处理
```go
// 统一错误处理
if err != nil {
    log.Printf("错误: %v", err)
    c.JSON(http.StatusInternalServerError, gin.H{"error": "服务器内部错误"})
    return
}
```

#### 3. 注释规范
```go
// createProject 创建新项目
// 参数: c *gin.Context - Gin上下文
// 返回: JSON响应
func createProject(c *gin.Context) {
    // 实现代码
}
```

### Vue代码规范

#### 1. 组件命名
```javascript
// 组件名：PascalCase
export default {
  name: 'GanttChart'
}
```

#### 2. 变量命名
```javascript
// 变量名：camelCase
const projectList = ref([])
const isLoading = ref(false)

// 常量：UPPER_SNAKE_CASE
const DEFAULT_PASSWORD = 'zwl'
```

#### 3. 组件结构
```vue
<template>
  <!-- 模板内容 -->
</template>

<script>
// 脚本内容
</script>

<style scoped>
/* 样式内容 */
</style>
```

## 🐛 调试指南

### 后端调试

#### 1. 日志调试
```go
// 添加调试日志
log.Printf("调试信息: %+v", data)

// 查看服务日志
docker compose logs -f backend
```

#### 2. 数据库调试
```bash
# 连接数据库
docker compose exec postgres psql -U postgres -d gantt_excel

# 查看表结构
\dt

# 查询数据
SELECT * FROM projects;
```

#### 3. API调试
```bash
# 测试API接口
curl -X GET http://localhost:9898/api/v1/projects
curl -X POST http://localhost:9898/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"测试项目","start_date":"2024-01-01T00:00:00Z","end_date":"2024-12-31T23:59:59Z"}'
```

### 前端调试

#### 1. 浏览器调试
```javascript
// 添加调试日志
console.log('调试信息:', data)

// 使用Vue DevTools
// 安装Vue DevTools浏览器扩展
```

#### 2. 网络请求调试
```javascript
// 在浏览器开发者工具的Network标签页查看API请求
// 检查请求参数和响应数据
```

#### 3. 组件调试
```vue
<script>
// 使用Vue DevTools查看组件状态
// 在组件中添加调试信息
console.log('组件数据:', reactiveData)
</script>
```

### 容器调试

#### 1. 进入容器
```bash
# 进入后端容器
docker compose exec backend bash

# 进入前端容器
docker compose exec frontend bash

# 进入数据库容器
docker compose exec postgres bash
```

#### 2. 查看容器日志
```bash
# 查看所有服务日志
docker compose logs

# 查看特定服务日志
docker compose logs backend
docker compose logs frontend
docker compose logs postgres
```

#### 3. 容器状态检查
```bash
# 查看容器状态
docker compose ps

# 查看容器资源使用
docker stats
```

## ❓ 常见问题

### Q: 后端服务启动失败
**A**: 检查以下项目：
1. 数据库是否正常运行
2. 环境变量配置是否正确
3. 端口是否被占用
4. Go版本是否符合要求

```bash
# 检查数据库连接
docker compose exec postgres pg_isready -U postgres

# 检查端口占用
netstat -tlnp | grep 9898

# 查看详细错误日志
docker compose logs backend
```

### Q: 前端页面无法访问
**A**: 检查以下项目：
1. 前端服务是否启动
2. 端口配置是否正确
3. 代理配置是否正确

```bash
# 检查前端服务
docker compose ps frontend

# 检查端口占用
netstat -tlnp | grep 9897

# 查看前端日志
docker compose logs frontend
```

### Q: 数据库连接失败
**A**: 检查以下项目：
1. 数据库服务是否启动
2. 连接参数是否正确
3. 网络连接是否正常

```bash
# 检查数据库状态
docker compose exec postgres pg_isready -U postgres

# 测试数据库连接
docker compose exec postgres psql -U postgres -d gantt_excel -c "SELECT version();"
```

### Q: 甘特图显示异常
**A**: 检查以下项目：
1. 项目时间设置是否正确
2. 阶段和任务数据是否完整
3. 前端组件是否正确渲染

```javascript
// 在浏览器控制台检查数据
console.log('甘特图数据:', ganttData)

// 检查时间计算
console.log('时间线:', timelineDates)
```

### Q: 密码验证不工作
**A**: 检查以下项目：
1. 密码是否正确
2. 路由守卫是否正确配置
3. localStorage是否正常工作

```javascript
// 检查认证状态
console.log('认证状态:', localStorage.getItem('gantt_authenticated'))

// 检查路由配置
console.log('当前路由:', router.currentRoute.value)
```

## 🔧 开发工具推荐

### 后端开发工具
- **IDE**: GoLand / VS Code
- **API测试**: Postman / Insomnia
- **数据库管理**: pgAdmin / DBeaver
- **版本控制**: Git

### 前端开发工具
- **IDE**: VS Code / WebStorm
- **浏览器扩展**: Vue DevTools
- **包管理**: npm / yarn
- **构建工具**: Vite

### 通用工具
- **容器管理**: Docker Desktop
- **终端**: iTerm2 (macOS) / Windows Terminal
- **文本编辑**: VS Code / Vim
- **版本控制**: Git

## 📚 学习资源

### Go学习资源
- [Go官方文档](https://golang.org/doc/)
- [Gin框架文档](https://gin-gonic.com/docs/)
- [GORM文档](https://gorm.io/docs/)

### Vue学习资源
- [Vue 3官方文档](https://vuejs.org/)
- [Vite文档](https://vitejs.dev/)
- [Element Plus文档](https://element-plus.org/)

### 数据库学习资源
- [PostgreSQL文档](https://www.postgresql.org/docs/)
- [SQL教程](https://www.w3schools.com/sql/)

---

**注意**: 开发过程中遇到问题，请先查看本文档的常见问题部分，如果问题仍未解决，请联系项目维护者。
