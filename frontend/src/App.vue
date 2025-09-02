<template>
  <div id="app">
    <el-container class="app-container">
      <el-header class="app-header">
        <div class="header-content">
          <div class="logo">
            <h1>🐟 咸鱼甘特图</h1>
          </div>
          <div class="header-actions">
            <el-button type="primary" @click="createNewProject">
              <el-icon><Plus /></el-icon>
              新建项目
            </el-button>
            <el-button type="danger" @click="logout" plain>
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-button>
          </div>
        </div>
      </el-header>
      
      <el-main class="app-main">
        <router-view />
      </el-main>
    </el-container>
  </div>
</template>

<script>
import { Plus, SwitchButton } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'

export default {
  name: 'App',
  components: {
    Plus,
    SwitchButton
  },
  setup() {
    const router = useRouter()
    
    const createNewProject = () => {
      router.push('/project/new')
    }
    
    const logout = async () => {
      try {
        await ElMessageBox.confirm(
          '确定要退出登录吗？',
          '确认退出',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
          }
        )
        
        // 清除认证信息
        localStorage.removeItem('gantt_authenticated')
        localStorage.removeItem('gantt_auth_time')
        
        ElMessage.success('已退出登录')
        
        // 跳转到登录页面
        router.push('/auth')
      } catch (error) {
        // 用户取消退出
      }
    }
    
    return {
      createNewProject,
      logout
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
  height: 100vh;
}

.app-container {
  height: 100vh;
}

.app-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0 20px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
}

.logo h1 {
  font-size: 24px;
  font-weight: 600;
}

.app-main {
  padding: 20px;
  background-color: #f5f7fa;
  overflow-y: auto;
}

.el-button--primary {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.3);
}

.el-button--primary:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}

.el-button--danger.is-plain {
  background: rgba(245, 108, 108, 0.1);
  border-color: rgba(245, 108, 108, 0.3);
  color: #f56c6c;
}

.el-button--danger.is-plain:hover {
  background: rgba(245, 108, 108, 0.2);
  border-color: rgba(245, 108, 108, 0.5);
  color: #f56c6c;
}
</style>
