<template>
  <div class="password-auth">
    <div class="auth-container">
      <div class="auth-card">
        <div class="auth-header">
          <h1>🐟 咸鱼甘特图</h1>
          <p class="auth-subtitle">请输入密码以访问系统</p>
        </div>
        
        <el-form 
          ref="formRef" 
          :model="form" 
          :rules="rules" 
          class="auth-form"
          @submit.prevent="handleSubmit"
        >
          <el-form-item prop="password">
            <el-input
              v-model="form.password"
              type="password"
              placeholder="请输入密码"
              size="large"
              show-password
              :prefix-icon="Lock"
              @keyup.enter="handleSubmit"
              :loading="loading"
            />
          </el-form-item>
          
          <el-form-item>
            <el-button 
              type="primary" 
              size="large" 
              class="auth-button"
              @click="handleSubmit"
              :loading="loading"
              block
            >
              <el-icon><Key /></el-icon>
              解锁系统
            </el-button>
          </el-form-item>
        </el-form>
        
        <div class="auth-footer">
          <p class="hint-text">请输入正确的密码以访问系统</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Lock, Key } from '@element-plus/icons-vue'

export default {
  name: 'PasswordAuth',
  components: {
    Lock,
    Key
  },
  setup() {
    const router = useRouter()
    const formRef = ref(null)
    const loading = ref(false)
    
    const form = reactive({
      password: ''
    })
    
    const rules = {
      password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 1, message: '密码不能为空', trigger: 'blur' }
      ]
    }
    
    const handleSubmit = async () => {
      if (!formRef.value) return
      
      try {
        await formRef.value.validate()
        loading.value = true
        
        // 模拟验证延迟
        await new Promise(resolve => setTimeout(resolve, 500))
        
        // 验证密码
        if (form.password === 'zwl') {
          // 密码正确，设置认证状态
          localStorage.setItem('gantt_authenticated', 'true')
          localStorage.setItem('gantt_auth_time', Date.now().toString())
          
          ElMessage.success('验证成功，正在进入系统...')
          
          // 跳转到首页
          setTimeout(() => {
            router.push('/')
          }, 1000)
        } else {
          ElMessage.error('密码错误，请重新输入')
          form.password = ''
        }
      } catch (error) {
        console.error('表单验证失败:', error)
      } finally {
        loading.value = false
      }
    }
    
    return {
      formRef,
      form,
      rules,
      loading,
      handleSubmit
    }
  }
}
</script>

<style scoped>
.password-auth {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.auth-container {
  width: 100%;
  max-width: 400px;
}

.auth-card {
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.auth-header {
  text-align: center;
  margin-bottom: 30px;
}

.auth-header h1 {
  font-size: 28px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 8px;
}

.auth-subtitle {
  color: #909399;
  font-size: 14px;
  margin: 0;
}

.auth-form {
  margin-bottom: 20px;
}

.auth-button {
  height: 48px;
  font-size: 16px;
  font-weight: 500;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.auth-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
}

.auth-footer {
  text-align: center;
}

.hint-text {
  color: #909399;
  font-size: 12px;
  margin: 0;
  opacity: 0.8;
}

:deep(.el-input__wrapper) {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 1px solid #e4e7ed;
  transition: all 0.3s ease;
}

:deep(.el-input__wrapper:hover) {
  border-color: #667eea;
}

:deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
}

:deep(.el-form-item__error) {
  color: #f56c6c;
  font-size: 12px;
}
</style>
