# GitHub仓库提交指南

## 🚀 将项目提交到GitHub

### 1. 在GitHub上创建新仓库

1. 登录到 [GitHub](https://github.com)
2. 点击右上角的 "+" 按钮，选择 "New repository"
3. 填写仓库信息：
   - **Repository name**: `gantt-excel` 或您喜欢的名称
   - **Description**: `咸鱼甘特图 - 基于Go和Vue的项目管理系统`
   - **Visibility**: 选择 Public 或 Private
   - **不要**勾选 "Initialize this repository with a README"（因为我们已经有了）
4. 点击 "Create repository"

### 2. 配置Git用户信息

```bash
# 替换为您的真实信息
git config --global user.name "您的姓名"
git config --global user.email "您的邮箱@example.com"
```

### 3. 添加GitHub远程仓库

```bash
# 替换为您的GitHub用户名和仓库名
git remote add origin https://github.com/您的用户名/gantt-excel.git

# 验证远程仓库配置
git remote -v
```

### 4. 推送到GitHub

```bash
# 推送到GitHub主分支
git push -u origin main
```

### 5. 验证提交

1. 访问您的GitHub仓库页面
2. 确认所有文件都已成功上传
3. 检查README.md是否正确显示

## 🔧 后续开发流程

### 日常开发提交

```bash
# 1. 查看修改状态
git status

# 2. 添加修改的文件
git add .

# 3. 提交修改
git commit -m "feat: 添加新功能描述"

# 4. 推送到GitHub
git push origin main
```

### 创建功能分支

```bash
# 1. 创建并切换到新分支
git checkout -b feature/新功能名称

# 2. 进行开发工作
# ... 修改代码 ...

# 3. 提交修改
git add .
git commit -m "feat: 实现新功能"

# 4. 推送分支到GitHub
git push origin feature/新功能名称

# 5. 在GitHub上创建Pull Request
```

## 📝 提交信息规范

### 提交类型
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 提交信息格式
```
类型: 简短描述

详细描述（可选）

相关Issue: #123
```

### 示例
```bash
git commit -m "feat: 添加密码验证功能

- 实现前端密码验证组件
- 添加路由守卫
- 支持会话管理

相关Issue: #1"
```

## 🔒 安全注意事项

### 敏感信息处理
- **不要**提交包含密码、API密钥等敏感信息的文件
- 使用 `.env.example` 文件作为配置模板
- 确保 `.gitignore` 文件正确配置

### 当前项目的敏感信息
- 默认密码 `zwl` 在代码中（可考虑移到环境变量）
- 数据库密码在 `docker-compose.yml` 中（生产环境需要修改）

## 📋 仓库管理建议

### 1. 添加仓库描述
在GitHub仓库页面添加：
- **Description**: `咸鱼甘特图 - 基于Go和Vue的项目管理系统，支持甘特图可视化、团队管理、Excel导出`
- **Topics**: `gantt-chart`, `project-management`, `vue`, `golang`, `docker`

### 2. 设置仓库标签
- `enhancement`: 功能增强
- `bug`: 问题修复
- `documentation`: 文档更新
- `help wanted`: 需要帮助

### 3. 创建Issues模板
在 `.github/ISSUE_TEMPLATE/` 目录下创建：
- `bug_report.md`: Bug报告模板
- `feature_request.md`: 功能请求模板

## 🎯 项目展示

### README.md优化
您的README.md已经包含了：
- ✅ 项目介绍和功能特点
- ✅ 技术栈说明
- ✅ 快速开始指南
- ✅ 部署说明
- ✅ 文档链接

### 添加徽章
可以在README.md顶部添加一些徽章：
```markdown
![Go Version](https://img.shields.io/badge/Go-1.19+-blue)
![Vue Version](https://img.shields.io/badge/Vue-3.3+-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Docker](https://img.shields.io/badge/Docker-Supported-blue)
```

## 🚀 发布版本

### 创建Release
1. 在GitHub仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 填写版本信息：
   - **Tag version**: `v1.0.0`
   - **Release title**: `咸鱼甘特图 v1.0.0`
   - **Description**: 描述此版本的新功能和修复

### 版本标签
```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签到GitHub
git push origin v1.0.0
```

## 📞 获取帮助

如果在提交过程中遇到问题：

1. **认证问题**: 检查GitHub用户名和密码/Token
2. **权限问题**: 确认您有仓库的写入权限
3. **网络问题**: 检查网络连接和防火墙设置
4. **冲突问题**: 使用 `git pull` 同步远程更改

---

**恭喜！您的咸鱼甘特图项目现在已经准备好提交到GitHub了！** 🎉
