#!/bin/bash

# MicroStack 构建脚本
TAG=${1:-latest}

echo "构建 MicroStack 微服务架构..."

# 构建基础镜像
echo "构建基础镜像..."
docker build -t microstack-base:$TAG -f infrastructure/docker/Dockerfile.base .

if [ $? -ne 0 ]; then
    echo "基础镜像构建失败!"
    exit 1
fi

echo "构建完成! 使用 ./deploy.sh 启动服务"