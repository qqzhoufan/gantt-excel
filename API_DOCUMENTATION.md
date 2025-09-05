# API 接口文档

## 📋 概述

甘特图项目管理系统提供RESTful API接口，支持项目管理、任务调度、团队协作等功能。

### 基础信息
- **Base URL**: `http://your-server:8080/api/v1`
- **认证方式**: 基于密码的简单认证
- **数据格式**: JSON
- **字符编码**: UTF-8

## 🔐 认证

系统使用密码验证机制，前端通过密码验证后可访问所有API接口。

## 📊 API 接口列表

### 健康检查

#### GET /health
检查系统健康状态

**请求示例**:
```bash
curl http://localhost:8080/api/v1/health
```

**响应示例**:
```json
{
  "status": "ok",
  "message": "咸鱼甘特图后端服务运行正常"
}
```

---

### 项目管理

#### GET /projects
获取所有项目列表

**请求示例**:
```bash
curl http://localhost:8080/api/v1/projects
```

**响应示例**:
```json
[
  {
    "id": 1,
    "name": "示例项目",
    "description": "这是一个示例项目",
    "start_date": "2024-01-01T00:00:00Z",
    "end_date": "2024-12-31T00:00:00Z",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "stages": [...],
    "team_members": [...]
  }
]
```

#### POST /projects
创建新项目

**请求示例**:
```bash
curl -X POST http://localhost:8080/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "新项目",
    "description": "项目描述",
    "start_date": "2024-01-01T00:00:00Z",
    "end_date": "2024-12-31T00:00:00Z",
    "status": "active"
  }'
```

**请求参数**:
| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| name | string | 是 | 项目名称 |
| description | string | 否 | 项目描述 |
| start_date | datetime | 是 | 项目开始日期 |
| end_date | datetime | 是 | 项目结束日期 |
| status | string | 否 | 项目状态 (active/completed/paused) |

**响应示例**:
```json
{
  "id": 2,
  "name": "新项目",
  "description": "项目描述",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-12-31T00:00:00Z",
  "status": "active",
  "created_at": "2024-12-01T10:00:00Z",
  "updated_at": "2024-12-01T10:00:00Z"
}
```

#### GET /projects/{id}
获取指定项目详情

**请求示例**:
```bash
curl http://localhost:8080/api/v1/projects/1
```

**响应示例**:
```json
{
  "id": 1,
  "name": "示例项目",
  "description": "这是一个示例项目",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-12-31T00:00:00Z",
  "status": "active",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "stages": [
    {
      "id": 1,
      "name": "需求分析",
      "description": "项目需求分析阶段",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-01-31T00:00:00Z",
      "status": "completed",
      "progress": 100,
      "tasks": [...]
    }
  ],
  "team_members": [
    {
      "id": 1,
      "name": "张三",
      "email": "zhangsan@example.com",
      "role": "pm",
      "is_active": true
    }
  ]
}
```

#### PUT /projects/{id}
更新项目信息

**请求示例**:
```bash
curl -X PUT http://localhost:8080/api/v1/projects/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "更新后的项目名称",
    "status": "completed"
  }'
```

#### DELETE /projects/{id}
删除项目

**请求示例**:
```bash
curl -X DELETE http://localhost:8080/api/v1/projects/1
```

#### GET /projects/{id}/export
导出项目甘特图为Excel

**请求示例**:
```bash
curl http://localhost:8080/api/v1/projects/1/export \
  -o project_gantt.xlsx
```

**响应**: Excel文件二进制数据

---

### 项目阶段管理

#### POST /stages
创建项目阶段

**请求示例**:
```bash
curl -X POST http://localhost:8080/api/v1/stages \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "name": "开发阶段",
    "description": "系统开发阶段",
    "start_date": "2024-02-01T00:00:00Z",
    "end_date": "2024-06-30T00:00:00Z",
    "status": "in_progress",
    "progress": 50
  }'
```

**请求参数**:
| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| project_id | integer | 是 | 所属项目ID |
| name | string | 是 | 阶段名称 |
| description | string | 否 | 阶段描述 |
| start_date | datetime | 是 | 阶段开始日期 |
| end_date | datetime | 是 | 阶段结束日期 |
| status | string | 否 | 阶段状态 (pending/in_progress/completed) |
| progress | float | 否 | 完成进度 (0-100) |

#### GET /stages/project/{projectId}
获取项目的所有阶段

**请求示例**:
```bash
curl http://localhost:8080/api/v1/stages/project/1
```

#### PUT /stages/{id}
更新阶段信息

**请求示例**:
```bash
curl -X PUT http://localhost:8080/api/v1/stages/1 \
  -H "Content-Type: application/json" \
  -d '{
    "progress": 75,
    "status": "in_progress"
  }'
```

---

### 任务管理

#### POST /tasks
创建任务

**请求示例**:
```bash
curl -X POST http://localhost:8080/api/v1/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "stage_id": 1,
    "name": "前端开发",
    "description": "开发用户界面",
    "start_date": "2024-02-01T00:00:00Z",
    "end_date": "2024-03-31T00:00:00Z",
    "status": "in_progress",
    "priority": "high",
    "progress": 30,
    "assigned_to": 2
  }'
```

**请求参数**:
| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| stage_id | integer | 是 | 所属阶段ID |
| name | string | 是 | 任务名称 |
| description | string | 否 | 任务描述 |
| start_date | datetime | 是 | 任务开始日期 |
| end_date | datetime | 是 | 任务结束日期 |
| status | string | 否 | 任务状态 (pending/in_progress/completed) |
| priority | string | 否 | 优先级 (low/medium/high/urgent) |
| progress | float | 否 | 完成进度 (0-100) |
| assigned_to | integer | 否 | 指派成员ID |

#### PUT /tasks/{id}
更新任务信息

**请求示例**:
```bash
curl -X PUT http://localhost:8080/api/v1/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "progress": 80,
    "status": "in_progress"
  }'
```

---

### 团队成员管理

#### POST /members
添加团队成员

**请求示例**:
```bash
curl -X POST http://localhost:8080/api/v1/members \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "name": "李四",
    "email": "lisi@example.com",
    "role": "frontend",
    "is_active": true
  }'
```

**请求参数**:
| 参数 | 类型 | 必填 | 描述 |
|------|------|------|------|
| project_id | integer | 是 | 所属项目ID |
| name | string | 是 | 成员姓名 |
| email | string | 否 | 邮箱地址 |
| role | string | 是 | 角色 (pm/po/frontend/backend/ui/vfx/audio/tester) |
| is_active | boolean | 否 | 是否激活 (默认true) |

#### GET /members/project/{projectId}
获取项目团队成员

**请求示例**:
```bash
curl http://localhost:8080/api/v1/members/project/1
```

#### PUT /members/{id}
更新成员信息

**请求示例**:
```bash
curl -X PUT http://localhost:8080/api/v1/members/1 \
  -H "Content-Type: application/json" \
  -d '{
    "role": "backend",
    "is_active": false
  }'
```

---

### 角色管理

#### GET /roles
获取所有可用角色

**请求示例**:
```bash
curl http://localhost:8080/api/v1/roles
```

**响应示例**:
```json
[
  {
    "id": 1,
    "name": "pm",
    "display_name": "项目经理(PM)",
    "color": "#e74c3c",
    "description": "负责项目整体规划和进度管理"
  },
  {
    "id": 2,
    "name": "po",
    "display_name": "产品经理(PO)",
    "color": "#f39c12",
    "description": "负责产品需求和功能设计"
  },
  {
    "id": 3,
    "name": "frontend",
    "display_name": "客户端程序",
    "color": "#3498db",
    "description": "负责前端界面和交互开发"
  },
  {
    "id": 4,
    "name": "backend",
    "display_name": "服务器程序",
    "color": "#2ecc71",
    "description": "负责后端服务和数据库开发"
  }
]
```

---

### 甘特图数据

#### GET /gantt/{projectId}
获取项目甘特图数据

**请求示例**:
```bash
curl http://localhost:8080/api/v1/gantt/1
```

**响应示例**:
```json
{
  "project": {
    "id": 1,
    "name": "示例项目",
    "start_date": "2024-01-01T00:00:00Z",
    "end_date": "2024-12-31T00:00:00Z",
    "status": "active"
  },
  "timeline": [
    {
      "id": 1,
      "name": "需求分析阶段",
      "start_date": "2024-01-01",
      "end_date": "2024-01-31",
      "progress": 100,
      "status": "completed",
      "tasks": [
        {
          "id": 1,
          "name": "需求调研",
          "start_date": "2024-01-01",
          "end_date": "2024-01-15",
          "progress": 100,
          "status": "completed",
          "priority": "high",
          "assignee": {
            "id": 1,
            "name": "张三",
            "role": "pm"
          }
        }
      ]
    }
  ]
}
```

## 📊 状态码说明

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 405 | 方法不允许 |
| 500 | 服务器内部错误 |

## 🔧 错误响应格式

```json
{
  "error": "错误信息描述"
}
```

## 📋 数据类型说明

### 项目状态 (status)
- `active`: 进行中
- `completed`: 已完成
- `paused`: 已暂停

### 任务/阶段状态 (status)
- `pending`: 待开始
- `in_progress`: 进行中
- `completed`: 已完成

### 优先级 (priority)
- `low`: 低
- `medium`: 中
- `high`: 高
- `urgent`: 紧急

### 角色 (role)
- `pm`: 项目经理
- `po`: 产品经理
- `frontend`: 客户端程序
- `backend`: 服务器程序
- `ui`: UI设计师
- `vfx`: 特效师
- `audio`: 音频师
- `tester`: 测试工程师

## 🧪 测试接口

可以使用以下工具测试API接口:
- **curl**: 命令行工具
- **Postman**: GUI工具
- **浏览器**: 直接访问GET接口

### 测试示例
```bash
# 测试健康检查
curl http://localhost:8080/api/v1/health

# 测试获取角色列表
curl http://localhost:8080/api/v1/roles

# 测试获取项目列表
curl http://localhost:8080/api/v1/projects
```

---

**版本**: v1.2.0  
**更新日期**: 2024年12月  
**技术支持**: 查看项目GitHub仓库获取更多信息