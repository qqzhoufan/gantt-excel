package main

import (
	"time"
)

// 项目表
type Project struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Name        string    `gorm:"not null" json:"name"`
	Description string    `json:"description"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	Status      string    `gorm:"default:active" json:"status"` // active, completed, paused
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 关联关系
	Stages      []Stage      `json:"stages,omitempty"`
	TeamMembers []TeamMember `json:"team_members,omitempty"`
}

// 项目阶段表
type Stage struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	ProjectID   uint      `gorm:"not null" json:"project_id"`
	Name        string    `gorm:"not null" json:"name"`
	Description string    `json:"description"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	Status      string    `gorm:"default:pending" json:"status"` // pending, in_progress, completed
	Order       int       `gorm:"default:0" json:"order"`
	Progress    float64   `gorm:"default:0" json:"progress"` // 0-100
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 外键关系
	Project Project `gorm:"foreignKey:ProjectID" json:"project,omitempty"`

	// 关联关系
	Tasks []Task `json:"tasks,omitempty"`
}

// 任务表
type Task struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	StageID     uint      `gorm:"not null" json:"stage_id"`
	Name        string    `gorm:"not null" json:"name"`
	Description string    `json:"description"`
	StartDate   time.Time `json:"start_date"`
	EndDate     time.Time `json:"end_date"`
	Status      string    `gorm:"default:pending" json:"status"`  // pending, in_progress, completed
	Priority    string    `gorm:"default:medium" json:"priority"` // low, medium, high, urgent
	Progress    float64   `gorm:"default:0" json:"progress"`      // 0-100
	AssignedTo  uint      `json:"assigned_to"`                    // 关联到团队成员
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`

	// 外键关系
	Stage    Stage      `gorm:"foreignKey:StageID" json:"stage,omitempty"`
	Assignee TeamMember `gorm:"foreignKey:AssignedTo" json:"assignee,omitempty"`
}

// 团队成员表
type TeamMember struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	ProjectID uint      `gorm:"not null" json:"project_id"`
	Name      string    `gorm:"not null" json:"name"`
	Email     string    `json:"email"`
	Role      string    `gorm:"not null" json:"role"` // PM, PO, frontend, backend, ui, vfx, audio, tester
	Avatar    string    `json:"avatar"`
	IsActive  bool      `gorm:"default:true" json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// 外键关系
	Project Project `gorm:"foreignKey:ProjectID" json:"project,omitempty"`

	// 关联关系
	Tasks []Task `gorm:"foreignKey:AssignedTo" json:"tasks,omitempty"`
}

// 角色定义
type Role struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	Name        string `gorm:"not null;unique" json:"name"`
	DisplayName string `gorm:"not null" json:"display_name"`
	Color       string `gorm:"default:#3498db" json:"color"`
	Description string `json:"description"`
}

// 预定义角色数据
func GetDefaultRoles() []Role {
	return []Role{
		{Name: "pm", DisplayName: "项目经理(PM)", Color: "#e74c3c", Description: "负责项目整体规划和进度管理"},
		{Name: "po", DisplayName: "产品经理(PO)", Color: "#f39c12", Description: "负责产品需求和功能设计"},
		{Name: "frontend", DisplayName: "客户端程序", Color: "#3498db", Description: "负责前端界面和交互开发"},
		{Name: "backend", DisplayName: "服务器程序", Color: "#2ecc71", Description: "负责后端服务和数据库开发"},
		{Name: "ui", DisplayName: "UI设计师", Color: "#9b59b6", Description: "负责用户界面设计"},
		{Name: "vfx", DisplayName: "特效师", Color: "#1abc9c", Description: "负责视觉特效制作"},
		{Name: "audio", DisplayName: "音频师", Color: "#34495e", Description: "负责音效和音乐制作"},
		{Name: "tester", DisplayName: "测试工程师", Color: "#95a5a6", Description: "负责功能测试和质量保证"},
	}
}
