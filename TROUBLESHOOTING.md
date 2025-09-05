# 故障排除指南

## 🔍 常见问题诊断

### 快速诊断检查清单

在遇到问题时，请按以下顺序检查：

1. **服务状态检查**
```bash
docker-compose -f docker-compose.fixed.yml ps
```

2. **网络连接测试**
```bash
curl http://localhost:3000  # 前端
curl http://localhost:8080/api/v1/health  # 后端
```

3. **日志查看**
```bash
docker-compose -f docker-compose.fixed.yml logs -f
```

## 🐛 具体问题解决

### 1. 部署和启动问题

#### 问题: Docker构建失败
**现象**: `vite: not found` 或构建过程中断

**解决方案**:
```bash
# 清理Docker缓存
docker system prune -a

# 重新构建
docker-compose -f docker-compose.fixed.yml build --no-cache

# 检查Docker版本
docker --version
docker-compose --version
```

**原因**: 
- Docker缓存问题
- 依赖安装不完整
- 网络连接问题

#### 问题: 端口占用
**现象**: `Port 3000 is already in use`

**解决方案**:
```bash
# 查找占用端口的进程
sudo netstat -tlnp | grep :3000
sudo lsof -i :3000

# 停止占用进程
sudo kill -9 <PID>

# 或修改端口配置
# 编辑 docker-compose.fixed.yml 中的端口映射
```

#### 问题: 权限不足
**现象**: `Permission denied`

**解决方案**:
```bash
# 添加用户到docker组
sudo usermod -aG docker $USER

# 重新登录或刷新组权限
newgrp docker

# 检查文件权限
ls -la
sudo chown -R $USER:$USER .
```

### 2. 甘特图显示问题

#### 问题: 甘特图条与时间轴不对齐
**现象**: 任务条位置与日期不匹配

**解决方案**:
1. **确认版本**: 确保使用v1.2.0或更高版本
2. **清理缓存**: 强制刷新浏览器 (Ctrl+F5)
3. **检查数据**: 确认任务时间在项目范围内

**调试步骤**:
```bash
# 查看浏览器控制台调试信息
# 应该看到 "甘特图条调试:" 的详细日志

# 访问测试页面验证
http://your-server:3000/test/gantt
```

#### 问题: 结束时间显示错误
**现象**: 周五结束的任务显示在周四结束

**解决方案**:
- 这个问题在v1.2.0中已修复
- 确保使用最新版本的代码
- 重新构建前端服务

#### 问题: 无法滚动查看后面日期
**现象**: 甘特图无法水平滚动

**解决方案**:
1. **检查CSS**: 确保容器有正确的overflow设置
2. **浏览器兼容**: 使用现代浏览器
3. **内容宽度**: 确认甘特图内容宽度足够

### 3. API访问问题

#### 问题: 405 Method Not Allowed
**现象**: 创建项目时出现405错误

**解决方案**:
1. **检查nginx代理**: 确认前端nginx正确代理API请求
2. **重新构建前端**: 使用最新的Dockerfile配置
3. **网络检查**: 确认前后端容器网络连通

**验证步骤**:
```bash
# 直接测试后端API
curl -X POST http://localhost:8080/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'

# 测试前端代理
curl -X POST http://localhost:3000/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'
```

#### 问题: 角色选择没有选项
**现象**: 团队成员角色下拉框为空

**解决方案**:
1. **API连接**: 检查 `/api/v1/roles` 接口是否正常
2. **网络代理**: 确认前端能正确访问后端
3. **数据库**: 确认角色数据已初始化

**检查步骤**:
```bash
# 测试角色API
curl http://localhost:3000/api/v1/roles

# 检查数据库角色数据
docker-compose -f docker-compose.fixed.yml exec postgres \
  psql -U postgres -d gantt_excel -c "SELECT * FROM roles;"
```

### 4. Excel导出问题

#### 问题: Excel导出位置偏移
**现象**: 甘特图条在Excel中位置不准确

**解决方案**:
- 这个问题在v1.2.0中已修复
- 重新构建后端服务
- 测试导出功能

#### 问题: 导出文件损坏
**现象**: Excel文件无法打开

**解决方案**:
```bash
# 检查后端日志
docker-compose -f docker-compose.fixed.yml logs backend

# 测试导出API
curl http://localhost:8080/api/v1/projects/1/export \
  -o test.xlsx

# 检查文件大小
ls -la test.xlsx
```

### 5. 数据库问题

#### 问题: 数据库连接失败
**现象**: `connection refused` 或 `database not found`

**解决方案**:
```bash
# 检查数据库状态
docker-compose -f docker-compose.fixed.yml exec postgres pg_isready

# 查看数据库日志
docker-compose -f docker-compose.fixed.yml logs postgres

# 重启数据库服务
docker-compose -f docker-compose.fixed.yml restart postgres
```

#### 问题: 数据丢失
**现象**: 之前创建的项目消失

**解决方案**:
```bash
# 检查数据卷
docker volume ls
docker volume inspect gantt-excel_postgres_data

# 备份数据库
docker-compose -f docker-compose.fixed.yml exec postgres \
  pg_dump -U postgres gantt_excel > backup.sql

# 恢复数据库
docker-compose -f docker-compose.fixed.yml exec -T postgres \
  psql -U postgres gantt_excel < backup.sql
```

### 6. 性能问题

#### 问题: 页面加载慢
**现象**: 前端页面响应缓慢

**解决方案**:
```bash
# 检查资源使用
docker stats

# 查看系统资源
free -h
df -h

# 优化配置
# 编辑 docker-compose.fixed.yml 调整资源限制
```

#### 问题: 内存不足
**现象**: 容器频繁重启或OOM错误

**解决方案**:
```bash
# 监控内存使用
docker stats --no-stream

# 增加swap空间
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 调整容器资源限制
# 在 docker-compose.fixed.yml 中设置合适的内存限制
```

## 🔧 调试工具和方法

### 浏览器调试
1. **开发者工具**: F12打开，查看Network和Console标签
2. **网络请求**: 检查API请求是否正常发送和响应
3. **控制台日志**: 查看JavaScript错误和调试信息
4. **本地存储**: 检查localStorage中的认证信息

### 后端调试
```bash
# 查看实时日志
docker-compose -f docker-compose.fixed.yml logs -f backend

# 进入后端容器
docker-compose -f docker-compose.fixed.yml exec backend sh

# 检查后端健康状态
curl http://localhost:8080/api/v1/health
```

### 数据库调试
```bash
# 连接数据库
docker-compose -f docker-compose.fixed.yml exec postgres \
  psql -U postgres -d gantt_excel

# 查看表结构
\dt
\d projects
\d stages
\d tasks

# 查看数据
SELECT * FROM projects LIMIT 5;
SELECT * FROM roles;
```

### 网络调试
```bash
# 检查容器网络
docker network ls
docker network inspect gantt-network

# 测试容器间连通性
docker-compose -f docker-compose.fixed.yml exec frontend ping backend
docker-compose -f docker-compose.fixed.yml exec backend ping postgres

# 检查端口监听
docker-compose -f docker-compose.fixed.yml exec backend netstat -tlnp
```

## 📞 获取技术支持

### 提交问题前的准备
请收集以下信息：

1. **系统信息**:
```bash
uname -a
docker --version
docker-compose --version
```

2. **错误日志**:
```bash
docker-compose -f docker-compose.fixed.yml logs > logs.txt
```

3. **服务状态**:
```bash
docker-compose -f docker-compose.fixed.yml ps
```

4. **网络测试结果**:
```bash
curl -v http://localhost:3000
curl -v http://localhost:8080/api/v1/health
```

### 问题报告模板
```markdown
## 问题描述
[简要描述遇到的问题]

## 复现步骤
1. [第一步]
2. [第二步]
3. [第三步]

## 期望结果
[描述期望看到的结果]

## 实际结果
[描述实际发生的情况]

## 环境信息
- 操作系统: 
- Docker版本: 
- 项目版本: 

## 错误日志
[粘贴相关的错误日志]

## 截图
[如果有UI问题，请提供截图]
```

### 联系方式
- **GitHub Issues**: 在项目仓库中提交Issue
- **文档查看**: 查阅相关文档获取更多信息

## 📋 预防措施

### 定期维护
```bash
# 每周清理Docker缓存
docker system prune -f

# 每月备份数据库
docker-compose -f docker-compose.fixed.yml exec postgres \
  pg_dump -U postgres gantt_excel > backup-$(date +%Y%m%d).sql

# 监控磁盘空间
df -h
```

### 系统监控
```bash
# 设置资源监控
watch 'docker stats --no-stream'

# 日志轮转
# 配置Docker日志轮转防止日志文件过大
```

### 安全更新
```bash
# 定期更新系统
sudo apt update && sudo apt upgrade

# 更新Docker镜像
docker-compose -f docker-compose.fixed.yml pull
docker-compose -f docker-compose.fixed.yml up -d
```

---

**版本**: v1.2.0  
**更新日期**: 2024年12月  
**维护**: 定期更新，确保问题解决方案的有效性