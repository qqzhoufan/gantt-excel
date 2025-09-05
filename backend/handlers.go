package main

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"
	"gorm.io/gorm"
)

// 项目相关接口
func createProject(c *gin.Context) {
	var project Project
	if err := c.ShouldBindJSON(&project); err != nil {
		// 记录详细的绑定错误
		log.Printf("JSON绑定失败: %v", err)
		log.Printf("请求数据: %+v", project)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 验证必填字段
	if project.Name == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "项目名称不能为空"})
		return
	}

	// 验证日期
	if project.StartDate.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{"error": "开始日期不能为空"})
		return
	}

	if project.EndDate.IsZero() {
		c.JSON(http.StatusBadRequest, gin.H{"error": "结束日期不能为空"})
		return
	}

	if project.StartDate.After(project.EndDate) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "开始日期不能晚于结束日期"})
		return
	}

	// 设置默认值
	if project.Status == "" {
		project.Status = "active"
	}

	project.CreatedAt = time.Now()
	project.UpdatedAt = time.Now()

	log.Printf("创建项目: %+v", project)

	if err := DB.Create(&project).Error; err != nil {
		log.Printf("数据库创建失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	log.Printf("项目创建成功，ID: %d", project.ID)
	c.JSON(http.StatusCreated, project)
}

func getProjects(c *gin.Context) {
	var projects []Project
	log.Printf("开始查询项目列表...")

	if err := DB.Preload("Stages").Preload("TeamMembers").Find(&projects).Error; err != nil {
		log.Printf("查询项目列表失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	log.Printf("查询到 %d 个项目", len(projects))
	for i, project := range projects {
		log.Printf("项目 %d: ID=%d, Name=%s, CreatedAt=%s", i+1, project.ID, project.Name, project.CreatedAt.Format("2006-01-02 15:04:05"))
	}

	c.JSON(http.StatusOK, projects)
}

func getProject(c *gin.Context) {
	id := c.Param("id")
	var project Project

	if err := DB.Preload("Stages.Tasks").Preload("TeamMembers").First(&project, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Project not found"})
		return
	}

	c.JSON(http.StatusOK, project)
}

func updateProject(c *gin.Context) {
	id := c.Param("id")
	var project Project

	if err := DB.First(&project, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Project not found"})
		return
	}

	if err := c.ShouldBindJSON(&project); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	project.UpdatedAt = time.Now()

	if err := DB.Save(&project).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, project)
}

func deleteProject(c *gin.Context) {
	id := c.Param("id")

	// 开始事务
	tx := DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// 先删除相关的任务
	if err := tx.Where("stage_id IN (SELECT id FROM stages WHERE project_id = ?)", id).Delete(&Task{}).Error; err != nil {
		tx.Rollback()
		log.Printf("删除任务失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除相关任务失败"})
		return
	}

	// 删除相关的阶段
	if err := tx.Where("project_id = ?", id).Delete(&Stage{}).Error; err != nil {
		tx.Rollback()
		log.Printf("删除阶段失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除相关阶段失败"})
		return
	}

	// 删除相关的团队成员
	if err := tx.Where("project_id = ?", id).Delete(&TeamMember{}).Error; err != nil {
		tx.Rollback()
		log.Printf("删除团队成员失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除相关团队成员失败"})
		return
	}

	// 最后删除项目
	if err := tx.Delete(&Project{}, id).Error; err != nil {
		tx.Rollback()
		log.Printf("删除项目失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除项目失败"})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.Printf("提交事务失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除操作失败"})
		return
	}

	log.Printf("项目 %s 及其相关数据删除成功", id)
	c.JSON(http.StatusOK, gin.H{"message": "Project deleted successfully"})
}

// 阶段相关接口
func createStage(c *gin.Context) {
	var stage Stage
	if err := c.ShouldBindJSON(&stage); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	stage.CreatedAt = time.Now()
	stage.UpdatedAt = time.Now()

	if err := DB.Create(&stage).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, stage)
}

func getStages(c *gin.Context) {
	projectID := c.Param("projectId")
	var stages []Stage

	if err := DB.Where("project_id = ?", projectID).Preload("Tasks").Find(&stages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, stages)
}

func updateStage(c *gin.Context) {
	id := c.Param("id")
	var stage Stage

	if err := DB.First(&stage, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stage not found"})
		return
	}

	var updateData map[string]interface{}
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 只更新允许的字段
	allowedFields := []string{"name", "description", "start_date", "end_date", "status", "progress"}
	for _, field := range allowedFields {
		if value, exists := updateData[field]; exists {
			switch field {
			case "name":
				stage.Name = value.(string)
			case "description":
				stage.Description = value.(string)
			case "start_date":
				if dateStr, ok := value.(string); ok {
					if date, err := time.Parse("2006-01-02", dateStr); err == nil {
						stage.StartDate = date
					}
				}
			case "end_date":
				if dateStr, ok := value.(string); ok {
					if date, err := time.Parse("2006-01-02", dateStr); err == nil {
						stage.EndDate = date
					}
				}
			case "status":
				stage.Status = value.(string)
			case "progress":
				if progress, ok := value.(float64); ok {
					stage.Progress = progress
				}
			}
		}
	}

	stage.UpdatedAt = time.Now()

	if err := DB.Save(&stage).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, stage)
}

// 团队成员相关接口
func createTeamMember(c *gin.Context) {
	var member TeamMember
	if err := c.ShouldBindJSON(&member); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	member.CreatedAt = time.Now()
	member.UpdatedAt = time.Now()

	if err := DB.Create(&member).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, member)
}

func getTeamMembers(c *gin.Context) {
	projectID := c.Param("projectId")
	var members []TeamMember

	if err := DB.Where("project_id = ?", projectID).Find(&members).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, members)
}

func updateTeamMember(c *gin.Context) {
	id := c.Param("id")
	var member TeamMember

	if err := DB.First(&member, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Team member not found"})
		return
	}

	if err := c.ShouldBindJSON(&member); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	member.UpdatedAt = time.Now()

	if err := DB.Save(&member).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, member)
}

// 角色相关接口
func getRoles(c *gin.Context) {
	var roles []Role
	if err := DB.Find(&roles).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, roles)
}

// 甘特图数据接口
func getGanttData(c *gin.Context) {
	projectID := c.Param("projectId")

	var project Project
	if err := DB.Preload("Stages.Tasks.Assignee").First(&project, projectID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Project not found"})
		return
	}

	// 构建甘特图数据结构
	ganttData := map[string]interface{}{
		"project":  project,
		"timeline": generateTimeline(project),
	}

	c.JSON(http.StatusOK, ganttData)
}

// 生成时间线数据
func generateTimeline(project Project) []map[string]interface{} {
	var timeline []map[string]interface{}

	for _, stage := range project.Stages {
		stageData := map[string]interface{}{
			"id":         stage.ID,
			"name":       stage.Name,
			"start_date": stage.StartDate.Format("2006-01-02"),
			"end_date":   stage.EndDate.Format("2006-01-02"),
			"progress":   stage.Progress,
			"status":     stage.Status,
			"tasks":      []map[string]interface{}{},
		}

		for _, task := range stage.Tasks {
			taskData := map[string]interface{}{
				"id":         task.ID,
				"name":       task.Name,
				"start_date": task.StartDate.Format("2006-01-02"),
				"end_date":   task.EndDate.Format("2006-01-02"),
				"progress":   task.Progress,
				"status":     task.Status,
				"priority":   task.Priority,
				"assignee":   task.Assignee,
			}
			stageData["tasks"] = append(stageData["tasks"].([]map[string]interface{}), taskData)
		}

		timeline = append(timeline, stageData)
	}

	return timeline
}

// 任务相关接口
func createTask(c *gin.Context) {
	var task Task
	if err := c.ShouldBindJSON(&task); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	task.CreatedAt = time.Now()
	task.UpdatedAt = time.Now()

	if err := DB.Create(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, task)
}

func updateTask(c *gin.Context) {
	id := c.Param("id")
	var task Task

	if err := DB.First(&task, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
		return
	}

	var updateData map[string]interface{}
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 只更新允许的字段
	allowedFields := []string{"name", "description", "start_date", "end_date", "status", "priority", "progress"}
	for _, field := range allowedFields {
		if value, exists := updateData[field]; exists {
			switch field {
			case "name":
				task.Name = value.(string)
			case "description":
				task.Description = value.(string)
			case "start_date":
				if dateStr, ok := value.(string); ok {
					if date, err := time.Parse("2006-01-02", dateStr); err == nil {
						task.StartDate = date
					}
				}
			case "end_date":
				if dateStr, ok := value.(string); ok {
					if date, err := time.Parse("2006-01-02", dateStr); err == nil {
						task.EndDate = date
					}
				}
			case "status":
				task.Status = value.(string)
			case "priority":
				task.Priority = value.(string)
			case "progress":
				if progress, ok := value.(float64); ok {
					task.Progress = progress
				}
			}
		}
	}

	task.UpdatedAt = time.Now()

	if err := DB.Save(&task).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, task)
}

// 导出项目甘特图到Excel
func exportProjectToExcel(c *gin.Context) {
	projectID := c.Param("id")
	if projectID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "项目ID不能为空"})
		return
	}

	id, err := strconv.ParseUint(projectID, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的项目ID"})
		return
	}

	// 获取项目信息
	var project Project
	if err := DB.Preload("Stages.Tasks.Assignee").Preload("TeamMembers").First(&project, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "项目不存在"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取项目信息失败"})
		return
	}

	// 创建Excel文件
	f := excelize.NewFile()
	defer func() {
		if err := f.Close(); err != nil {
			log.Printf("关闭Excel文件失败: %v", err)
		}
	}()

	// 设置工作表名称
	sheetName := "甘特图"
	f.SetSheetName("Sheet1", sheetName)

	// 设置标题行
	f.SetCellValue(sheetName, "A1", "项目甘特图")
	f.SetCellValue(sheetName, "A2", "项目名称")
	f.SetCellValue(sheetName, "B2", project.Name)
	f.SetCellValue(sheetName, "A3", "项目描述")
	f.SetCellValue(sheetName, "B3", project.Description)
	f.SetCellValue(sheetName, "A4", "开始日期")
	f.SetCellValue(sheetName, "B4", project.StartDate.Format("2006-01-02"))
	f.SetCellValue(sheetName, "A5", "结束日期")
	f.SetCellValue(sheetName, "B5", project.EndDate.Format("2006-01-02"))
	f.SetCellValue(sheetName, "A6", "状态")
	f.SetCellValue(sheetName, "B6", getStatusText(project.Status))

	// 设置表头
	headers := []string{"阶段/任务", "开始日期", "结束日期", "工期(工作日)", "状态", "进度", "负责人", "优先级"}
	for i, header := range headers {
		col := string(rune('A' + i + 2)) // 从C列开始
		f.SetCellValue(sheetName, col+"8", header)
	}

	// 填充阶段和任务数据
	row := 9
	for _, stage := range project.Stages {
		// 阶段行
		f.SetCellValue(sheetName, "C"+strconv.Itoa(row), stage.Name)
		f.SetCellValue(sheetName, "D"+strconv.Itoa(row), stage.StartDate.Format("2006-01-02"))
		f.SetCellValue(sheetName, "E"+strconv.Itoa(row), stage.EndDate.Format("2006-01-02"))
		f.SetCellValue(sheetName, "F"+strconv.Itoa(row), calculateWorkDays(stage.StartDate, stage.EndDate))
		f.SetCellValue(sheetName, "G"+strconv.Itoa(row), getStatusText(stage.Status))
		f.SetCellValue(sheetName, "H"+strconv.Itoa(row), strconv.FormatFloat(stage.Progress, 'f', 1, 64)+"%")
		f.SetCellValue(sheetName, "I"+strconv.Itoa(row), "")
		f.SetCellValue(sheetName, "J"+strconv.Itoa(row), "")
		row++

		// 任务行
		for _, task := range stage.Tasks {
			f.SetCellValue(sheetName, "C"+strconv.Itoa(row), "  "+task.Name) // 缩进表示任务
			f.SetCellValue(sheetName, "D"+strconv.Itoa(row), task.StartDate.Format("2006-01-02"))
			f.SetCellValue(sheetName, "E"+strconv.Itoa(row), task.EndDate.Format("2006-01-02"))
			f.SetCellValue(sheetName, "F"+strconv.Itoa(row), calculateWorkDays(task.StartDate, task.EndDate))
			f.SetCellValue(sheetName, "G"+strconv.Itoa(row), getStatusText(task.Status))
			f.SetCellValue(sheetName, "H"+strconv.Itoa(row), strconv.FormatFloat(task.Progress, 'f', 1, 64)+"%")
			if task.Assignee.ID > 0 {
				f.SetCellValue(sheetName, "I"+strconv.Itoa(row), task.Assignee.Name)
			}
			f.SetCellValue(sheetName, "J"+strconv.Itoa(row), getPriorityText(task.Priority))
			row++
		}
	}

	// 添加甘特图数据表
	sheetName2 := "甘特图数据"
	f.NewSheet(sheetName2)

	// 甘特图表头
	ganntHeaders := []string{"项目", "阶段", "任务", "开始日期", "结束日期", "工期(工作日)", "状态", "进度", "负责人", "优先级"}
	for i, header := range ganntHeaders {
		col := string(rune('A' + i))
		f.SetCellValue(sheetName2, col+"1", header)
	}

	// 填充甘特图数据
	row2 := 2
	for _, stage := range project.Stages {
		// 阶段行
		f.SetCellValue(sheetName2, "A"+strconv.Itoa(row2), project.Name)
		f.SetCellValue(sheetName2, "B"+strconv.Itoa(row2), stage.Name)
		f.SetCellValue(sheetName2, "C"+strconv.Itoa(row2), "")
		f.SetCellValue(sheetName2, "D"+strconv.Itoa(row2), stage.StartDate.Format("2006-01-02"))
		f.SetCellValue(sheetName2, "E"+strconv.Itoa(row2), stage.EndDate.Format("2006-01-02"))
		f.SetCellValue(sheetName2, "F"+strconv.Itoa(row2), calculateWorkDays(stage.StartDate, stage.EndDate))
		f.SetCellValue(sheetName2, "G"+strconv.Itoa(row2), getStatusText(stage.Status))
		f.SetCellValue(sheetName2, "H"+strconv.Itoa(row2), strconv.FormatFloat(stage.Progress, 'f', 1, 64)+"%")
		f.SetCellValue(sheetName2, "I"+strconv.Itoa(row2), "")
		f.SetCellValue(sheetName2, "J"+strconv.Itoa(row2), "")
		row2++

		// 任务行
		for _, task := range stage.Tasks {
			f.SetCellValue(sheetName2, "A"+strconv.Itoa(row2), project.Name)
			f.SetCellValue(sheetName2, "B"+strconv.Itoa(row2), stage.Name)
			f.SetCellValue(sheetName2, "C"+strconv.Itoa(row2), task.Name)
			f.SetCellValue(sheetName2, "D"+strconv.Itoa(row2), task.StartDate.Format("2006-01-02"))
			f.SetCellValue(sheetName2, "E"+strconv.Itoa(row2), task.EndDate.Format("2006-01-02"))
			f.SetCellValue(sheetName2, "F"+strconv.Itoa(row2), calculateWorkDays(task.StartDate, task.EndDate))
			f.SetCellValue(sheetName2, "G"+strconv.Itoa(row2), getStatusText(task.Status))
			f.SetCellValue(sheetName2, "H"+strconv.Itoa(row2), strconv.FormatFloat(task.Progress, 'f', 1, 64)+"%")
			if task.Assignee.ID > 0 {
				f.SetCellValue(sheetName2, "I"+strconv.Itoa(row2), task.Assignee.Name)
			}
			f.SetCellValue(sheetName2, "J"+strconv.Itoa(row2), getPriorityText(task.Priority))
			row2++
		}
	}

	// 设置甘特图数据表的列宽
	f.SetColWidth(sheetName2, "A", "A", 20)
	f.SetColWidth(sheetName2, "B", "B", 25)
	f.SetColWidth(sheetName2, "C", "C", 25)
	f.SetColWidth(sheetName2, "D", "E", 12)
	f.SetColWidth(sheetName2, "F", "F", 15)
	f.SetColWidth(sheetName2, "G", "G", 12)
	f.SetColWidth(sheetName2, "H", "H", 12)
	f.SetColWidth(sheetName2, "I", "I", 15)
	f.SetColWidth(sheetName2, "J", "J", 12)

	// 创建甘特图时间线表
	sheetName3 := "甘特图时间线"
	f.NewSheet(sheetName3)

	// 生成时间线
	startDate := project.StartDate
	endDate := project.EndDate
	current := startDate
	col := 1 // 从B列开始

	// 设置任务列
	f.SetCellValue(sheetName3, "A1", "任务/阶段")
	f.SetCellValue(sheetName3, "A2", "开始日期")
	f.SetCellValue(sheetName3, "A3", "结束日期")
	f.SetCellValue(sheetName3, "A4", "工期(工作日)")

	// 生成日期标题行
	for current.Before(endDate) || current.Equal(endDate) {
		colLetter := getColumnLetter(col)
		dateStr := current.Format("01/02")
		f.SetCellValue(sheetName3, colLetter+"1", dateStr)

		// 标记周末
		if current.Weekday() == time.Sunday || current.Weekday() == time.Saturday {
			weekendStyle, _ := f.NewStyle(&excelize.Style{
				Fill: excelize.Fill{
					Type:    "pattern",
					Color:   []string{"FFE6E6"},
					Pattern: 1,
				},
			})
			f.SetCellStyle(sheetName3, colLetter+"1", colLetter+"1", weekendStyle)
		}

		current = current.AddDate(0, 0, 1)
		col++
	}

	// 填充甘特图数据
	row = 5
	for _, stage := range project.Stages {
		// 阶段行
		f.SetCellValue(sheetName3, "A"+strconv.Itoa(row), "📁 "+stage.Name)

		// 绘制甘特图条
		drawGanttBar(f, sheetName3, stage.StartDate, stage.EndDate, startDate, row, getStatusColor(stage.Status))
		row++

		// 任务行
		for _, task := range stage.Tasks {
			f.SetCellValue(sheetName3, "A"+strconv.Itoa(row), "  📄 "+task.Name)
			drawGanttBar(f, sheetName3, task.StartDate, task.EndDate, startDate, row, getStatusColor(task.Status))
			row++
		}
	}

	// 设置甘特图时间线表的列宽
	f.SetColWidth(sheetName3, "A", "A", 30)
	for i := 1; i < col; i++ {
		colLetter := getColumnLetter(i)
		f.SetColWidth(sheetName3, colLetter, colLetter, 3)
	}

	// 创建团队成员信息表
	sheetName4 := "团队成员信息"
	f.NewSheet(sheetName4)

	// 团队成员表头
	memberHeaders := []string{"姓名", "角色", "邮箱", "头像", "加入时间", "状态"}
	for i, header := range memberHeaders {
		col := string(rune('A' + i))
		f.SetCellValue(sheetName4, col+"1", header)
	}

	// 填充团队成员数据
	row4 := 2
	for _, member := range project.TeamMembers {
		f.SetCellValue(sheetName4, "A"+strconv.Itoa(row4), member.Name)
		f.SetCellValue(sheetName4, "B"+strconv.Itoa(row4), member.Role)
		f.SetCellValue(sheetName4, "C"+strconv.Itoa(row4), member.Email)
		f.SetCellValue(sheetName4, "D"+strconv.Itoa(row4), member.Avatar)
		f.SetCellValue(sheetName4, "E"+strconv.Itoa(row4), member.CreatedAt.Format("2006-01-02"))
		if member.IsActive {
			f.SetCellValue(sheetName4, "F"+strconv.Itoa(row4), "活跃")
		} else {
			f.SetCellValue(sheetName4, "F"+strconv.Itoa(row4), "非活跃")
		}
		row4++
	}

	// 设置团队成员表的列宽
	f.SetColWidth(sheetName4, "A", "A", 15)
	f.SetColWidth(sheetName4, "B", "B", 15)
	f.SetColWidth(sheetName4, "C", "C", 25)
	f.SetColWidth(sheetName4, "D", "D", 20)
	f.SetColWidth(sheetName4, "E", "E", 12)
	f.SetColWidth(sheetName4, "F", "F", 10)

	// 设置列宽
	f.SetColWidth(sheetName, "A", "A", 15)
	f.SetColWidth(sheetName, "B", "B", 20)
	f.SetColWidth(sheetName, "C", "C", 25)
	f.SetColWidth(sheetName, "D", "E", 12)
	f.SetColWidth(sheetName, "F", "F", 15)
	f.SetColWidth(sheetName, "G", "G", 12)
	f.SetColWidth(sheetName, "H", "H", 12)
	f.SetColWidth(sheetName, "I", "I", 15)
	f.SetColWidth(sheetName, "J", "J", 12)

	// 设置标题样式
	titleStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{
			Bold:  true,
			Size:  16,
			Color: "000000",
		},
		Alignment: &excelize.Alignment{
			Horizontal: "center",
			Vertical:   "center",
		},
	})
	f.SetCellStyle(sheetName, "A1", "A1", titleStyle)
	f.MergeCell(sheetName, "A1", "J1")

	// 设置表头样式
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{
			Bold:  true,
			Color: "FFFFFF",
		},
		Fill: excelize.Fill{
			Type:    "pattern",
			Color:   []string{"366092"},
			Pattern: 1,
		},
		Alignment: &excelize.Alignment{
			Horizontal: "center",
			Vertical:   "center",
		},
	})
	f.SetCellStyle(sheetName, "C8", "J8", headerStyle)

	// 设置团队成员表头样式
	f.SetCellStyle(sheetName4, "A1", "F1", headerStyle)

	// 设置文件名
	fileName := project.Name + "_甘特图.xlsx"
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", "attachment; filename="+fileName)

	// 写入响应
	if err := f.Write(c.Writer); err != nil {
		log.Printf("写入Excel文件失败: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成Excel文件失败"})
		return
	}
}

// 计算工作日（排除周六周日）
func calculateWorkDays(startDate, endDate time.Time) int {
	if startDate.IsZero() || endDate.IsZero() {
		return 0
	}

	workDays := 0
	current := startDate
	for current.Before(endDate) || current.Equal(endDate) {
		weekday := current.Weekday()
		if weekday != time.Sunday && weekday != time.Saturday {
			workDays++
		}
		current = current.AddDate(0, 0, 1)
	}
	return workDays
}

// 获取状态文本
func getStatusText(status string) string {
	statusMap := map[string]string{
		"pending":     "待开始",
		"in_progress": "进行中",
		"completed":   "已完成",
		"active":      "活跃",
		"paused":      "暂停",
	}
	if text, exists := statusMap[status]; exists {
		return text
	}
	return status
}

// 获取优先级文本
func getPriorityText(priority string) string {
	priorityMap := map[string]string{
		"low":    "低",
		"medium": "中",
		"high":   "高",
		"urgent": "紧急",
	}
	if text, exists := priorityMap[priority]; exists {
		return text
	}
	return "中"
}

// 获取列字母 (1=A, 2=B, 27=AA, etc.)
func getColumnLetter(col int) string {
	result := ""
	for col > 0 {
		col--
		result = string(rune('A'+col%26)) + result
		col /= 26
	}
	return result
}

// 获取状态颜色
func getStatusColor(status string) string {
	statusColorMap := map[string]string{
		"pending":     "FFE6B3", // 橙色
		"in_progress": "FFB366", // 深橙色
		"completed":   "90EE90", // 浅绿色
		"active":      "87CEEB", // 天蓝色
		"paused":      "DDA0DD", // 紫色
	}
	if color, exists := statusColorMap[status]; exists {
		return color
	}
	return "E0E0E0" // 默认灰色
}

// 绘制甘特图条
func drawGanttBar(f *excelize.File, sheetName string, startDate, endDate, projectStart time.Time, row int, color string) {
	if startDate.IsZero() || endDate.IsZero() {
		return
	}

	// 修复：正确计算开始和结束列
	// 日期列从第2列开始（B列），A列是任务名称
	dayOffset := int(startDate.Sub(projectStart).Hours() / 24)
	startCol := dayOffset + 2 // +2是因为A列是任务名，从B列开始是日期
	
	// 计算结束列，确保包含结束日期
	endDayOffset := int(endDate.Sub(projectStart).Hours() / 24)
	endCol := endDayOffset + 2 // 结束日期对应的列
	
	// 确保列号有效
	if startCol < 2 {
		startCol = 2
	}
	if endCol < startCol {
		endCol = startCol
	}

	// 创建样式
	barStyle, _ := f.NewStyle(&excelize.Style{
		Fill: excelize.Fill{
			Type:    "pattern",
			Color:   []string{color},
			Pattern: 1,
		},
		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
		},
	})

	// 绘制甘特图条
	startColLetter := getColumnLetter(startCol)
	endColLetter := getColumnLetter(endCol)

	f.SetCellStyle(sheetName, startColLetter+strconv.Itoa(row), endColLetter+strconv.Itoa(row), barStyle)
}
