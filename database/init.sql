-- 咸鱼甘特图数据库初始化脚本

-- 注意：PostgreSQL不支持CREATE DATABASE IF NOT EXISTS语法
-- 数据库应该在docker-compose.yml中通过环境变量自动创建

-- 创建角色表
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#3498db',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建项目表
CREATE TABLE IF NOT EXISTS projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建团队成员表
CREATE TABLE IF NOT EXISTS team_members (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    role VARCHAR(50) NOT NULL,
    avatar VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建项目阶段表
CREATE TABLE IF NOT EXISTS stages (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    "order" INTEGER DEFAULT 0,
    progress DECIMAL(5,2) DEFAULT 0.00 CHECK (progress >= 0 AND progress <= 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建任务表
CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    stage_id INTEGER NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    progress DECIMAL(5,2) DEFAULT 0.00 CHECK (progress >= 0 AND progress <= 100),
    assigned_to INTEGER REFERENCES team_members(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入默认角色数据
INSERT INTO roles (name, display_name, color, description) VALUES
('pm', '项目经理(PM)', '#e74c3c', '负责项目整体规划和进度管理'),
('po', '产品经理(PO)', '#f39c12', '负责产品需求和功能设计'),
('frontend', '客户端程序', '#3498db', '负责前端界面和交互开发'),
('backend', '服务器程序', '#2ecc71', '负责后端服务和数据库开发'),
('ui', 'UI设计师', '#9b59b6', '负责用户界面设计'),
('vfx', '特效师', '#1abc9c', '负责视觉特效制作'),
('audio', '音频师', '#34495e', '负责音效和音乐制作'),
('tester', '测试工程师', '#95a5a6', '负责功能测试和质量保证')
ON CONFLICT (name) DO NOTHING;

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_team_members_project_id ON team_members(project_id);
CREATE INDEX IF NOT EXISTS idx_team_members_role ON team_members(role);
CREATE INDEX IF NOT EXISTS idx_stages_project_id ON stages(project_id);
CREATE INDEX IF NOT EXISTS idx_stages_order ON stages("order");
CREATE INDEX IF NOT EXISTS idx_tasks_stage_id ON tasks(stage_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为相关表创建更新时间触发器
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_team_members_updated_at BEFORE UPDATE ON team_members FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stages_updated_at BEFORE UPDATE ON stages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入示例项目数据
INSERT INTO projects (name, description, start_date, end_date, status) VALUES
('示例项目', '这是一个示例项目，用于演示甘特图功能', '2024-01-01', '2024-06-30', 'active')
ON CONFLICT DO NOTHING;

-- 插入示例阶段数据
INSERT INTO stages (project_id, name, description, start_date, end_date, status, "order", progress) VALUES
(1, '需求分析', '收集和分析项目需求', '2024-01-01', '2024-01-31', 'completed', 1, 100.00),
(1, '设计阶段', '系统架构和界面设计', '2024-02-01', '2024-02-28', 'completed', 2, 100.00),
(1, '开发阶段', '核心功能开发', '2024-03-01', '2024-05-31', 'in_progress', 3, 60.00),
(1, '测试阶段', '功能测试和Bug修复', '2024-06-01', '2024-06-30', 'pending', 4, 0.00)
ON CONFLICT DO NOTHING;

-- 插入示例团队成员数据
INSERT INTO team_members (project_id, name, email, role, is_active) VALUES
(1, '张三', 'zhangsan@example.com', 'pm', true),
(1, '李四', 'lisi@example.com', 'po', true),
(1, '王五', 'wangwu@example.com', 'frontend', true),
(1, '赵六', 'zhaoliu@example.com', 'backend', true),
(1, '孙七', 'sunqi@example.com', 'ui', true),
(1, '周八', 'zhouba@example.com', 'tester', true)
ON CONFLICT DO NOTHING;

-- 插入示例任务数据
INSERT INTO tasks (stage_id, name, description, start_date, end_date, status, priority, progress, assigned_to) VALUES
(1, '需求调研', '与客户沟通，了解具体需求', '2024-01-01', '2024-01-15', 'completed', 'high', 100.00, 1),
(1, '需求文档编写', '编写详细的需求规格说明书', '2024-01-16', '2024-01-31', 'completed', 'high', 100.00, 2),
(2, '系统架构设计', '设计系统整体架构', '2024-02-01', '2024-02-15', 'completed', 'high', 100.00, 4),
(2, 'UI设计', '设计用户界面原型', '2024-02-16', '2024-02-28', 'completed', 'medium', 100.00, 5),
(3, '前端开发', '开发前端界面和交互', '2024-03-01', '2024-05-15', 'in_progress', 'high', 80.00, 3),
(3, '后端开发', '开发后端API服务', '2024-03-01', '2024-05-31', 'in_progress', 'high', 60.00, 4),
(4, '功能测试', '测试各项功能是否正常', '2024-06-01', '2024-06-20', 'pending', 'medium', 0.00, 6),
(4, 'Bug修复', '修复测试中发现的问题', '2024-06-21', '2024-06-30', 'pending', 'high', 0.00, 4)
ON CONFLICT DO NOTHING;
