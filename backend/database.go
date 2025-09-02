package main

import (
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDatabase(config *Config) {
	var err error

	// 连接数据库
	DB, err = gorm.Open(postgres.Open(config.GetDBConnectionString()), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	log.Println("Database connected successfully")

	// 自动迁移数据库表
	err = DB.AutoMigrate(
		&Project{},
		&Stage{},
		&Task{},
		&TeamMember{},
		&Role{},
	)
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	log.Println("Database migration completed")

	// 初始化默认角色
	initDefaultRoles()
}

func initDefaultRoles() {
	var count int64
	DB.Model(&Role{}).Count(&count)

	if count == 0 {
		roles := GetDefaultRoles()
		for _, role := range roles {
			DB.Create(&role)
		}
		log.Println("Default roles initialized")
	}
}
