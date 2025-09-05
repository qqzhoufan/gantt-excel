<template>
  <div class="gantt-chart">
    <div class="gantt-header">
      <h3>项目甘特图</h3>
      <div class="gantt-controls">
        <el-button-group>
          <el-button
            :type="viewMode === 'day' ? 'primary' : ''"
            @click="changeViewMode('day')"
          >
            日视图
          </el-button>
          <el-button
            :type="viewMode === 'week' ? 'primary' : ''"
            @click="changeViewMode('week')"
          >
            周视图
          </el-button>
          <el-button
            :type="viewMode === 'month' ? 'primary' : ''"
            @click="changeViewMode('month')"
          >
            月视图
          </el-button>
        </el-button-group>
        
        <!-- 导出按钮 -->
        <el-button type="success" @click="exportToExcel" :loading="exporting">
          <el-icon><Download /></el-icon>
          导出Excel
        </el-button>
      </div>
    </div>
    
    <div class="gantt-container" ref="ganttContainer">
      <div class="gantt-timeline">
        <!-- 时间轴 -->
        <div class="timeline-header">
          <div class="task-column">任务/阶段</div>
          <div class="dates-container">
            <div
              v-for="date in timelineDates"
              :key="date.key"
              class="date-cell"
              :class="{ 'weekend': date.isWeekend, 'today': date.isToday }"
              :style="{ width: cellWidth + 'px' }"
            >
              <div class="date-label">{{ date.label }}</div>
              <div class="date-subtitle">{{ date.subtitle }}</div>
            </div>
          </div>
        </div>
        
        <!-- 甘特图内容 -->
        <div class="gantt-content">
          <div
            v-for="stage in ganttData"
            :key="stage.id"
            class="stage-group"
          >
            <!-- 阶段行 -->
            <div class="gantt-row stage-row">
              <div class="task-column" style="display: flex; align-items: center; min-height: 60px;">
                <div class="stage-info" style="display: flex; align-items: center; width: 100%;">
                  <el-icon class="stage-icon"><FolderOpened /></el-icon>
                  <span class="stage-name">{{ stage.name }}</span>
                  <el-tag size="small" :type="getStatusType(stage.status)">
                    {{ getStatusText(stage.status) }}
                  </el-tag>
                  <div class="duration-info">
                    <span class="duration-label">工期:</span>
                    <span class="duration-value">{{ calculateWorkDays(stage.start_date, stage.end_date) }}天</span>
                  </div>
                </div>
              </div>
              <div class="dates-container">
                <div
                  class="gantt-bar stage-bar"
                  :style="getBarStyle(stage)"
                  :title="`${stage.name} (${stage.start_date} - ${stage.end_date})`"
                  @click="editStage(stage)"
                >
                  <div class="bar-content">
                    {{ stage.name }}
                  </div>
                  <div class="progress-bar" :style="{ width: stage.progress + '%' }"></div>
                  <div class="duration-tooltip">
                    {{ calculateWorkDays(stage.start_date, stage.end_date) }}工作日
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 任务行 -->
            <div
              v-for="task in stage.tasks"
              :key="task.id"
              class="gantt-row task-row"
            >
              <div class="task-column" style="display: flex; align-items: center; min-height: 60px;">
                <div class="task-info" style="display: flex; align-items: center; width: 100%;">
                  <el-icon class="task-icon"><Document /></el-icon>
                  <span class="task-name">{{ task.name }}</span>
                  <el-tag size="mini" :type="getPriorityType(task.priority)">
                    {{ getPriorityText(task.priority) }}
                  </el-tag>
                  <div class="duration-info">
                    <span class="duration-label">工期:</span>
                    <span class="duration-value">{{ calculateWorkDays(task.start_date, task.end_date) }}天</span>
                  </div>
                  <div v-if="task.assignee" class="assignee">
                    <el-avatar :size="20" class="assignee-avatar">
                      {{ task.assignee.name?.charAt(0) }}
                    </el-avatar>
                    <span class="assignee-name">{{ task.assignee.name }}</span>
                  </div>
                </div>
              </div>
              <div class="dates-container">
                <div
                  class="gantt-bar task-bar"
                  :style="getBarStyle(task)"
                  :title="`${task.name} (${task.start_date} - ${task.end_date})`"
                  @click="editTask(task)"
                >
                  <div class="bar-content">
                    {{ task.name }}
                  </div>
                  <div class="progress-bar" :style="{ width: task.progress + '%' }"></div>
                  <div class="duration-tooltip">
                    {{ calculateWorkDays(task.start_date, task.end_date) }}工作日
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 任务编辑对话框 -->
    <el-dialog
      v-model="showTaskDialog"
      :title="editingTask ? '编辑任务' : '新建任务'"
      width="600px"
      @close="closeTaskDialog"
    >
      <el-form
        ref="taskFormRef"
        :model="taskForm"
        :rules="taskRules"
        label-width="100px"
      >
        <el-form-item label="任务名称" prop="name">
          <el-input v-model="taskForm.name" placeholder="请输入任务名称" />
        </el-form-item>
        
        <el-form-item label="开始日期" prop="start_date">
          <el-date-picker
            v-model="taskForm.start_date"
            type="date"
            placeholder="选择开始日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="结束日期" prop="end_date">
          <el-date-picker
            v-model="taskForm.end_date"
            type="date"
            placeholder="选择结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="进度" prop="progress">
          <el-slider
            v-model="taskForm.progress"
            :min="0"
            :max="100"
            show-input
            :show-input-controls="false"
          />
        </el-form-item>
        
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="taskForm.priority" placeholder="选择优先级" style="width: 100%">
            <el-option label="低" value="low" />
            <el-option label="中" value="medium" />
            <el-option label="高" value="high" />
            <el-option label="紧急" value="urgent" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="状态" prop="status">
          <el-select v-model="taskForm.status" placeholder="选择状态" style="width: 100%">
            <el-option label="待开始" value="pending" />
            <el-option label="进行中" value="in_progress" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="closeTaskDialog">取消</el-button>
        <el-button type="primary" @click="saveTask" :loading="saving">
          {{ editingTask ? '更新' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
    
    <!-- 阶段编辑对话框 -->
    <el-dialog
      v-model="showStageDialog"
      :title="editingStage ? '编辑阶段' : '新建阶段'"
      width="600px"
      @close="closeStageDialog"
    >
      <el-form
        ref="stageFormRef"
        :model="stageForm"
        :rules="stageRules"
        label-width="100px"
      >
        <el-form-item label="阶段名称" prop="name">
          <el-input v-model="stageForm.name" placeholder="请输入阶段名称" />
        </el-form-item>
        
        <el-form-item label="开始日期" prop="start_date">
          <el-date-picker
            v-model="stageForm.start_date"
            type="date"
            placeholder="选择开始日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="结束日期" prop="end_date">
          <el-date-picker
            v-model="stageForm.end_date"
            type="date"
            placeholder="选择结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="进度" prop="progress">
          <el-slider
            v-model="stageForm.progress"
            :min="0"
            :max="100"
            show-input
            :show-input-controls="false"
          />
        </el-form-item>
        
        <el-form-item label="状态" prop="status">
          <el-select v-model="stageForm.status" placeholder="选择状态" style="width: 100%">
            <el-option label="待开始" value="pending" />
            <el-option label="进行中" value="in_progress" />
            <el-option label="已完成" value="completed" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="stageForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入阶段描述"
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="closeStageDialog">取消</el-button>
        <el-button type="primary" @click="saveStage" :loading="saving">
          {{ editingStage ? '更新' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch, reactive } from 'vue'
import { FolderOpened, Document, Download } from '@element-plus/icons-vue'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import api from '../utils/api'

export default {
  name: 'GanttChart',
  components: {
    FolderOpened,
    Document,
    Download
  },
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  emits: ['refresh'],
  setup(props, { emit }) {
    const ganttContainer = ref()
    const viewMode = ref('day')
    const cellWidth = 80
    const exporting = ref(false)
    
    // 编辑功能状态
    const showTaskDialog = ref(false)
    const showStageDialog = ref(false)
    const editingTask = ref(null)
    const editingStage = ref(null)
    const saving = ref(false)
    
    // 表单引用
    const taskFormRef = ref()
    const stageFormRef = ref()
    
    // 任务表单
    const taskForm = reactive({
      name: '',
      start_date: '',
      end_date: '',
      progress: 0,
      priority: 'medium',
      status: 'pending'
    })
    
    // 阶段表单
    const stageForm = reactive({
      name: '',
      start_date: '',
      end_date: '',
      progress: 0,
      status: 'pending',
      description: ''
    })
    
    // 表单验证规则
    const taskRules = {
      name: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
      start_date: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
      end_date: [{ required: true, message: '请选择结束日期', trigger: 'change' }]
    }
    
    const stageRules = {
      name: [{ required: true, message: '请输入阶段名称', trigger: 'blur' }],
      start_date: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
      end_date: [{ required: true, message: '请选择结束日期', trigger: 'change' }]
    }
    
    const ganttData = computed(() => props.data.timeline || [])
    const project = computed(() => props.data.project || {})
    
    // 计算工作日（排除周六周日）
    const calculateWorkDays = (startDate, endDate) => {
      if (!startDate || !endDate) return 0
      
      const start = dayjs(startDate)
      const end = dayjs(endDate)
      let workDays = 0
      let current = start
      
      while (current.isBefore(end) || current.isSame(end, 'day')) {
        const dayOfWeek = current.day()
        if (dayOfWeek !== 0 && dayOfWeek !== 6) { // 0=周日, 6=周六
          workDays++
        }
        current = current.add(1, 'day')
      }
      
      return workDays
    }
    
    // 生成时间轴日期
    const timelineDates = computed(() => {
      if (!project.value.start_date || !project.value.end_date) return []
      
      const start = dayjs(project.value.start_date)
      const end = dayjs(project.value.end_date)
      const dates = []
      const today = dayjs()
      
      console.log('时间轴调试:', {
        projectStart: start.format('YYYY-MM-DD'),
        projectEnd: end.format('YYYY-MM-DD'),
        cellWidth,
        viewMode: viewMode.value
      })
      
      let current = start
      
      switch (viewMode.value) {
        case 'day':
          // 日视图：包含开始日期到结束日期的所有天数
          while (current.isBefore(end) || current.isSame(end, 'day')) {
            const label = current.format('MM/DD')
            const subtitle = current.format('ddd')
            const key = current.format('YYYY-MM-DD')
            const isWeekend = current.day() === 0 || current.day() === 6
            const isToday = current.isSame(today, 'day')
            
            dates.push({ label, subtitle, key, isWeekend, isToday })
            current = current.add(1, 'day')
          }
          break
          
        case 'week':
          // 周视图：从包含开始日期的周开始，到包含结束日期的周结束
          const startWeek = start.startOf('week')
          const endWeek = end.startOf('week')
          current = startWeek
          
          while (current.isBefore(endWeek) || current.isSame(endWeek, 'week')) {
            const weekStart = current.startOf('week')
            const weekEnd = current.endOf('week')
            const label = `${weekStart.format('MM/DD')}周`
            const subtitle = `${weekStart.format('MM/DD')} - ${weekEnd.format('MM/DD')}`
            const key = current.format('YYYY-WW')
            
            dates.push({ label, subtitle, key, isWeekend: false, isToday: false })
            current = current.add(1, 'week')
          }
          break
          
        case 'month':
          // 月视图：从包含开始日期的月开始，到包含结束日期的月结束
          const startMonth = start.startOf('month')
          const endMonth = end.startOf('month')
          current = startMonth
          
          while (current.isBefore(endMonth) || current.isSame(endMonth, 'month')) {
            const label = current.format('MM月')
            const subtitle = current.format('YYYY')
            const key = current.format('YYYY-MM')
            
            dates.push({ label, subtitle, key, isWeekend: false, isToday: false })
            current = current.add(1, 'month')
          }
          break
      }
      
      console.log('生成的时间轴单元格数量:', dates.length)
      return dates
    })
    
    // 改变视图模式
    const changeViewMode = (mode) => {
      viewMode.value = mode
    }
    
    // 获取甘特图条样式
    const getBarStyle = (item) => {
      if (!project.value.start_date || !project.value.end_date || !item.start_date || !item.end_date) {
        return { display: 'none' }
      }
      
      const projectStart = dayjs(project.value.start_date)
      const projectEnd = dayjs(project.value.end_date)
      let itemStart = dayjs(item.start_date)
      let itemEnd = dayjs(item.end_date)
      
      // 确保任务/阶段时间在项目范围内
      if (itemStart.isBefore(projectStart)) {
        itemStart = projectStart
      }
      if (itemEnd.isAfter(projectEnd)) {
        itemEnd = projectEnd
      }
      
      // 如果调整后的开始时间晚于结束时间，隐藏该条
      if (itemStart.isAfter(itemEnd)) {
        return { display: 'none' }
      }
      
      let left = 0
      let width = 0
      
      switch (viewMode.value) {
        case 'day':
          // 日视图：精确计算天数偏移
          const startOffset = itemStart.diff(projectStart, 'day')
          const duration = itemEnd.diff(itemStart, 'day') + 1 // 包含结束日期
          left = Math.max(0, startOffset) * cellWidth
          width = duration * cellWidth
          break
          
        case 'week':
          // 周视图：计算周偏移，考虑实际的周边界
          const projectStartWeek = projectStart.startOf('week')
          const itemStartWeek = itemStart.startOf('week')
          const itemEndWeek = itemEnd.startOf('week')
          
          const weekStartOffset = itemStartWeek.diff(projectStartWeek, 'week')
          const weekDuration = itemEndWeek.diff(itemStartWeek, 'week') + 1
          
          left = Math.max(0, weekStartOffset) * cellWidth
          width = weekDuration * cellWidth
          break
          
        case 'month':
          // 月视图：计算月偏移，考虑实际的月边界
          const projectStartMonth = projectStart.startOf('month')
          const itemStartMonth = itemStart.startOf('month')
          const itemEndMonth = itemEnd.startOf('month')
          
          const monthStartOffset = itemStartMonth.diff(projectStartMonth, 'month')
          const monthDuration = itemEndMonth.diff(itemStartMonth, 'month') + 1
          
          left = Math.max(0, monthStartOffset) * cellWidth
          width = monthDuration * cellWidth
          break
      }
      
      // 调试信息
      console.log('甘特图条调试:', {
        itemName: item.name,
        viewMode: viewMode.value,
        originalStart: dayjs(item.start_date).format('YYYY-MM-DD'),
        originalEnd: dayjs(item.end_date).format('YYYY-MM-DD'),
        adjustedStart: itemStart.format('YYYY-MM-DD'),
        adjustedEnd: itemEnd.format('YYYY-MM-DD'),
        projectStart: projectStart.format('YYYY-MM-DD'),
        projectEnd: projectEnd.format('YYYY-MM-DD'),
        left,
        width,
        cellWidth
      })
      
      return {
        left: left + 'px',
        width: Math.max(width, 20) + 'px',
        position: 'absolute',
        top: '50%',
        transform: 'translateY(-50%)',
        zIndex: 2
      }
    }
    
    // 导出到Excel
    const exportToExcel = async () => {
      if (!project.value.id) {
        ElMessage.warning('请先选择项目')
        return
      }
      
      exporting.value = true
      try {
        // 这里调用后端导出API
        const response = await fetch(`/api/v1/projects/${project.value.id}/export`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json'
          }
        })
        
        if (response.ok) {
          const blob = await response.blob()
          const url = window.URL.createObjectURL(blob)
          const a = document.createElement('a')
          a.href = url
          a.download = `${project.value.name}_甘特图.xlsx`
          document.body.appendChild(a)
          a.click()
          document.body.removeChild(a)
          window.URL.revokeObjectURL(url)
          ElMessage.success('导出成功')
        } else {
          throw new Error('导出失败')
        }
      } catch (error) {
        console.error('导出错误:', error)
        ElMessage.error('导出失败，请稍后重试')
      } finally {
        exporting.value = false
      }
    }
    
    // 获取状态类型
    const getStatusType = (status) => {
      const statusMap = {
        pending: 'info',
        in_progress: 'warning',
        completed: 'success'
      }
      return statusMap[status] || 'info'
    }
    
    // 获取状态文本
    const getStatusText = (status) => {
      const statusMap = {
        pending: '待开始',
        in_progress: '进行中',
        completed: '已完成'
      }
      return statusMap[status] || '未知'
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
    
    // 编辑任务
    const editTask = (task) => {
      editingTask.value = task
      Object.assign(taskForm, {
        name: task.name,
        start_date: task.start_date,
        end_date: task.end_date,
        progress: task.progress,
        priority: task.priority,
        status: task.status
      })
      showTaskDialog.value = true
    }
    
    // 编辑阶段
    const editStage = (stage) => {
      editingStage.value = stage
      Object.assign(stageForm, {
        name: stage.name,
        start_date: stage.start_date,
        end_date: stage.end_date,
        progress: stage.progress,
        status: stage.status,
        description: stage.description || ''
      })
      showStageDialog.value = true
    }
    
    // 关闭任务对话框
    const closeTaskDialog = () => {
      showTaskDialog.value = false
      editingTask.value = null
      Object.assign(taskForm, {
        name: '',
        start_date: '',
        end_date: '',
        progress: 0,
        priority: 'medium',
        status: 'pending'
      })
      if (taskFormRef.value) {
        taskFormRef.value.resetFields()
      }
    }
    
    // 关闭阶段对话框
    const closeStageDialog = () => {
      showStageDialog.value = false
      editingStage.value = null
      Object.assign(stageForm, {
        name: '',
        start_date: '',
        end_date: '',
        progress: 0,
        status: 'pending',
        description: ''
      })
      if (stageFormRef.value) {
        stageFormRef.value.resetFields()
      }
    }
    
    // 保存任务
    const saveTask = async () => {
      if (!taskFormRef.value) return
      
      try {
        await taskFormRef.value.validate()
        saving.value = true
        
        // 转换字段名以匹配后端API
        const taskData = {
          name: taskForm.name,
          start_date: taskForm.start_date,
          end_date: taskForm.end_date,
          progress: taskForm.progress,
          priority: taskForm.priority,
          status: taskForm.status
        }
        
        if (editingTask.value) {
          // 更新任务
          await api.put(`/tasks/${editingTask.value.id}`, taskData)
          ElMessage.success('任务更新成功')
        } else {
          // 创建任务
          await api.post('/tasks', {
            ...taskData,
            stage_id: editingTask.value?.stage_id || ganttData.value[0]?.id
          })
          ElMessage.success('任务创建成功')
        }
        
        closeTaskDialog()
        // 触发父组件刷新数据
        emit('refresh')
      } catch (error) {
        console.error('保存任务失败:', error)
        ElMessage.error('保存任务失败: ' + (error.response?.data?.error || error.message))
      } finally {
        saving.value = false
      }
    }
    
    // 保存阶段
    const saveStage = async () => {
      if (!stageFormRef.value) return
      
      try {
        await stageFormRef.value.validate()
        saving.value = true
        
        // 转换字段名以匹配后端API
        const stageData = {
          name: stageForm.name,
          start_date: stageForm.start_date,
          end_date: stageForm.end_date,
          progress: stageForm.progress,
          status: stageForm.status,
          description: stageForm.description
        }
        
        if (editingStage.value) {
          // 更新阶段
          await api.put(`/stages/${editingStage.value.id}`, stageData)
          ElMessage.success('阶段更新成功')
        } else {
          // 创建阶段
          await api.post('/stages', {
            ...stageData,
            project_id: project.value.id
          })
          ElMessage.success('阶段创建成功')
        }
        
        closeStageDialog()
        // 触发父组件刷新数据
        emit('refresh')
      } catch (error) {
        console.error('保存阶段失败:', error)
        ElMessage.error('保存阶段失败: ' + (error.response?.data?.error || error.message))
      } finally {
        saving.value = false
      }
    }
    
    return {
      ganttContainer,
      viewMode,
      cellWidth,
      ganttData,
      project,
      timelineDates,
      exporting,
      showTaskDialog,
      showStageDialog,
      editingTask,
      editingStage,
      saving,
      taskFormRef,
      stageFormRef,
      taskForm,
      stageForm,
      taskRules,
      stageRules,
      calculateWorkDays,
      changeViewMode,
      getBarStyle,
      exportToExcel,
      getStatusType,
      getStatusText,
      getPriorityType,
      getPriorityText,
      editTask,
      editStage,
      closeTaskDialog,
      closeStageDialog,
      saveTask,
      saveStage
    }
  }
}
</script>

<style scoped>
.gantt-chart {
  background: white;
  border-radius: 8px;
  overflow: hidden;
}

.gantt-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #EBEEF5;
  background: #FAFAFA;
}

.gantt-header h3 {
  margin: 0;
  color: #303133;
}

.gantt-container {
  overflow-x: auto;
  overflow-y: auto;
  max-height: 600px;
}

.gantt-timeline {
  min-width: 1000px;
  display: flex;
  flex-direction: column;
}

.task-column {
  width: 300px;
  padding: 12px 16px;
  border-right: 1px solid #EBEEF5;
  font-weight: 600;
  color: #303133;
  background: #F5F7FA;
  position: sticky;
  left: 0;
  z-index: 11;
  display: flex;
  align-items: center;
  min-height: 60px;
}

.dates-container {
  display: flex;
  flex: 1;
  position: relative;
  min-height: 60px;
  align-items: stretch;
}

.date-cell {
  flex-shrink: 0;
  box-sizing: border-box;
  border-right: 1px solid #EBEEF5;
  text-align: center;
  padding: 12px 8px;
  font-size: 12px;
  color: #606266;
  background: #F5F7FA;
}

.date-cell.weekend {
  color: #F56C6C; /* 周末日期颜色 */
}

.date-cell.today {
  background-color: #E1F3D8; /* 今天日期背景 */
  font-weight: bold;
}

.date-label {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.date-subtitle {
  font-size: 10px;
  color: #909399;
  margin-top: 4px;
}

.gantt-content {
  position: relative;
}

.stage-group {
  border-bottom: 1px solid #EBEEF5;
}

.gantt-row {
  display: flex;
  min-height: 60px;
  border-bottom: 1px solid #F5F7FA;
  align-items: center;
}

.gantt-row .task-column {
  display: flex;
  align-items: center;
  min-height: 60px;
}

.gantt-row:hover {
  background: #F9F9F9;
}

.stage-row .task-column {
  background: #FFF;
  position: sticky;
  left: 0;
  z-index: 5;
  display: flex;
  align-items: center;
  min-height: 60px;
}

.task-row .task-column {
  background: #FFF;
  position: sticky;
  left: 0;
  z-index: 5;
  padding-left: 32px;
  display: flex;
  align-items: center;
  min-height: 60px;
}

.stage-info,
.task-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  width: 100%;
}

.stage-icon,
.task-icon {
  color: #409EFF;
}

.stage-name,
.task-name {
  font-weight: 500;
  color: #303133;
}

.duration-info {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
}

.duration-label {
  font-weight: 500;
  color: #606266;
}

.duration-value {
  font-weight: 600;
  color: #303133;
}

.assignee {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-left: 8px;
}

.assignee-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 10px;
}

.assignee-name {
  font-size: 12px;
  color: #909399;
}

.gantt-bar {
  position: absolute;
  height: 32px;
  top: 50%;
  transform: translateY(-50%);
  border-radius: 4px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s;
  z-index: 2;
}

.stage-bar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  height: 32px;
}

.task-bar {
  background: linear-gradient(135deg, #42b883 0%, #369870 100%);
  color: white;
  height: 28px;
}

.bar-content {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  padding: 0 8px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  z-index: 2;
}

.progress-bar {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.3);
  transition: width 0.3s;
}

.gantt-bar:hover {
  transform: translateY(-50%) scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.duration-tooltip {
  position: absolute;
  top: -25px; /* Adjust tooltip position */
  left: 50%;
  transform: translateX(-50%);
  background-color: #303133;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  white-space: nowrap;
  z-index: 3;
  opacity: 0;
  transition: opacity 0.3s;
}

.gantt-bar:hover .duration-tooltip {
  opacity: 1;
}

/* 滚动条样式 */
.gantt-container::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.gantt-container::-webkit-scrollbar-track {
  background: #F5F7FA;
}

.gantt-container::-webkit-scrollbar-thumb {
  background: #C0C4CC;
  border-radius: 4px;
}

.gantt-container::-webkit-scrollbar-thumb:hover {
  background: #A4A9B0;
}

/* 强化时间轴对齐 */
.timeline-header {
  display: flex;
  background: #F5F7FA;
  border-bottom: 2px solid #DCDFE6;
  position: sticky;
  top: 0;
  z-index: 10;
  align-items: stretch;
}

.timeline-header .task-column {
  flex-shrink: 0;
  width: 300px;
  box-sizing: border-box;
}

.timeline-header .dates-container {
  display: flex;
  flex: 1;
  overflow: hidden;
  align-items: stretch;
}

/* 强化甘特图内容对齐 */
.gantt-content .gantt-row {
  display: flex;
  align-items: center;
  min-height: 60px;
}

.gantt-content .task-column {
  flex-shrink: 0;
  width: 300px;
  box-sizing: border-box;
  position: sticky;
  left: 0;
  z-index: 5;
}

.gantt-content .dates-container {
  display: flex;
  flex: 1;
  position: relative;
  min-height: 60px;
  align-items: center;
  overflow: hidden;
}

/* 确保甘特图条精确对齐 */
.gantt-bar {
  position: absolute !important;
  top: 50% !important;
  transform: translateY(-50%) !important;
  z-index: 2 !important;
  box-sizing: border-box;
}


.date-cell:first-child {
  margin-left: 0;
  border-left: none;
}

.date-cell:last-child {
  border-right: none;
}


/* 修复垂直对齐问题 */
.gantt-row .task-column,
.gantt-row .task-column .stage-info,
.gantt-row .task-column .task-info {
  display: flex !important;
  align-items: center !important;
  justify-content: flex-start !important;
}
</style>
