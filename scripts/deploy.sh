#!/bin/bash

# MicroStack 部署脚本
ENV=${1:-dev}
TAG=${2:-latest}

echo "部署 MicroStack 到 $ENV 环境..."

case $ENV in
    "dev")
        echo "启动开发环境..."
        docker-compose up -d
        ;;
    "prod")
        echo "启动生产环境..."
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
        ;;
    *)
        echo "未知环境: $ENV"
        echo "使用方法: ./deploy.sh [dev|prod] [tag]"
        exit 1
        ;;
esac

echo "等待服务启动..."
sleep 15

# 健康检查
echo "执行健康检查..."
services=("api-gateway:8080" "user-service:8081" "example-service:8082")

for service in "${services[@]}"; do
    name=$(echo $service | cut -d':' -f1)
    port=$(echo $service | cut -d':' -f2)
    
    echo "检查 $name..."
    if curl -f http://localhost:$port/health > /dev/null 2>&1; then
        echo "✓ $name 健康"
    else
        echo "✗ $name 不健康"
    fi
done

echo "部署完成!"