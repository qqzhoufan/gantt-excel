import { createRouter, createWebHistory } from 'vue-router'
import ProjectList from '../views/ProjectList.vue'
import ProjectDetail from '../views/ProjectDetail.vue'
import ProjectNew from '../views/ProjectNew.vue'
import PasswordAuth from '../components/PasswordAuth.vue'

const routes = [
  {
    path: '/auth',
    name: 'PasswordAuth',
    component: PasswordAuth
  },
  {
    path: '/',
    name: 'ProjectList',
    component: ProjectList,
    meta: { requiresAuth: true }
  },
  {
    path: '/project/new',
    name: 'ProjectNew',
    component: ProjectNew,
    meta: { requiresAuth: true }
  },
  {
    path: '/project/:id',
    name: 'ProjectDetail',
    component: ProjectDetail,
    props: true,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 检查是否需要认证
  if (to.meta.requiresAuth) {
    const isAuthenticated = localStorage.getItem('gantt_authenticated') === 'true'
    const authTime = localStorage.getItem('gantt_auth_time')
    
    // 检查认证是否过期（24小时）
    const isExpired = authTime && (Date.now() - parseInt(authTime)) > 24 * 60 * 60 * 1000
    
    if (!isAuthenticated || isExpired) {
      // 清除过期的认证信息
      if (isExpired) {
        localStorage.removeItem('gantt_authenticated')
        localStorage.removeItem('gantt_auth_time')
      }
      next('/auth')
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
