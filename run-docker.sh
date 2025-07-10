#!/bin/bash

# MicroStack Docker运行脚本
# 用于在Docker容器中运行当前微服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}MicroStack Docker运行脚本${NC}"
    echo ""
    echo "使用方法:"
    echo "  ./run-docker.sh [options]"
    echo ""
    echo "选项:"
    echo "  --port PORT     指定端口号 (默认: 8080，若被占用会自动递增)"
    echo "  --name NAME     容器名称 (默认: microstack-service)"
    echo "  --build         运行前构建镜像"
    echo "  --detach        后台运行"
    echo "  --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./run-docker.sh                    # 使用默认配置运行"
    echo "  ./run-docker.sh --build --port 8090 # 构建并运行在8090端口"
    echo "  ./run-docker.sh --detach           # 后台运行"
}

# 检查Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: 未找到Docker${NC}"
        echo "请先安装Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker ps &> /dev/null; then
        echo -e "${RED}错误: Docker服务未运行${NC}"
        echo "请启动Docker服务"
        exit 1
    fi
}

# 创建Docker网络
create_network() {
    if ! docker network ls | grep -q "microstack-network"; then
        echo -e "${YELLOW}创建Docker网络: microstack-network${NC}"
        docker network create microstack-network
    fi
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if command -v lsof &> /dev/null; then
        lsof -i :$port &> /dev/null
    elif command -v netstat &> /dev/null; then
        netstat -an | grep -q ":$port "
    else
        # 尝试连接端口
        (echo >/dev/tcp/localhost/$port) &>/dev/null
    fi
}

# 查找可用端口
find_available_port() {
    local start_port=$1
    local max_attempts=50
    local current_port=$start_port
    
    for ((i=0; i<max_attempts; i++)); do
        if ! check_port $current_port; then
            echo $current_port
            return 0
        else
            current_port=$((current_port + 1))
        fi
    done
    
    return 1
}

# 构建镜像
build_image() {
    local service_name=$1
    echo -e "${YELLOW}🔨 构建镜像 ${service_name}...${NC}"
    
    # 创建临时Dockerfile
    cat > Dockerfile.tmp << EOF
FROM python:3.9-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# 创建应用用户
RUN useradd -m -u 1000 app

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建配置目录
RUN mkdir -p /app/config

# 设置权限
RUN chown -R app:app /app
USER app

# 设置环境变量
ENV PYTHONPATH=/app
ENV CONFIG_PATH=/app/config/config.yaml

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \\
    CMD curl -f http://localhost:\${PORT:-8080}/health || exit 1

# 启动命令
CMD ["python3", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
EOF
    
    docker build -f Dockerfile.tmp -t ${service_name}:latest .
    rm Dockerfile.tmp
    
    echo -e "${GREEN}✅ 镜像构建完成${NC}"
}

# 运行容器
run_container() {
    local container_name=$1
    local port=$2
    local detach=$3
    
    # 停止并删除已存在的容器
    if docker ps -a | grep -q "$container_name"; then
        echo -e "${YELLOW}停止已存在的容器...${NC}"
        docker stop $container_name 2>/dev/null || true
        docker rm $container_name 2>/dev/null || true
    fi
    
    # 准备运行参数
    local docker_args="-p ${port}:${port}"
    docker_args="${docker_args} --name ${container_name}"
    docker_args="${docker_args} --network microstack-network"
    docker_args="${docker_args} -e PORT=${port}"
    docker_args="${docker_args} -e CONFIG_PATH=/app/config/config.yaml"
    
    # 挂载配置文件（如果存在）
    if [ -f "config/config.yaml" ]; then
        docker_args="${docker_args} -v $(pwd)/config:/app/config:ro"
    fi
    
    if [ -z "$detach" ]; then
        docker_args="${docker_args} --rm -it"
    else
        docker_args="${docker_args} -d"
    fi
    
    # 运行容器
    echo -e "${GREEN}🐳 运行容器 ${container_name}...${NC}"
    echo -e "${BLUE}📍 端口映射: localhost:${port} -> container:${port}${NC}"
    echo -e "${BLUE}📚 API文档: http://localhost:${port}/docs${NC}"
    
    if [ -f "config/config.yaml" ]; then
        echo -e "${BLUE}🔧 配置挂载: ./config -> /app/config${NC}"
    fi
    
    if [ -z "$detach" ]; then
        echo ""
        echo -e "${YELLOW}按 Ctrl+C 停止容器${NC}"
        echo ""
    fi
    
    docker run ${docker_args} ${container_name}:latest
    
    if [ ! -z "$detach" ]; then
        echo -e "${GREEN}✅ 容器已在后台运行${NC}"
        echo -e "${BLUE}查看日志: docker logs -f ${container_name}${NC}"
        echo -e "${BLUE}停止容器: docker stop ${container_name}${NC}"
    fi
}

# 主函数
main() {
    # 默认值
    PORT=8080
    CONTAINER_NAME="microstack-service"
    BUILD=""
    DETACH=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port)
                PORT=$2
                shift 2
                ;;
            --name)
                CONTAINER_NAME=$2
                shift 2
                ;;
            --build)
                BUILD="yes"
                shift
                ;;
            --detach|-d)
                DETACH="yes"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}错误: 未知参数 '$1'${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查环境
    check_docker
    create_network
    
    # 检查并分配可用端口
    echo -e "${YELLOW}🔍 检查端口可用性...${NC}"
    AVAILABLE_PORT=$(find_available_port $PORT)
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 无法找到可用端口 (尝试范围: $PORT-$((PORT + 49)))${NC}"
        exit 1
    fi
    
    # 如果端口发生变化，提醒用户
    if [ "$AVAILABLE_PORT" != "$PORT" ]; then
        echo -e "${YELLOW}⚠️ 端口 $PORT 已被占用${NC}"
        echo -e "${BLUE}💡 已自动切换到端口 $AVAILABLE_PORT${NC}"
    else
        echo -e "${GREEN}✅ 端口 $PORT 可用${NC}"
    fi
    echo ""
    
    PORT=$AVAILABLE_PORT
    
    # 构建镜像（如果需要）
    if [ ! -z "$BUILD" ]; then
        build_image $CONTAINER_NAME
        echo ""
    fi
    
    # 检查镜像是否存在
    if ! docker images | grep -q "$CONTAINER_NAME"; then
        echo -e "${YELLOW}镜像不存在，正在构建...${NC}"
        build_image $CONTAINER_NAME
        echo ""
    fi
    
    # 运行容器
    run_container $CONTAINER_NAME $PORT $DETACH
}

# 执行主函数
main "$@"