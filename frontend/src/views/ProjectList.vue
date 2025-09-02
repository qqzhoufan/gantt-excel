<template>
  <div class="project-list">
    <div class="page-header">
      <h2>项目列表</h2>
      <div class="header-actions">
        <el-button 
          type="info" 
          @click="refreshProjects"
          :loading="loading"
        >
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
        <el-button 
          type="success" 
          :disabled="selectedCount === 0"
          @click="exportSelectedProjects"
          :loading="exporting"
        >
          <el-icon><Download /></el-icon>
          导出选中项目 ({{ selectedCount }}) - 调试: {{ selectedProjects.length }}
        </el-button>
        <el-button type="primary" @click="$router.push('/project/new')">
          <el-icon><Plus /></el-icon>
          新建项目
        </el-button>
        <el-button type="warning" @click="testSelection">
          测试选择功能
        </el-button>
      </div>
    </div>
    
    <div class="project-stats">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-number">{{ projects.length }}</div>
              <div class="stat-label">总项目数</div>
            </div>
            <el-icon class="stat-icon"><FolderOpened /></el-icon>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card active">
            <div class="stat-content">
              <div class="stat-number">{{ activeProjects.length }}</div>
              <div class="stat-label">进行中</div>
            </div>
            <el-icon class="stat-icon"><Timer /></el-icon>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card completed">
            <div class="stat-content">
              <div class="stat-number">{{ completedProjects.length }}</div>
              <div class="stat-label">已完成</div>
            </div>
            <el-icon class="stat-icon"><CircleCheck /></el-icon>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <el-card class="project-table-card">
      <template #header>
        <div class="card-header">
          <span>项目管理</span>
          <el-input
            v-model="searchText"
            placeholder="搜索项目..."
            style="width: 200px"
            clearable
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
      </template>
      
      <el-table
        v-loading="loading"
        :data="filteredProjects"
        style="width: 100%"
        @row-click="handleRowClick"
        class="project-table"
        ref="tableRef"
        row-key="id"
      >
        <!-- 多选列 -->
        <el-table-column type="selection" width="55">
          <template #header>
            <el-checkbox 
              :model-value="selectAll" 
              @update:model-value="handleSelectAllChange"
              :indeterminate="isIndeterminate"
            />
          </template>
          <template #default="{ row }">
            <el-checkbox 
              :model-value="row.selected" 
              @update:model-value="(value) => handleRowSelectChange(row, value)"
              @click.stop
            />
          </template>
        </el-table-column>
        
        <el-table-column prop="name" label="项目名称" min-width="200">
          <template #default="{ row }">
            <div class="project-name">
              <strong>{{ row.name }}</strong>
              <div class="project-desc">{{ row.description || '暂无描述' }}</div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }">
            <el-tag 
              :type="getStatusType(row.status)"
              effect="light"
            >
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        
        <el-table-column prop="start_date" label="开始日期" width="120">
          <template #default="{ row }">
            {{ formatDate(row.start_date) }}
          </template>
        </el-table-column>
        
        <el-table-column prop="end_date" label="结束日期" width="120">
          <template #default="{ row }">
            {{ formatDate(row.end_date) }}
          </template>
        </el-table-column>
        
        <el-table-column label="团队成员" width="150">
          <template #default="{ row }">
            <div class="team-avatars">
              <el-avatar
                v-for="member in row.team_members?.slice(0, 3)"
                :key="member.id"
                :size="30"
                class="team-avatar"
              >
                {{ member.name.charAt(0) }}
              </el-avatar>
              <span v-if="row.team_members?.length > 3" class="more-count">
                +{{ row.team_members.length - 3 }}
              </span>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click.stop="viewProject(row.id)"
            >
              查看详情
            </el-button>
            <el-button
              type="danger"
              size="small"
              @click.stop="confirmDelete(row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useProjectStore } from '../stores/project'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Plus, FolderOpened, Timer, CircleCheck, Search, Download, Refresh } from '@element-plus/icons-vue'
import dayjs from 'dayjs'

export default {
  name: 'ProjectList',
  components: {
    Plus,
    FolderOpened,
    Timer,
    CircleCheck,
    Search,
    Download,
    Refresh
  },
  setup() {
    const router = useRouter()
    const projectStore = useProjectStore()
    const searchText = ref('')
    
    // 不要解构，直接使用store来保持响应性
    // const { 
    //   projects, 
    //   loading, 
    //   activeProjects, 
    //   completedProjects,
    //   fetchProjects,
    //   deleteProject,
    //   exportProjects
    // } = projectStore
    
    const selectedProjects = ref([])
    const exporting = ref(false)
    const tableRef = ref(null)
    const selectAll = ref(false)
    const isIndeterminate = ref(false)
    

    
    // 处理全选变化
    const handleSelectAllChange = (checked) => {
      console.log('全选变化:', checked)
      console.log('当前项目数量:', filteredProjects.value.length)
      filteredProjects.value.forEach((row, index) => {
        console.log(`设置第${index}行选中状态为:`, checked)
        row.selected = checked
      })
      updateSelectedProjects()
    }
    
    // 处理单行选择变化
    const handleRowSelectChange = (row, value) => {
      console.log('单行选择变化:', row, '新值:', value)
      row.selected = value
      updateSelectedProjects()
    }
    
    // 更新选中的项目列表
    const updateSelectedProjects = () => {
      console.log('开始更新选中项目')
      console.log('所有项目:', filteredProjects.value)
      console.log('每行的选中状态:', filteredProjects.value.map(row => ({ id: row.id, name: row.name, selected: row.selected })))
      
      const selected = filteredProjects.value.filter(row => row.selected)
      console.log('筛选出的选中项目:', selected)
      selectedProjects.value = selected
      
      // 使用nextTick确保状态更新在DOM更新之后
      nextTick(() => {
        // 更新全选状态
        const total = filteredProjects.value.length
        const selectedCount = selected.length
        selectAll.value = selectedCount === total && total > 0
        isIndeterminate.value = selectedCount > 0 && selectedCount < total
        
        console.log('全选状态:', selectAll.value)
        console.log('半选状态:', isIndeterminate.value)
      })
    }
    
    // 计算选中的项目数量
    const selectedCount = computed(() => {
      const count = selectedProjects.value.length
      console.log('selectedCount计算:', count, 'selectedProjects.value:', selectedProjects.value)
      return count
    })
    
    // 监听选择变化
    watch(selectedProjects, (newVal) => {
      console.log('watch selectedProjects变化:', newVal, '长度:', newVal.length)
    }, { deep: true })
    
        // 过滤项目
    const filteredProjects = computed(() => {
      console.log('filteredProjects计算属性被调用')
      console.log('projectStore.projects:', projectStore.projects)
      console.log('projectStore.projects长度:', projectStore.projects?.length)
      console.log('searchText.value:', searchText.value)

      if (!projectStore.projects || projectStore.projects.length === 0) {
        console.log('项目列表为空，返回空数组')
        return []
      }

      let projects = []
      if (!searchText.value) {
        console.log('没有搜索文本，返回所有项目:', projectStore.projects)
        projects = projectStore.projects
      } else {
        projects = projectStore.projects.filter(project =>
          project.name.toLowerCase().includes(searchText.value.toLowerCase()) ||
          project.description?.toLowerCase().includes(searchText.value.toLowerCase())
        )
        console.log('过滤后的项目:', projects)
      }
      
      // 确保每个项目都有selected属性
      return projects.map(project => ({
        ...project,
        selected: project.selected || false
      }))
    })
    
    // 格式化日期
    const formatDate = (date) => {
      return date ? dayjs(date).format('YYYY-MM-DD') : '-'
    }
    
    // 获取状态类型
    const getStatusType = (status) => {
      const statusMap = {
        active: 'success',
        completed: 'info',
        paused: 'warning'
      }
      return statusMap[status] || 'info'
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        active: '进行中',
        completed: '已完成',
        paused: '已暂停'
      }
      return statusMap[status] || '未知'
    }
    
    // 查看项目详情
    const viewProject = (id) => {
      router.push(`/project/${id}`)
    }
    
    // 行点击事件
    const handleRowClick = (row) => {
      viewProject(row.id)
    }
    
    // 确认删除
    const confirmDelete = async (project) => {
      try {
        await ElMessageBox.confirm(
          `确定要删除项目"${project.name}"吗？此操作不可恢复。`,
          '确认删除',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
            showClose: true,
            closeOnClickModal: false,
            closeOnPressEscape: true,
            distinguishCancelAndClose: true,
            buttonSize: 'default'
          }
        )
        
        console.log('开始删除项目:', project.id)
        await projectStore.deleteProject(project.id)
        console.log('项目删除成功')
        // 重新获取项目列表
        await projectStore.fetchProjects()
        ElMessage.success('项目删除成功')
      } catch (error) {
        console.log('删除操作结果:', error)
        if (error !== 'cancel') {
          console.error('删除项目失败:', error)
          ElMessage.error('删除项目失败: ' + (error.message || error))
        }
      }
    }

    // 批量导出项目
    const exportSelectedProjects = async () => {
      try {
        await ElMessageBox.confirm(
          `确定要导出选中的 ${selectedProjects.length} 个项目吗？`,
          '确认导出',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'info',
          }
        )
        const projectIds = selectedProjects.value.map(p => p.id)
        await projectStore.exportProjects(projectIds)
        ElMessage.success('项目导出成功')
      } catch (error) {
        if (error !== 'cancel') {
          console.error('导出项目失败:', error)
        }
      }
    }

    // 手动刷新项目列表
    const refreshProjects = () => {
      projectStore.fetchProjects()
      ElMessage.success('项目列表已刷新')
    }
    
    // 测试选择功能
    const testSelection = () => {
      console.log('测试选择功能')
      console.log('当前selectedProjects:', selectedProjects.value)
      console.log('当前selectedCount:', selectedCount.value)
      console.log('表格引用:', tableRef.value)
      console.log('表格数据:', filteredProjects.value)
      
      // 检查表格数据的第一项
      if (filteredProjects.value.length > 0) {
        console.log('第一项数据:', filteredProjects.value[0])
        console.log('第一项ID:', filteredProjects.value[0].id)
        console.log('第一项类型:', typeof filteredProjects.value[0])
      }
      
      // 手动触发选择变化
      if (filteredProjects.value.length > 0) {
        const testRow = filteredProjects.value[0]
        console.log('手动触发选择变化:', testRow)
        handleRowSelectChange(testRow, true)
      }
    }
    

    
    // 初始化
    onMounted(() => {
      console.log('组件挂载，开始获取项目列表')
      projectStore.fetchProjects().then(() => {
        console.log('项目列表获取完成，当前项目数量:', projectStore.projects?.length)
        // 使用nextTick等待DOM更新
        nextTick(() => {
          console.log('DOM更新后表格引用:', tableRef.value)
          console.log('表格数据:', filteredProjects.value)
        })
      })
    })
    
    return {
      // 使用store直接访问，保持响应性
      projects: computed(() => projectStore.projects),
      loading: computed(() => projectStore.loading),
      activeProjects: computed(() => projectStore.activeProjects),
      completedProjects: computed(() => projectStore.completedProjects),
      searchText,
      filteredProjects,
      formatDate,
      getStatusType,
      getStatusText,
      viewProject,
      handleRowClick,
      confirmDelete,
      selectedProjects,
      selectedCount,
      exporting,
      selectAll,
      isIndeterminate,
      handleSelectAllChange,
      handleRowSelectChange,
      exportSelectedProjects,
      refreshProjects,
      testSelection
    }
  }
}
</script>

<style scoped>
.project-list {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  color: #303133;
  font-size: 24px;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.project-stats {
  margin-bottom: 20px;
}

.stat-card {
  position: relative;
  overflow: hidden;
}

.stat-card.active {
  border-color: #67C23A;
}

.stat-card.completed {
  border-color: #909399;
}

.stat-content {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 8px;
}

.stat-icon {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 40px;
  color: #E4E7ED;
}

.project-table-card {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.project-table {
  cursor: pointer;
}

.project-name strong {
  font-size: 16px;
  color: #303133;
}

.project-desc {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.team-avatars {
  display: flex;
  align-items: center;
  gap: -8px;
}

.team-avatar {
  margin-right: -8px;
  border: 2px solid #fff;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 12px;
}

.more-count {
  font-size: 12px;
  color: #909399;
  margin-left: 8px;
}

:deep(.el-table__row:hover) {
  background-color: #f5f7fa;
}
</style>
