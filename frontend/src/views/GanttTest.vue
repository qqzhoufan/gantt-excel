<template>
  <div class="gantt-test">
    <div class="test-header">
      <h1>甘特图时间对齐测试</h1>
      <p>此页面用于测试甘特图时间对齐问题的修复效果</p>
      
      <div class="test-controls">
        <el-button-group>
          <el-button 
            :type="currentTest === 'normal' ? 'primary' : ''" 
            @click="switchTest('normal')"
          >
            正常测试数据
          </el-button>
          <el-button 
            :type="currentTest === 'boundary' ? 'primary' : ''" 
            @click="switchTest('boundary')"
          >
            边界测试数据
          </el-button>
        </el-button-group>
      </div>
      
      <div class="test-info">
        <el-alert
          v-if="currentTest === 'normal'"
          title="正常测试"
          description="项目时间：2024-09-01 至 2024-09-30，包含3个阶段和7个任务，测试正常时间对齐"
          type="info"
          show-icon
          :closable="false"
        />
        <el-alert
          v-if="currentTest === 'boundary'"
          title="边界测试"
          description="项目时间：2024-09-15 至 2024-09-25，包含超出项目范围的阶段和任务，测试边界处理"
          type="warning"
          show-icon
          :closable="false"
        />
      </div>
    </div>
    
    <div class="gantt-wrapper">
      <GanttChart :data="testData" @refresh="refreshData" />
    </div>
    
    <div class="debug-info">
      <el-collapse v-model="debugCollapse">
        <el-collapse-item title="调试信息" name="debug">
          <div class="debug-content">
            <h4>项目信息</h4>
            <pre>{{ JSON.stringify(testData.project, null, 2) }}</pre>
            
            <h4>时间轴数据</h4>
            <pre>{{ JSON.stringify(testData.timeline, null, 2) }}</pre>
          </div>
        </el-collapse-item>
      </el-collapse>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import GanttChart from '../components/GanttChart.vue'
import { testGanttData, boundaryTestData } from '../test-data.js'

export default {
  name: 'GanttTest',
  components: {
    GanttChart
  },
  setup() {
    const currentTest = ref('normal')
    const debugCollapse = ref([])
    
    const testData = computed(() => {
      return currentTest.value === 'normal' ? testGanttData : boundaryTestData
    })
    
    const switchTest = (testType) => {
      currentTest.value = testType
    }
    
    const refreshData = () => {
      console.log('刷新数据 - 当前测试:', currentTest.value)
    }
    
    return {
      currentTest,
      debugCollapse,
      testData,
      switchTest,
      refreshData
    }
  }
}
</script>

<style scoped>
.gantt-test {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.test-header {
  margin-bottom: 30px;
}

.test-header h1 {
  color: #303133;
  margin-bottom: 10px;
}

.test-header p {
  color: #606266;
  margin-bottom: 20px;
}

.test-controls {
  margin-bottom: 20px;
}

.test-info {
  margin-bottom: 20px;
}

.gantt-wrapper {
  margin-bottom: 30px;
  border: 1px solid #EBEEF5;
  border-radius: 8px;
  overflow: hidden;
}

.debug-info {
  background: #FAFAFA;
  border-radius: 8px;
  padding: 20px;
}

.debug-content h4 {
  color: #303133;
  margin: 16px 0 8px 0;
}

.debug-content h4:first-child {
  margin-top: 0;
}

.debug-content pre {
  background: #F5F7FA;
  padding: 12px;
  border-radius: 4px;
  font-size: 12px;
  color: #606266;
  overflow-x: auto;
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>