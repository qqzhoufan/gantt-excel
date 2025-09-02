package main

import (
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// 加载配置
	config := LoadConfig()

	// 初始化数据库
	InitDatabase(config)

	// 创建Gin引擎
	r := gin.Default()

	// 禁用自动重定向
	r.RedirectTrailingSlash = false
	r.RedirectFixedPath = false

	// 配置CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"*"},
		ExposeHeaders:    []string{"*"},
		AllowCredentials: false,
		MaxAge:           86400,
	}))

	// 添加请求日志中间件
	r.Use(func(c *gin.Context) {
		log.Printf("Request: %s %s from %s", c.Request.Method, c.Request.URL.Path, c.ClientIP())
		c.Next()
	})

	// 健康检查 - 放在最前面
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "咸鱼甘特图后端服务运行正常",
		})
	})

	// API路由组
	api := r.Group("/api/v1")
	{
		// 项目路由
		api.GET("/projects", getProjects)
		api.POST("/projects", createProject)
		api.GET("/projects/:id", getProject)
		api.PUT("/projects/:id", updateProject)
		api.DELETE("/projects/:id", deleteProject)
		api.GET("/projects/:id/export", exportProjectToExcel)

		// 项目阶段路由
		api.POST("/stages", createStage)
		api.GET("/stages/project/:projectId", getStages)
		api.PUT("/stages/:id", updateStage)

		// 项目团队成员路由
		api.POST("/members", createTeamMember)
		api.GET("/members/project/:projectId", getTeamMembers)
		api.PUT("/members/:id", updateTeamMember)

		// 任务路由
		api.POST("/tasks", createTask)
		api.PUT("/tasks/:id", updateTask)

		// 角色路由
		api.GET("/roles", getRoles)

		// 甘特图数据路由
		api.GET("/gantt/:projectId", getGanttData)
	}

	log.Printf("Server starting on %s:%s", "0.0.0.0", config.Port)
	log.Fatal(r.Run("0.0.0.0:" + config.Port))
}
