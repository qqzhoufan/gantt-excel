#!/bin/bash

# 网络连通性测试脚本

echo "🌐 网络连通性测试"
echo "=================="

# 获取本机IP地址
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "本机IP地址: $LOCAL_IP"

# 测试端口是否开放
echo ""
echo "🔍 测试端口开放状态..."

# 测试前端端口9897
if nc -z localhost 9897 2>/dev/null; then
    echo "✅ 前端端口 9897: 开放"
else
    echo "❌ 前端端口 9897: 关闭"
fi

# 测试后端端口9898
if nc -z localhost 9898 2>/dev/null; then
    echo "✅ 后端端口 9898: 开放"
else
    echo "❌ 后端端口 9898: 关闭"
fi

# 测试数据库端口5432
if nc -z localhost 5432 2>/dev/null; then
    echo "✅ 数据库端口 5432: 开放"
else
    echo "❌ 数据库端口 5432: 关闭"
fi

# 测试服务响应
echo ""
echo "🔍 测试服务响应..."

# 测试前端服务
echo "测试前端服务 (http://localhost:9897)..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9897 | grep -q "200\|302"; then
    echo "✅ 前端服务响应正常"
else
    echo "❌ 前端服务无响应"
fi

# 测试后端服务
echo "测试后端服务 (http://localhost:9898/health)..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9898/health | grep -q "200"; then
    echo "✅ 后端服务响应正常"
else
    echo "❌ 后端服务无响应"
fi

# 测试外部访问
echo ""
echo "🔍 测试外部访问..."

# 测试前端外部访问
echo "测试前端外部访问 (http://$LOCAL_IP:9897)..."
if curl -s -o /dev/null -w "%{http_code}" http://$LOCAL_IP:9897 | grep -q "200\|302"; then
    echo "✅ 前端外部访问正常"
else
    echo "❌ 前端外部访问失败"
fi

# 测试后端外部访问
echo "测试后端外部访问 (http://$LOCAL_IP:9898/health)..."
if curl -s -o /dev/null -w "%{http_code}" http://$LOCAL_IP:9898/health | grep -q "200"; then
    echo "✅ 后端外部访问正常"
else
    echo "❌ 后端外部访问失败"
fi

# 测试前后端通信
echo ""
echo "🔍 测试前后端通信..."

# 通过前端代理测试后端API
echo "测试前端代理到后端API..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9897/api/v1/roles | grep -q "200"; then
    echo "✅ 前后端通信正常"
else
    echo "❌ 前后端通信失败"
fi

# 显示网络接口信息
echo ""
echo "🌐 网络接口信息:"
ip addr show | grep -E "inet.*scope global" | awk '{print "  " $2}'

# 显示路由信息
echo ""
echo "🛣️  路由信息:"
ip route show | head -5

echo ""
echo "🎯 测试完成！"
echo "如果外部访问失败，请检查:"
echo "1. 防火墙设置"
echo "2. 云服务商安全组"
echo "3. 服务是否正在运行"
