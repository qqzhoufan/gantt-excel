// API健康检查工具
import api from './api'

/**
 * 检查API连接状态
 */
export const checkAPIConnection = async () => {
  try {
    console.log('🔍 检查API连接...')
    const response = await fetch('/api/v1/health')
    if (response.ok) {
      const data = await response.json()
      console.log('✅ API连接正常:', data)
      return { success: true, data }
    } else {
      console.error('❌ API连接失败:', response.status, response.statusText)
      return { success: false, error: `HTTP ${response.status}` }
    }
  } catch (error) {
    console.error('❌ API连接错误:', error)
    return { success: false, error: error.message }
  }
}

/**
 * 检查角色数据是否可用
 */
export const checkRolesAPI = async () => {
  try {
    console.log('🔍 检查角色API...')
    const response = await api.get('/roles')
    console.log('✅ 角色数据加载成功:', response.data)
    return { success: true, data: response.data }
  } catch (error) {
    console.error('❌ 角色数据加载失败:', error)
    return { success: false, error: error.message }
  }
}

/**
 * 测试项目创建API
 */
export const testProjectCreationAPI = async () => {
  try {
    console.log('🔍 测试项目创建API...')
    // 只测试API端点是否存在，不实际创建项目
    const response = await fetch('/api/v1/projects', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({}) // 发送空数据，应该返回400而不是405
    })
    
    if (response.status === 405) {
      console.error('❌ 项目创建API不可用: 405 Method Not Allowed')
      return { success: false, error: 'API端点不支持POST方法' }
    } else if (response.status === 400) {
      console.log('✅ 项目创建API可用 (返回400是因为数据验证失败，这是正常的)')
      return { success: true, message: 'API端点正常' }
    } else {
      console.log(`ℹ️ 项目创建API响应: ${response.status}`)
      return { success: true, message: `API响应状态: ${response.status}` }
    }
  } catch (error) {
    console.error('❌ 项目创建API测试失败:', error)
    return { success: false, error: error.message }
  }
}

/**
 * 综合健康检查
 */
export const runFullHealthCheck = async () => {
  console.log('🚀 开始综合健康检查...')
  
  const results = {
    api: await checkAPIConnection(),
    roles: await checkRolesAPI(),
    projectCreation: await testProjectCreationAPI()
  }
  
  console.log('📊 健康检查结果:', results)
  
  const allHealthy = Object.values(results).every(result => result.success)
  
  if (allHealthy) {
    console.log('✅ 所有API检查通过！')
  } else {
    console.warn('⚠️ 部分API检查失败，请检查后端服务')
  }
  
  return results
}

/**
 * 在开发模式下自动运行健康检查
 */
if (import.meta.env.DEV) {
  // 延迟运行，确保应用已经启动
  setTimeout(() => {
    runFullHealthCheck()
  }, 1000)
}