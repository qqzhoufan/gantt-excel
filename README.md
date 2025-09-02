# 咸鱼甘特图 (Gantt-Excel)

一个基于Go后端和Vue前端的甘特图项目管理系统，支持自动生成项目阶段时间线和自定义团队角色管理。

## 🎯 功能特点

- 🔐 密码保护访问（默认密码：zwl）
- 🗓️ 自动生成项目各阶段甘特图
- 👥 自定义团队角色管理（PM、PO、客户端、服务器、UI、特效、音频、测试等）
- 💾 本地PostgreSQL数据存储
- 🎯 直观的项目进度可视化
- 📱 响应式设计，支持移动端
- 📊 Excel导出功能（项目信息、甘特图、团队成员）
- 🔄 批量项目操作和导出
- ⏰ 工作日计算（自动排除周末）
- 🎨 横向甘特图时间线可视化
- ✏️ 甘特图任务和阶段编辑功能

## 🚀 快速开始

### 方式一：Docker Compose一键启动（推荐）
```bash
# 启动所有服务（数据库、后端、前端）
./scripts/docker-compose-start.sh

# 或者手动启动
docker compose up --build -d
```

### 方式二：Docker一键启动（旧版本）
```bash
./scripts/docker-start.sh
```

### 方式三：本地安装
```bash
# 1. 启动PostgreSQL
docker compose up -d postgres

# 2. 启动后端
cd backend && go run .

# 3. 启动前端
cd frontend && npm install && npm run dev
```

## 🌐 访问地址

- **前端**: http://YOUR_IP:9897
- **后端**: http://YOUR_IP:9898
- **数据库**: localhost:5432

## 🔐 访问说明

首次访问前端应用时，需要输入密码进行身份验证：
- **默认密码**: `zwl`
- **会话有效期**: 24小时
- **退出登录**: 点击页面右上角的"退出登录"按钮

## 🔧 技术栈

- **后端**: Go (端口: 9898)
  - Gin Web框架
  - GORM ORM
  - PostgreSQL数据库
  - Excelize Excel文件生成
- **前端**: Vue.js 3 (端口: 9897)
  - Element Plus UI组件库
  - Vite构建工具
  - Pinia状态管理
  - Day.js 日期处理
- **数据库**: PostgreSQL
- **架构**: 前后端分离
- **部署**: Docker + Docker Compose

## 📁 项目结构

```
gantt-excel/
├── backend/          # Go后端服务
│   ├── main.go      # 主程序入口
│   ├── models.go    # 数据模型
│   ├── handlers.go  # API处理器
│   ├── database.go  # 数据库连接
│   ├── config.go    # 配置管理
│   ├── Dockerfile   # 后端容器配置
│   └── env.local    # 环境变量配置
├── frontend/         # Vue前端应用
│   ├── src/
│   │   ├── components/  # 组件
│   │   ├── views/       # 页面
│   │   ├── stores/      # 状态管理
│   │   └── utils/       # 工具函数
│   ├── Dockerfile       # 前端容器配置
│   ├── nginx.conf       # Nginx配置
│   ├── vite.config.js   # Vite配置
│   └── env.local        # 环境变量配置
├── database/         # 数据库脚本
│   └── init.sql     # 初始化脚本
├── scripts/          # 管理脚本
│   ├── docker-compose-start.sh # Docker Compose启动脚本
│   ├── docker-start.sh         # Docker启动脚本
│   ├── firewall-setup.sh       # 防火墙配置脚本
│   ├── network-test.sh         # 网络测试脚本
│   └── test.sh                 # 测试脚本
├── docker-compose.yml # Docker Compose配置
└── docs/            # 项目文档
```

## 🎨 界面预览

- **项目列表页**: 项目概览、统计信息、搜索功能、批量选择导出
- **项目详情页**: 甘特图、团队管理、阶段跟踪、Excel导出
- **新建项目页**: 项目配置、阶段设置、团队配置

## 📋 功能演示

### Excel导出功能
导出的Excel文件包含4个工作表：
1. **甘特图** - 项目基本信息和甘特图数据
2. **甘特图数据** - 详细的数据表格
3. **甘特图时间线** - 横向甘特图可视化
4. **团队成员信息** - 团队成员详细信息

### 批量操作
- 支持多选项目进行批量导出
- 智能文件命名：`项目名称_甘特图.xlsx`
- 响应式选择界面，实时显示选中数量

### 甘特图特性
- 横向时间线显示
- 工作日计算（自动排除周末）
- 阶段和任务工期显示
- 彩色状态区分

## 📊 核心功能

### 项目管理
- 创建、编辑、删除项目
- 项目状态管理（进行中、已完成、已暂停）
- 项目时间线设置
- 批量项目选择和操作

### 甘特图
- 可视化项目时间线
- 横向甘特图时间线显示
- 工作日计算（自动排除周末）
- 阶段和任务工期显示
- 进度条显示和拖拽交互
- 任务和阶段在线编辑功能
- 实时保存编辑内容

### 团队管理
- 支持多种角色：PM、PO、前端、后端、UI、特效、音频、测试
- 团队成员分配和权限管理
- 任务分配和跟踪
- 团队成员信息管理

### Excel导出
- 项目基本信息导出
- 甘特图数据表格导出
- 横向甘特图时间线可视化导出
- 团队成员信息导出
- 支持单个和批量项目导出
- 智能文件命名（项目名称_甘特图.xlsx）

## 🚨 环境要求

- Go 1.19+
- Node.js 16+
- PostgreSQL 12+
- Docker 20.10+ (推荐)

## 🌐 网络配置

### 端口说明
- **9897**: 前端服务端口
- **9898**: 后端服务端口  
- **5432**: PostgreSQL数据库端口

### 防火墙配置
```bash
# 配置防火墙规则
sudo ./scripts/firewall-setup.sh

# 测试网络连通性
./scripts/network-test.sh
```

### 外部访问配置
1. 确保服务绑定到 `0.0.0.0` 接口
2. 开放防火墙端口 9897 和 9898
3. 如果使用云服务器，配置安全组规则

## 📖 详细文档

- [快速启动指南](./QUICKSTART.md)
- [部署指南](./DEPLOYMENT.md)
- [用户使用手册](./docs/USER_GUIDE.md)
- [API接口文档](./docs/API.md)
- [开发指南](./docs/DEVELOPMENT.md)

## 🔧 开发状态

✅ **已完成功能**
- 项目基础架构
- 后端API服务
- 前端Vue应用
- 甘特图组件
- 团队角色管理
- 数据库设计
- 部署脚本
- Docker容器化
- 网络配置优化
- Excel导出功能
- 批量项目操作
- 横向甘特图时间线
- 工作日计算
- 团队成员信息管理
- 智能文件命名
- 响应式选择功能
- 密码保护访问控制
- 甘特图任务和阶段编辑功能

🔄 **进行中**
- 代码优化和测试

📋 **计划功能**
- 用户认证系统
- 数据导入功能
- 移动端适配
- 实时协作
- 更多导出格式支持

## 🚀 部署指南

### 1. 克隆项目
```bash
git clone <repository-url>
cd gantt-excel
```

### 2. 启动服务
```bash
# 使用Docker Compose（推荐）
./scripts/docker-compose-start.sh

# 或手动启动
docker compose up --build -d
```

### 3. 配置防火墙
```bash
sudo ./scripts/firewall-setup.sh
```

### 4. 测试访问
```bash
./scripts/network-test.sh
```

### 5. 访问应用
- 前端: http://YOUR_SERVER_IP:9897
- 后端: http://YOUR_SERVER_IP:9898

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 项目主页: [GitHub Repository]
- 问题反馈: [Issues]
- 功能建议: [Discussions]

---

🎉 **咸鱼甘特图 - 让项目管理变得简单高效！**
