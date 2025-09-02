# 咸鱼甘特图 - API接口文档

## 📖 概述

本文档描述了咸鱼甘特图系统的后端API接口。所有API接口都基于RESTful设计原则，使用JSON格式进行数据交换。

## 🌐 基础信息

- **基础URL**: `http://YOUR_SERVER_IP:9898/api/v1`
- **数据格式**: JSON
- **字符编码**: UTF-8
- **认证方式**: 无（前端通过密码验证）

## 📋 通用响应格式

### 成功响应
```json
{
  "data": "响应数据",
  "message": "操作成功"
}
```

### 错误响应
```json
{
  "error": "错误信息描述"
}
```

## 🔍 健康检查

### GET /health
检查服务健康状态

**响应示例**:
```json
{
  "status": "ok",
  "message": "咸鱼甘特图后端服务运行正常"
}
```

## 📊 项目管理接口

### 获取项目列表
**GET** `/projects`

**查询参数**:
- `page` (可选): 页码，默认为1
- `limit` (可选): 每页数量，默认为10
- `search` (可选): 搜索关键词

**响应示例**:
```json
{
  "data": [
    {
      "id": 1,
      "name": "示例项目",
      "description": "项目描述",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-12-31T23:59:59Z",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10
}
```

### 创建项目
**POST** `/projects`

**请求体**:
```json
{
  "name": "新项目",
  "description": "项目描述",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-12-31T23:59:59Z",
  "status": "active"
}
```

**响应示例**:
```json
{
  "data": {
    "id": 1,
    "name": "新项目",
    "description": "项目描述",
    "start_date": "2024-01-01T00:00:00Z",
    "end_date": "2024-12-31T23:59:59Z",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  },
  "message": "项目创建成功"
}
```

### 获取项目详情
**GET** `/projects/{id}`

**路径参数**:
- `id`: 项目ID

**响应示例**:
```json
{
  "data": {
    "id": 1,
    "name": "示例项目",
    "description": "项目描述",
    "start_date": "2024-01-01T00:00:00Z",
    "end_date": "2024-12-31T23:59:59Z",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "stages": [
      {
        "id": 1,
        "name": "需求分析",
        "description": "需求分析阶段",
        "start_date": "2024-01-01T00:00:00Z",
        "end_date": "2024-01-15T23:59:59Z",
        "status": "completed",
        "progress": 100,
        "project_id": 1
      }
    ],
    "team_members": [
      {
        "id": 1,
        "name": "张三",
        "role": "PM",
        "email": "zhangsan@example.com",
        "phone": "13800138000",
        "project_id": 1
      }
    ]
  }
}
```

### 更新项目
**PUT** `/projects/{id}`

**路径参数**:
- `id`: 项目ID

**请求体**:
```json
{
  "name": "更新后的项目名称",
  "description": "更新后的项目描述",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-12-31T23:59:59Z",
  "status": "completed"
}
```

### 删除项目
**DELETE** `/projects/{id}`

**路径参数**:
- `id`: 项目ID

**响应示例**:
```json
{
  "message": "项目删除成功"
}
```

### 导出项目Excel
**GET** `/projects/{id}/export`

**路径参数**:
- `id`: 项目ID

**响应**: 返回Excel文件流

## 📅 项目阶段接口

### 创建阶段
**POST** `/stages`

**请求体**:
```json
{
  "name": "需求分析",
  "description": "需求分析阶段",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-15T23:59:59Z",
  "status": "active",
  "progress": 0,
  "project_id": 1
}
```

### 获取项目阶段列表
**GET** `/stages/project/{projectId}`

**路径参数**:
- `projectId`: 项目ID

**响应示例**:
```json
{
  "data": [
    {
      "id": 1,
      "name": "需求分析",
      "description": "需求分析阶段",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-01-15T23:59:59Z",
      "status": "completed",
      "progress": 100,
      "project_id": 1,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 更新阶段
**PUT** `/stages/{id}`

**路径参数**:
- `id`: 阶段ID

**请求体**:
```json
{
  "name": "更新后的阶段名称",
  "description": "更新后的阶段描述",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-15T23:59:59Z",
  "status": "completed",
  "progress": 100
}
```

## 👥 团队成员接口

### 创建团队成员
**POST** `/members`

**请求体**:
```json
{
  "name": "张三",
  "role": "PM",
  "email": "zhangsan@example.com",
  "phone": "13800138000",
  "project_id": 1
}
```

### 获取项目团队成员列表
**GET** `/members/project/{projectId}`

**路径参数**:
- `projectId`: 项目ID

**响应示例**:
```json
{
  "data": [
    {
      "id": 1,
      "name": "张三",
      "role": "PM",
      "email": "zhangsan@example.com",
      "phone": "13800138000",
      "project_id": 1,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 更新团队成员
**PUT** `/members/{id}`

**路径参数**:
- `id`: 成员ID

**请求体**:
```json
{
  "name": "张三",
  "role": "PO",
  "email": "zhangsan@example.com",
  "phone": "13800138000"
}
```

## 📋 任务管理接口

### 创建任务
**POST** `/tasks`

**请求体**:
```json
{
  "name": "需求调研",
  "description": "进行用户需求调研",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-05T23:59:59Z",
  "status": "active",
  "priority": "high",
  "progress": 0,
  "stage_id": 1
}
```

### 更新任务
**PUT** `/tasks/{id}`

**路径参数**:
- `id`: 任务ID

**请求体**:
```json
{
  "name": "需求调研",
  "description": "进行用户需求调研",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-01-05T23:59:59Z",
  "status": "completed",
  "priority": "high",
  "progress": 100
}
```

## 🎭 角色管理接口

### 获取角色列表
**GET** `/roles`

**响应示例**:
```json
{
  "data": [
    {
      "id": 1,
      "name": "PM",
      "display_name": "项目经理",
      "description": "负责项目整体管理"
    },
    {
      "id": 2,
      "name": "PO",
      "display_name": "产品负责人",
      "description": "负责产品需求管理"
    },
    {
      "id": 3,
      "name": "前端",
      "display_name": "前端开发",
      "description": "负责前端开发工作"
    },
    {
      "id": 4,
      "name": "后端",
      "display_name": "后端开发",
      "description": "负责后端开发工作"
    },
    {
      "id": 5,
      "name": "UI",
      "display_name": "UI设计师",
      "description": "负责界面设计"
    },
    {
      "id": 6,
      "name": "特效",
      "display_name": "特效设计师",
      "description": "负责特效设计"
    },
    {
      "id": 7,
      "name": "音频",
      "display_name": "音频设计师",
      "description": "负责音频设计"
    },
    {
      "id": 8,
      "name": "测试",
      "display_name": "测试工程师",
      "description": "负责测试工作"
    }
  ]
}
```

## 📊 甘特图数据接口

### 获取甘特图数据
**GET** `/gantt/{projectId}`

**路径参数**:
- `projectId`: 项目ID

**响应示例**:
```json
{
  "data": {
    "project": {
      "id": 1,
      "name": "示例项目",
      "start_date": "2024-01-01T00:00:00Z",
      "end_date": "2024-12-31T23:59:59Z"
    },
    "stages": [
      {
        "id": 1,
        "name": "需求分析",
        "start_date": "2024-01-01T00:00:00Z",
        "end_date": "2024-01-15T23:59:59Z",
        "status": "completed",
        "progress": 100,
        "tasks": [
          {
            "id": 1,
            "name": "需求调研",
            "start_date": "2024-01-01T00:00:00Z",
            "end_date": "2024-01-05T23:59:59Z",
            "status": "completed",
            "priority": "high",
            "progress": 100
          }
        ]
      }
    ]
  }
}
```

## 📝 数据模型

### 项目 (Project)
```json
{
  "id": "integer",
  "name": "string",
  "description": "string",
  "start_date": "datetime",
  "end_date": "datetime",
  "status": "string (active/completed/paused)",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 阶段 (Stage)
```json
{
  "id": "integer",
  "name": "string",
  "description": "string",
  "start_date": "datetime",
  "end_date": "datetime",
  "status": "string (active/completed/paused)",
  "progress": "integer (0-100)",
  "project_id": "integer",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 任务 (Task)
```json
{
  "id": "integer",
  "name": "string",
  "description": "string",
  "start_date": "datetime",
  "end_date": "datetime",
  "status": "string (active/completed/paused)",
  "priority": "string (low/medium/high)",
  "progress": "integer (0-100)",
  "stage_id": "integer",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 团队成员 (TeamMember)
```json
{
  "id": "integer",
  "name": "string",
  "role": "string",
  "email": "string",
  "phone": "string",
  "project_id": "integer",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 角色 (Role)
```json
{
  "id": "integer",
  "name": "string",
  "display_name": "string",
  "description": "string"
}
```

## ⚠️ 错误码说明

| HTTP状态码 | 说明 |
|-----------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 🔧 使用示例

### JavaScript (fetch)
```javascript
// 获取项目列表
fetch('http://localhost:9898/api/v1/projects')
  .then(response => response.json())
  .then(data => console.log(data));

// 创建新项目
fetch('http://localhost:9898/api/v1/projects', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: '新项目',
    description: '项目描述',
    start_date: '2024-01-01T00:00:00Z',
    end_date: '2024-12-31T23:59:59Z',
    status: 'active'
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

### curl
```bash
# 获取项目列表
curl -X GET http://localhost:9898/api/v1/projects

# 创建新项目
curl -X POST http://localhost:9898/api/v1/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "新项目",
    "description": "项目描述",
    "start_date": "2024-01-01T00:00:00Z",
    "end_date": "2024-12-31T23:59:59Z",
    "status": "active"
  }'
```

## 📞 技术支持

如果在使用API过程中遇到问题，请：

1. 检查请求URL和参数是否正确
2. 确认服务是否正常运行
3. 查看响应中的错误信息
4. 联系系统管理员获取技术支持

---

**注意**: 所有时间字段都使用ISO 8601格式 (UTC时间)，如：`2024-01-01T00:00:00Z`
