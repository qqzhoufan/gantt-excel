// 测试甘特图对齐的示例数据
export const testGanttData = {
  project: {
    id: 1,
    name: "测试项目 - 甘特图对齐",
    description: "用于测试甘特图时间对齐问题的项目",
    start_date: "2024-09-01",
    end_date: "2024-09-30",
    status: "active"
  },
  timeline: [
    {
      id: 1,
      name: "需求分析阶段",
      start_date: "2024-09-01",
      end_date: "2024-09-07",
      progress: 100,
      status: "completed",
      tasks: [
        {
          id: 1,
          name: "需求调研",
          start_date: "2024-09-01",
          end_date: "2024-09-03",
          progress: 100,
          status: "completed",
          priority: "high",
          assignee: { name: "张三" }
        },
        {
          id: 2,
          name: "需求文档编写",
          start_date: "2024-09-04",
          end_date: "2024-09-07",
          progress: 100,
          status: "completed",
          priority: "medium",
          assignee: { name: "李四" }
        }
      ]
    },
    {
      id: 2,
      name: "设计开发阶段",
      start_date: "2024-09-08",
      end_date: "2024-09-22",
      progress: 60,
      status: "in_progress",
      tasks: [
        {
          id: 3,
          name: "UI设计",
          start_date: "2024-09-08",
          end_date: "2024-09-12",
          progress: 100,
          status: "completed",
          priority: "high",
          assignee: { name: "王五" }
        },
        {
          id: 4,
          name: "前端开发",
          start_date: "2024-09-13",
          end_date: "2024-09-20",
          progress: 70,
          status: "in_progress",
          priority: "high",
          assignee: { name: "赵六" }
        },
        {
          id: 5,
          name: "后端开发",
          start_date: "2024-09-10",
          end_date: "2024-09-22",
          progress: 40,
          status: "in_progress",
          priority: "high",
          assignee: { name: "钱七" }
        }
      ]
    },
    {
      id: 3,
      name: "测试部署阶段",
      start_date: "2024-09-23",
      end_date: "2024-09-30",
      progress: 0,
      status: "pending",
      tasks: [
        {
          id: 6,
          name: "功能测试",
          start_date: "2024-09-23",
          end_date: "2024-09-27",
          progress: 0,
          status: "pending",
          priority: "medium",
          assignee: { name: "孙八" }
        },
        {
          id: 7,
          name: "部署上线",
          start_date: "2024-09-28",
          end_date: "2024-09-30",
          progress: 0,
          status: "pending",
          priority: "urgent",
          assignee: { name: "周九" }
        }
      ]
    },
    {
      id: 4,
      name: "时间边界测试阶段",
      start_date: "2024-09-02",
      end_date: "2024-09-06", // 周一到周五，应该显示5天
      progress: 50,
      status: "in_progress",
      tasks: [
        {
          id: 8,
          name: "周一到周五任务",
          start_date: "2024-09-02", // 周一
          end_date: "2024-09-06",   // 周五
          progress: 50,
          status: "in_progress",
          priority: "medium",
          assignee: { name: "测试员" }
        },
        {
          id: 9,
          name: "单日任务",
          start_date: "2024-09-10",
          end_date: "2024-09-10", // 同一天开始结束
          progress: 100,
          status: "completed",
          priority: "low",
          assignee: { name: "测试员" }
        }
      ]
    }
  ]
}

// 边界测试数据 - 测试超出项目范围的情况
export const boundaryTestData = {
  project: {
    id: 2,
    name: "边界测试项目",
    description: "测试时间边界处理",
    start_date: "2024-09-15",
    end_date: "2024-09-25",
    status: "active"
  },
  timeline: [
    {
      id: 1,
      name: "超前开始的阶段",
      start_date: "2024-09-10", // 早于项目开始时间
      end_date: "2024-09-20",
      progress: 50,
      status: "in_progress",
      tasks: [
        {
          id: 1,
          name: "超前任务",
          start_date: "2024-09-10",
          end_date: "2024-09-18",
          progress: 80,
          status: "in_progress",
          priority: "medium",
          assignee: { name: "测试员A" }
        }
      ]
    },
    {
      id: 2,
      name: "超后结束的阶段",
      start_date: "2024-09-20",
      end_date: "2024-09-30", // 晚于项目结束时间
      progress: 20,
      status: "in_progress",
      tasks: [
        {
          id: 2,
          name: "超后任务",
          start_date: "2024-09-22",
          end_date: "2024-10-02", // 晚于项目结束时间
          progress: 10,
          status: "pending",
          priority: "low",
          assignee: { name: "测试员B" }
        }
      ]
    },
    {
      id: 3,
      name: "正常范围阶段",
      start_date: "2024-09-16",
      end_date: "2024-09-24",
      progress: 75,
      status: "in_progress",
      tasks: [
        {
          id: 3,
          name: "正常任务",
          start_date: "2024-09-17",
          end_date: "2024-09-23",
          progress: 90,
          status: "in_progress",
          priority: "high",
          assignee: { name: "测试员C" }
        }
      ]
    }
  ]
}