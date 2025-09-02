import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../utils/api'

export const useProjectStore = defineStore('project', () => {
  const projects = ref([])
  const currentProject = ref(null)
  const loading = ref(false)
  const selectedProjects = ref([])
  const exporting = ref(false)
  
  // 获取所有项目
  const fetchProjects = async () => {
    loading.value = true
    try {
      // 添加缓存破坏参数
      const timestamp = new Date().getTime()
      const response = await api.get(`/projects?t=${timestamp}`)
      console.log('API响应数据:', response.data)
      console.log('API响应数据类型:', typeof response.data)
      console.log('API响应数据长度:', response.data?.length)
      
      projects.value = response.data || []
      console.log('设置projects.value:', projects.value)
      console.log('projects.value长度:', projects.value.length)
      console.log('获取项目列表成功:', projects.value.length, '个项目')
      
      // 打印每个项目的详细信息
      projects.value.forEach((project, index) => {
        console.log(`项目 ${index + 1}:`, {
          id: project.id,
          name: project.name,
          description: project.description,
          status: project.status,
          stages: project.stages?.length || 0,
          team_members: project.team_members?.length || 0
        })
      })
      
      // 如果数据为空，尝试重新获取
      if (projects.value.length === 0) {
        console.log('数据为空，尝试重新获取...')
        const retryResponse = await api.get('/projects')
        projects.value = retryResponse.data || []
        console.log('重试获取项目列表:', projects.value.length, '个项目')
      }
    } catch (error) {
      console.error('获取项目列表失败:', error)
      // 如果获取失败，尝试清空列表并显示错误
      projects.value = []
      throw error
    } finally {
      loading.value = false
    }
  }
  
  // 获取单个项目详情
  const fetchProject = async (id) => {
    loading.value = true
    try {
      const response = await api.get(`/projects/${id}`)
      currentProject.value = response.data
      console.log('获取项目详情成功:', response.data.name)
      return response.data
    } catch (error) {
      console.error('获取项目详情失败:', error)
      currentProject.value = null
      throw error
    } finally {
      loading.value = false
    }
  }
  
  // 创建项目
  const createProject = async (projectData) => {
    loading.value = true
    try {
      const response = await api.post('/projects', projectData)
      const newProject = response.data
      projects.value.push(newProject)
      console.log('创建项目成功:', newProject.name, 'ID:', newProject.id)
      return newProject
    } catch (error) {
      console.error('创建项目失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }
  
  // 更新项目
  const updateProject = async (id, projectData) => {
    loading.value = true
    try {
      const response = await api.put(`/projects/${id}`, projectData)
      const index = projects.value.findIndex(p => p.id === id)
      if (index !== -1) {
        projects.value[index] = response.data
      }
      if (currentProject.value && currentProject.value.id === id) {
        currentProject.value = response.data
      }
      return response.data
    } catch (error) {
      console.error('更新项目失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }
  
  // 删除项目
  const deleteProject = async (id) => {
    loading.value = true
    try {
      await api.delete(`/projects/${id}`)
      projects.value = projects.value.filter(p => p.id !== id)
      if (currentProject.value && currentProject.value.id === id) {
        currentProject.value = null
      }
    } catch (error) {
      console.error('删除项目失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }
  
  // 获取甘特图数据
  const fetchGanttData = async (projectId) => {
    try {
      const response = await api.get(`/gantt/${projectId}`)
      return response.data
    } catch (error) {
      console.error('获取甘特图数据失败:', error)
      throw error
    }
  }
  
  // 创建阶段
  const createStage = async (stageData) => {
    try {
      const response = await api.post('/stages', stageData)
      return response.data
    } catch (error) {
      console.error('创建阶段失败:', error)
      throw error
    }
  }
  
  // 创建团队成员
  const createTeamMember = async (memberData) => {
    try {
      const response = await api.post('/members', memberData)
      return response.data
    } catch (error) {
      console.error('创建团队成员失败:', error)
      throw error
    }
  }
  
  // 批量导出项目
  const exportProjects = async (projectIds) => {
    exporting.value = true
    try {
      // 如果有多个项目，创建一个ZIP文件
      if (projectIds.length > 1) {
        await exportMultipleProjects(projectIds)
      } else {
        // 单个项目直接导出
        await exportSingleProject(projectIds[0])
      }
    } catch (error) {
      console.error('导出项目失败:', error)
      throw error
    } finally {
      exporting.value = false
    }
  }
  
  // 导出单个项目
  const exportSingleProject = async (projectId) => {
    const response = await api.get(`/projects/${projectId}/export`, {
      responseType: 'blob'
    })
    
    // 获取项目信息用于文件命名
    const project = projects.value.find(p => p.id === projectId)
    const projectName = project ? project.name : `项目_${projectId}`
    
    const blob = new Blob([response.data], { 
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
    })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${projectName}_甘特图.xlsx`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  }
  
  // 导出多个项目（创建ZIP）
  const exportMultipleProjects = async (projectIds) => {
    // 这里可以调用后端批量导出API，或者逐个导出
    // 暂时使用逐个导出的方式
    for (const projectId of projectIds) {
      await exportSingleProject(projectId)
    }
  }
  
  // 计算属性
  const activeProjects = computed(() => 
    projects.value.filter(p => p.status === 'active')
  )
  
  const completedProjects = computed(() => 
    projects.value.filter(p => p.status === 'completed')
  )
  
  return {
    projects,
    currentProject,
    loading,
    selectedProjects,
    exporting,
    activeProjects,
    completedProjects,
    fetchProjects,
    fetchProject,
    createProject,
    updateProject,
    deleteProject,
    fetchGanttData,
    createStage,
    createTeamMember,
    exportProjects
  }
})
