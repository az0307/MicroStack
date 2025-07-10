#!/bin/bash

# MicroStack 开发环境启动脚本
echo "启动 MicroStack 开发环境..."

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker没有运行，请先启动Docker"
    exit 1
fi

# 启动基础设施服务 (MongoDB, Redis)
echo "启动基础设施服务..."
docker-compose up -d mongodb redis

# 等待服务启动
echo "等待数据库服务启动..."
sleep 10

# 启动所有服务
echo "启动所有微服务..."
docker-compose up --build

echo "服务访问地址:"
echo "  API网关: http://localhost:8080"
echo "  用户服务: http://localhost:8081"
echo "  示例服务: http://localhost:8082"
echo "  MongoDB: localhost:27017"
echo "  Redis: localhost:6379"