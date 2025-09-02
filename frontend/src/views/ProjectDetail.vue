<template>
  <div class="project-detail" v-loading="loading">
    <div class="page-header">
      <el-button @click="$router.back()" type="text">
        <el-icon><ArrowLeft /></el-icon>
        返回项目列表
      </el-button>
      <div class="header-info" v-if="project">
        <h2>{{ project.name }}</h2>
        <el-tag :type="getStatusType(project.status)" size="large">
          {{ getStatusText(project.status) }}
        </el-tag>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="refreshData">
          <el-icon><Refresh /></el-icon>
          刷新数据
        </el-button>
      </div>
    </div>
    
    <div class="project-info" v-if="project">
      <el-row :gutter="20">
        <el-col :span="16">
          <el-card class="info-card">
            <template #header>
              <span>项目信息</span>
            </template>
            <el-descriptions :column="2" border>
              <el-descriptions-item label="项目名称">
                {{ project.name }}
              </el-descriptions-item>
              <el-descriptions-item label="项目状态">
                <el-tag :type="getStatusType(project.status)">
                  {{ getStatusText(project.status) }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="开始日期">
                {{ formatDate(project.start_date) }}
              </el-descriptions-item>
              <el-descriptions-item label="结束日期">
                {{ formatDate(project.end_date) }}
              </el-descriptions-item>
              <el-descriptions-item label="项目描述" :span="2">
                {{ project.description || '暂无描述' }}
              </el-descriptions-item>
            </el-descriptions>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stats-card">
            <template #header>
              <span>项目统计</span>
            </template>
            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-number">{{ project.stages?.length || 0 }}</div>
                <div class="stat-label">项目阶段</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ totalTasks }}</div>
                <div class="stat-label">总任务数</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ project.team_members?.length || 0 }}</div>
                <div class="stat-label">团队成员</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ projectProgress }}%</div>
                <div class="stat-label">完成进度</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 甘特图 -->
    <el-card class="gantt-card" v-if="ganttData">
      <GanttChart :data="ganttData" @refresh="refreshData" />
    </el-card>
    
    <!-- 团队成员 -->
    <el-card class="team-card" v-if="project?.team_members?.length">
      <template #header>
        <div class="card-header">
          <span>团队成员</span>
          <el-button type="primary" size="small" @click="showAddMemberDialog = true">
            <el-icon><Plus /></el-icon>
            添加成员
          </el-button>
        </div>
      </template>
      
      <div class="team-grid">
        <div
          v-for="member in project.team_members"
          :key="member.id"
          class="team-member"
        >
          <el-avatar :size="60" class="member-avatar">
            {{ member.name.charAt(0) }}
          </el-avatar>
          <div class="member-info">
            <h4>{{ member.name }}</h4>
            <p>{{ getRoleDisplayName(member.role) }}</p>
            <div class="member-status">
              <el-tag :type="member.is_active ? 'success' : 'info'" size="small">
                {{ member.is_active ? '激活' : '禁用' }}
              </el-tag>
            </div>
          </div>
        </div>
      </div>
    </el-card>
    
    <!-- 项目阶段 -->
    <el-card class="stages-card" v-if="project?.stages?.length">
      <template #header>
        <div class="card-header">
          <span>项目阶段</span>
          <el-button type="primary" size="small" @click="showAddStageDialog = true">
            <el-icon><Plus /></el-icon>
            添加阶段
          </el-button>
        </div>
      </template>
      
      <el-timeline>
        <el-timeline-item
          v-for="stage in project.stages"
          :key="stage.id"
          :type="getStageTimelineType(stage.status)"
          :icon="getStageIcon(stage.status)"
        >
          <el-card class="stage-card">
            <div class="stage-header">
              <h4>{{ stage.name }}</h4>
              <div class="stage-meta">
                <el-tag :type="getStatusType(stage.status)" size="small">
                  {{ getStatusText(stage.status) }}
                </el-tag>
                <span class="stage-progress">{{ stage.progress }}%</span>
              </div>
            </div>
            <p class="stage-description">{{ stage.description }}</p>
            <div class="stage-dates">
              <span>{{ formatDate(stage.start_date) }} - {{ formatDate(stage.end_date) }}</span>
            </div>
            <div class="stage-progress-bar">
              <el-progress :percentage="stage.progress" :stroke-width="8" />
            </div>
            <div v-if="stage.tasks?.length" class="stage-tasks">
              <h5>任务列表 ({{ stage.tasks.length }})</h5>
              <div class="tasks-list">
                <div
                  v-for="task in stage.tasks"
                  :key="task.id"
                  class="task-item"
                >
                  <span class="task-name">{{ task.name }}</span>
                  <div class="task-meta">
                    <el-tag :type="getPriorityType(task.priority)" size="mini">
                      {{ getPriorityText(task.priority) }}
                    </el-tag>
                    <span class="task-progress">{{ task.progress }}%</span>
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-timeline-item>
      </el-timeline>
    </el-card>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useProjectStore } from '../stores/project'
import GanttChart from '../components/GanttChart.vue'
import { ArrowLeft, Refresh, Plus, User, Document, Clock } from '@element-plus/icons-vue'
import dayjs from 'dayjs'

export default {
  name: 'ProjectDetail',
  components: {
    GanttChart,
    ArrowLeft,
    Refresh,
    Plus,
    User,
    Document,
    Clock
  },
  setup() {
    const route = useRoute()
    const projectStore = useProjectStore()
    const loading = ref(false)
    const ganttData = ref(null)
    const showAddMemberDialog = ref(false)
    const showAddStageDialog = ref(false)
    
    const project = computed(() => projectStore.currentProject)
    
    // 计算总任务数
    const totalTasks = computed(() => {
      if (!project.value?.stages) return 0
      return project.value.stages.reduce((total, stage) => {
        return total + (stage.tasks?.length || 0)
      }, 0)
    })
    
    // 计算项目进度
    const projectProgress = computed(() => {
      if (!project.value?.stages?.length) return 0
      const totalProgress = project.value.stages.reduce((sum, stage) => sum + stage.progress, 0)
      return Math.round(totalProgress / project.value.stages.length)
    })
    
    // 获取项目数据
    const fetchProjectData = async () => {
      loading.value = true
      try {
        await projectStore.fetchProject(route.params.id)
        await fetchGanttData()
      } catch (error) {
        console.error('获取项目数据失败:', error)
      } finally {
        loading.value = false
      }
    }
    
    // 获取甘特图数据
    const fetchGanttData = async () => {
      try {
        const data = await projectStore.fetchGanttData(route.params.id)
        ganttData.value = data
      } catch (error) {
        console.error('获取甘特图数据失败:', error)
      }
    }
    
    // 刷新数据
    const refreshData = () => {
      fetchProjectData()
    }
    
    // 格式化日期
    const formatDate = (date) => {
      return date ? dayjs(date).format('YYYY-MM-DD') : '-'
    }
    
    // 获取状态类型
    const getStatusType = (status) => {
      const statusMap = {
        active: 'success',
        completed: 'info',
        paused: 'warning',
        pending: 'info',
        in_progress: 'warning'
      }
      return statusMap[status] || 'info'
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        active: '进行中',
        completed: '已完成',
        paused: '已暂停',
        pending: '待开始',
        in_progress: '进行中'
      }
      return statusMap[status] || '未知'
    }
    
    // 获取阶段时间轴类型
    const getStageTimelineType = (status) => {
      const typeMap = {
        pending: 'info',
        in_progress: 'warning',
        completed: 'success'
      }
      return typeMap[status] || 'info'
    }
    
    // 获取阶段图标
    const getStageIcon = (status) => {
      const iconMap = {
        pending: Clock,
        in_progress: Document,
        completed: User
      }
      return iconMap[status] || Document
    }
    
    // 获取优先级类型
    const getPriorityType = (priority) => {
      const priorityMap = {
        low: 'info',
        medium: 'warning',
        high: 'danger',
        urgent: 'danger'
      }
      return priorityMap[priority] || 'info'
    }
    
    // 获取优先级文本
    const getPriorityText = (priority) => {
      const priorityMap = {
        low: '低',
        medium: '中',
        high: '高',
        urgent: '紧急'
      }
      return priorityMap[priority] || '中'
    }
    
    // 获取角色显示名称
    const getRoleDisplayName = (role) => {
      const roleMap = {
        pm: '项目经理(PM)',
        po: '产品经理(PO)',
        frontend: '客户端程序',
        backend: '服务器程序',
        ui: 'UI设计师',
        vfx: '特效师',
        audio: '音频师',
        tester: '测试工程师'
      }
      return roleMap[role] || role
    }
    
    onMounted(() => {
      fetchProjectData()
    })
    
    return {
      loading,
      project,
      ganttData,
      totalTasks,
      projectProgress,
      showAddMemberDialog,
      showAddStageDialog,
      refreshData,
      formatDate,
      getStatusType,
      getStatusText,
      getStageTimelineType,
      getStageIcon,
      getPriorityType,
      getPriorityText,
      getRoleDisplayName
    }
  }
}
</script>

<style scoped>
.project-detail {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 20px;
}

.header-info {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
}

.header-info h2 {
  color: #303133;
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}

.project-info {
  margin-bottom: 20px;
}

.info-card,
.stats-card,
.gantt-card,
.team-card,
.stages-card {
  margin-bottom: 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.stat-item {
  text-align: center;
}

.stat-number {
  font-size: 28px;
  font-weight: bold;
  color: #409EFF;
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.team-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
}

.team-member {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  border: 1px solid #EBEEF5;
  border-radius: 8px;
  background: #FAFAFA;
}

.member-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin-bottom: 12px;
}

.member-info {
  text-align: center;
}

.member-info h4 {
  margin: 0 0 4px 0;
  color: #303133;
}

.member-info p {
  margin: 0 0 8px 0;
  color: #606266;
  font-size: 14px;
}

.stage-card {
  margin-bottom: 0;
}

.stage-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.stage-header h4 {
  margin: 0;
  color: #303133;
}

.stage-meta {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stage-progress {
  font-weight: 600;
  color: #409EFF;
}

.stage-description {
  color: #606266;
  margin-bottom: 12px;
}

.stage-dates {
  font-size: 14px;
  color: #909399;
  margin-bottom: 16px;
}

.stage-progress-bar {
  margin-bottom: 20px;
}

.stage-tasks h5 {
  margin: 0 0 12px 0;
  color: #303133;
}

.tasks-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.task-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #F9F9F9;
  border-radius: 4px;
}

.task-name {
  color: #303133;
  font-size: 14px;
}

.task-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.task-progress {
  font-size: 12px;
  color: #409EFF;
}
</style>
