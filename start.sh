#!/bin/bash

# MicroStack 快速启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 MicroStack 快速启动${NC}"
echo ""

# 检查是否在MicroStack目录
if [ ! -f "app.py" ] || [ ! -f "init.sh" ]; then
    echo -e "${RED}❌ 请在MicroStack根目录运行此脚本${NC}"
    exit 1
fi

echo "请选择启动方式："
echo "1) 创建新的微服务项目 (推荐)"
echo "2) 直接运行模板进行快速原型开发"
echo "3) 使用Docker运行"
echo ""

read -p "请输入选择 (1-3): " choice

case $choice in
    1)
        echo ""
        read -p "请输入项目名称: " project_name
        read -p "请输入端口号 (默认8080): " port
        port=${port:-8080}
        read -p "是否初始化Git仓库? (y/N): " init_git
        
        echo ""
        echo -e "${YELLOW}🔧 创建项目 '$project_name'...${NC}"
        
        if [[ $init_git == "y" || $init_git == "Y" ]]; then
            ./init.sh "$project_name" --port "$port" --git
        else
            ./init.sh "$project_name" --port "$port"
        fi
        
        echo ""
        echo -e "${GREEN}✅ 项目创建完成！${NC}"
        echo -e "${BLUE}下一步:${NC}"
        echo "  cd $project_name"
        echo "  pip install -r requirements.txt"
        echo "  ./run.sh --reload"
        ;;
    2)
        echo ""
        read -p "请输入端口号 (默认8080): " port
        port=${port:-8080}
        
        echo ""
        echo -e "${YELLOW}📦 检查依赖...${NC}"
        if ! python3 -c "import fastapi" 2>/dev/null; then
            echo -e "${YELLOW}安装依赖中...${NC}"
            pip install -r requirements.txt
        fi
        
        echo ""
        echo -e "${GREEN}🚀 启动服务...${NC}"
        ./run.sh --port "$port" --reload
        ;;
    3)
        echo ""
        read -p "请输入端口号 (默认8080): " port
        port=${port:-8080}
        read -p "是否构建镜像? (y/N): " build_image
        
        echo ""
        if [[ $build_image == "y" || $build_image == "Y" ]]; then
            echo -e "${GREEN}🐳 构建并启动Docker服务...${NC}"
            ./run-docker.sh --port "$port" --build
        else
            echo -e "${GREEN}🐳 启动Docker服务...${NC}"
            ./run-docker.sh --port "$port"
        fi
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac