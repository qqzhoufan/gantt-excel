#!/bin/bash

# 防火墙配置脚本 - 开放甘特图项目所需端口

echo "🔥 配置防火墙规则..."
echo "=================================="

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用sudo运行此脚本"
    exit 1
fi

# 获取本机IP地址
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "🌐 本机IP地址: $LOCAL_IP"

# 检查ufw状态
if command -v ufw &> /dev/null; then
    echo "🔧 配置UFW防火墙..."
    
    # 开放必要端口
    ufw allow 9897/tcp comment "甘特图前端服务"
    ufw allow 9898/tcp comment "甘特图后端服务"
    ufw allow 5432/tcp comment "PostgreSQL数据库"
    
    echo "✅ UFW规则已添加"
    echo "📋 当前UFW规则:"
    ufw status numbered
else
    echo "⚠️  UFW未安装，跳过UFW配置"
fi

# 检查iptables
if command -v iptables &> /dev/null; then
    echo "🔧 配置iptables..."
    
    # 开放端口9897 (前端)
    iptables -A INPUT -p tcp --dport 9897 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 9897 -j ACCEPT
    
    # 开放端口9898 (后端)
    iptables -A INPUT -p tcp --dport 9898 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 9898 -j ACCEPT
    
    # 开放端口5432 (数据库)
    iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT
    
    echo "✅ iptables规则已添加"
else
    echo "⚠️  iptables未安装，跳过iptables配置"
fi

# 检查firewalld (CentOS/RHEL)
if command -v firewall-cmd &> /dev/null; then
    echo "🔧 配置firewalld..."
    
    # 开放端口
    firewall-cmd --permanent --add-port=9897/tcp
    firewall-cmd --permanent --add-port=9898/tcp
    firewall-cmd --permanent --add-port=5432/tcp
    
    # 重新加载配置
    firewall-cmd --reload
    
    echo "✅ firewalld规则已添加"
    echo "📋 当前开放的端口:"
    firewall-cmd --list-ports
else
    echo "⚠️  firewalld未安装，跳过firewalld配置"
fi

echo ""
echo "🎉 防火墙配置完成！"
echo "=================================="
echo "📱 前端端口: 9897"
echo "🔧 后端端口: 9898"
echo "🗄️  数据库端口: 5432"
echo ""
echo "💡 现在您可以通过以下地址访问服务:"
echo "   前端: http://$LOCAL_IP:9897"
echo "   后端: http://$LOCAL_IP:9898"
echo ""
echo "⚠️  注意: 如果仍然无法访问，请检查云服务商的安全组设置"
