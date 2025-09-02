<template>
  <div class="project-new">
    <div class="page-header">
      <el-button @click="$router.back()" type="text">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
      <h2>新建项目</h2>
    </div>
    
    <el-card class="form-card">
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        @submit.prevent="handleSubmit"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="项目名称" prop="name">
              <el-input
                v-model="form.name"
                placeholder="请输入项目名称"
                clearable
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="项目状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择项目状态">
                <el-option label="进行中" value="active" />
                <el-option label="已暂停" value="paused" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="项目描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="4"
            placeholder="请输入项目描述"
          />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="开始日期" prop="start_date">
              <el-date-picker
                v-model="form.start_date"
                type="date"
                placeholder="选择开始日期"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预计结束日期" prop="end_date">
              <el-date-picker
                v-model="form.end_date"
                type="date"
                placeholder="选择结束日期"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-divider content-position="left">项目阶段设置</el-divider>
        
        <div class="stages-section">
          <div class="section-header">
            <h4>项目阶段</h4>
            <el-button 
              type="primary" 
              size="small" 
              @click="addStage"
              style="background-color: #409EFF; color: white; border: 2px solid #409EFF;"
            >
              <el-icon><Plus /></el-icon>
              添加阶段
            </el-button>
          </div>
          
          <div class="stages-list">
            <div
              v-for="(stage, index) in form.stages"
              :key="index"
              class="stage-item"
            >
              <el-row :gutter="20" align="middle">
                <el-col :span="6">
                  <el-input
                    v-model="stage.name"
                    placeholder="阶段名称"
                  />
                </el-col>
                <el-col :span="8">
                  <el-input
                    v-model="stage.description"
                    placeholder="阶段描述"
                  />
                </el-col>
                <el-col :span="4">
                  <el-date-picker
                    v-model="stage.start_date"
                    type="date"
                    placeholder="开始日期"
                    size="small"
                    style="width: 100%"
                  />
                </el-col>
                <el-col :span="4">
                  <el-date-picker
                    v-model="stage.end_date"
                    type="date"
                    placeholder="结束日期"
                    size="small"
                    style="width: 100%"
                  />
                </el-col>
                <el-col :span="2">
                  <el-button
                    type="danger"
                    size="small"
                    @click="removeStage(index)"
                    :disabled="form.stages.length <= 1"
                  >
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </el-col>
              </el-row>
            </div>
          </div>
        </div>
        
        <el-divider content-position="left">团队成员设置</el-divider>
        
        <div class="members-section">
          <div class="section-header">
            <h4>团队成员</h4>
            <el-button 
              type="primary" 
              size="small" 
              @click="addMember"
              style="background-color: #67C23A; color: white; border: 2px solid #67C23A;"
            >
              <el-icon><Plus /></el-icon>
              添加成员
            </el-button>
          </div>
          
          <div class="members-list">
            <div
              v-for="(member, index) in form.team_members"
              :key="index"
              class="member-item"
            >
              <el-row :gutter="20" align="middle">
                <el-col :span="6">
                  <el-input
                    v-model="member.name"
                    placeholder="成员姓名"
                  />
                </el-col>
                <el-col :span="6">
                  <el-input
                    v-model="member.email"
                    placeholder="邮箱地址"
                  />
                </el-col>
                <el-col :span="6">
                  <el-select
                    v-model="member.role"
                    placeholder="选择角色"
                    style="width: 100%"
                  >
                    <el-option
                      v-for="role in availableRoles"
                      :key="role.name"
                      :label="role.display_name"
                      :value="role.name"
                    />
                  </el-select>
                </el-col>
                <el-col :span="4">
                  <el-switch
                    v-model="member.is_active"
                    active-text="激活"
                    inactive-text="禁用"
                  />
                </el-col>
                <el-col :span="2">
                  <el-button
                    type="danger"
                    size="small"
                    @click="removeMember(index)"
                  >
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </el-col>
              </el-row>
            </div>
          </div>
        </div>
        
        <div class="form-actions">
          <el-button @click="$router.back()">取消</el-button>
          <el-button
            type="primary"
            @click="handleSubmit"
            :loading="loading"
            style="background-color: #67C23A; color: white; border: 2px solid #67C23A; font-size: 16px; padding: 12px 24px;"
          >
            创建项目
          </el-button>
          

        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useProjectStore } from '../stores/project'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Plus, Delete } from '@element-plus/icons-vue'
import api from '../utils/api'
import dayjs from 'dayjs'

export default {
  name: 'ProjectNew',
  components: {
    ArrowLeft,
    Plus,
    Delete
  },
  setup() {
    const router = useRouter()
    const projectStore = useProjectStore()
    const formRef = ref()
    const loading = ref(false)
    const availableRoles = ref([])
    
    const form = reactive({
      name: '',
      description: '',
      status: 'active',
      start_date: new Date(),
      end_date: dayjs().add(1, 'month').toDate(),
      stages: [
        {
          name: '需求分析',
          description: '项目需求调研和分析',
          start_date: new Date(),
          end_date: dayjs().add(1, 'week').toDate(),
          order: 1
        }
      ],
      team_members: [
        {
          name: '',
          email: '',
          role: 'pm',
          is_active: true
        }
      ]
    })
    
    const rules = {
      name: [
        { required: true, message: '请输入项目名称', trigger: 'blur' }
      ],
      start_date: [
        { required: true, message: '请选择开始日期', trigger: 'change' }
      ],
      end_date: [
        { required: true, message: '请选择结束日期', trigger: 'change' }
      ]
    }
    
    // 获取可用角色
    const fetchRoles = async () => {
      try {
        console.log('开始获取角色数据...')
        const response = await api.get('/roles')
        console.log('角色数据响应:', response.data)
        availableRoles.value = response.data
      } catch (error) {
        console.error('获取角色失败:', error)
        // 如果API调用失败，使用默认角色
        availableRoles.value = [
          { name: 'pm', display_name: '项目经理(PM)' },
          { name: 'po', display_name: '产品经理(PO)' },
          { name: 'frontend', display_name: '客户端程序' },
          { name: 'backend', display_name: '服务器程序' },
          { name: 'ui', display_name: 'UI设计师' },
          { name: 'vfx', display_name: '特效师' },
          { name: 'audio', display_name: '音频师' },
          { name: 'tester', display_name: '测试工程师' }
        ]
      }
    }
    
    // 添加阶段
    const addStage = () => {
      console.log('添加阶段，当前阶段数:', form.stages.length)
      const lastStage = form.stages[form.stages.length - 1]
      const startDate = lastStage ? dayjs(lastStage.end_date).add(1, 'day').toDate() : new Date()
      
      const newStage = {
        name: '',
        description: '',
        start_date: startDate,
        end_date: dayjs(startDate).add(1, 'week').toDate(),
        order: form.stages.length + 1
      }
      
      form.stages.push(newStage)
      console.log('阶段添加成功，新阶段:', newStage)
      console.log('当前所有阶段:', form.stages)
    }
    
    // 删除阶段
    const removeStage = (index) => {
      console.log('删除阶段，索引:', index)
      form.stages.splice(index, 1)
      // 重新排序
      form.stages.forEach((stage, idx) => {
        stage.order = idx + 1
      })
      console.log('阶段删除后:', form.stages)
    }
    
    // 添加成员
    const addMember = () => {
      console.log('添加成员，当前成员数:', form.team_members.length)
      const newMember = {
        name: '',
        email: '',
        role: 'frontend',
        is_active: true
      }
      
      form.team_members.push(newMember)
      console.log('成员添加成功，新成员:', newMember)
      console.log('当前所有成员:', form.team_members)
    }
    
    // 删除成员
    const removeMember = (index) => {
      console.log('删除成员，索引:', index)
      form.team_members.splice(index, 1)
      console.log('成员删除后:', form.team_members)
    }
    
    // 提交表单
    const handleSubmit = async () => {
      try {
        console.log('开始提交表单...')
        console.log('表单数据:', form)
        
        await formRef.value.validate()
        console.log('表单验证通过')
        
        loading.value = true
        
        // 1. 创建项目
        const projectData = {
          name: form.name,
          description: form.description,
          status: form.status,
          start_date: dayjs(form.start_date).format('YYYY-MM-DDTHH:mm:ssZ'),
          end_date: dayjs(form.end_date).format('YYYY-MM-DDTHH:mm:ssZ')
        }
        
        console.log('项目数据:', projectData)
        const project = await projectStore.createProject(projectData)
        console.log('项目创建成功:', project)
        ElMessage.success('项目创建成功')
        
        // 2. 创建项目阶段
        console.log('开始创建项目阶段...')
        for (const stage of form.stages) {
          if (stage.name.trim()) {
            const stageData = {
              project_id: project.id,
              name: stage.name,
              description: stage.description,
              start_date: dayjs(stage.start_date).format('YYYY-MM-DDTHH:mm:ssZ'),
              end_date: dayjs(stage.end_date).format('YYYY-MM-DDTHH:mm:ssZ'),
              order: stage.order
            }
            console.log('创建阶段:', stageData)
            await projectStore.createStage(stageData)
            console.log('阶段创建成功')
          }
        }
        
        // 3. 创建团队成员
        console.log('开始创建团队成员...')
        for (const member of form.team_members) {
          if (member.name.trim()) {
            const memberData = {
              project_id: project.id,
              name: member.name,
              email: member.email || '', // 如果邮箱为空，使用空字符串
              role: member.role,
              is_active: member.is_active
            }
            console.log('创建成员:', memberData)
            await projectStore.createTeamMember(memberData)
            console.log('成员创建成功')
          }
        }
        
        ElMessage.success('项目、阶段和团队成员创建完成')
        router.push(`/project/${project.id}`)
        
      } catch (error) {
        console.error('创建项目失败:', error)
        if (error !== 'validation failed') {
          ElMessage.error('创建项目失败，请重试')
        }
      } finally {
        loading.value = false
      }
    }
    
    onMounted(() => {
      console.log('ProjectNew组件已挂载')
      console.log('当前表单数据:', form)
      console.log('当前角色数据:', availableRoles)
      fetchRoles()
    })
    
    return {
      formRef,
      form,
      rules,
      loading,
      availableRoles,
      addStage,
      removeStage,
      addMember,
      removeMember,
      handleSubmit
    }
  }
}
</script>

<style scoped>
.project-new {
  max-width: 1000px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.page-header h2 {
  color: #303133;
  font-size: 24px;
  font-weight: 600;
  margin: 0;
}

.form-card {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.stages-section,
.members-section {
  margin: 20px 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.section-header h4 {
  color: #303133;
  margin: 0;
}

.stage-item,
.member-item {
  margin-bottom: 16px;
  padding: 16px;
  border: 1px solid #EBEEF5;
  border-radius: 6px;
  background: #FAFAFA;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #EBEEF5;
}
</style>
