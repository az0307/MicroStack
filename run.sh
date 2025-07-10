#!/bin/bash

# MicroStack 微服务运行脚本
# 用于启动当前微服务项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}MicroStack 微服务运行脚本${NC}"
    echo ""
    echo "使用方法:"
    echo "  ./run.sh [options]"
    echo ""
    echo "选项:"
    echo "  --port PORT     指定端口号 (默认: 8080，若被占用会自动递增)"
    echo "  --host HOST     指定主机地址 (默认: 0.0.0.0)"
    echo "  --reload        开启热重载模式 (开发环境)"
    echo "  --workers NUM   工作进程数 (生产环境，默认: 1)"
    echo "  --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./run.sh                           # 使用默认配置运行"
    echo "  ./run.sh --port 8090 --reload     # 开发模式，自定义端口"
    echo "  ./run.sh --workers 4              # 生产模式，4个工作进程"
}

# 检查Python环境
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}错误: 未找到Python3${NC}"
        echo "请先安装Python 3.8或更高版本"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    if [ ! -f "requirements.txt" ]; then
        echo -e "${RED}错误: 未找到requirements.txt${NC}"
        exit 1
    fi
    
    # 检查是否已安装主要依赖
    if ! python3 -c "import fastapi" 2>/dev/null; then
        echo -e "${YELLOW}正在安装依赖...${NC}"
        pip install -r requirements.txt
    fi
}

# 检查配置文件
check_config() {
    if [ ! -f "config/config.yaml" ]; then
        echo -e "${YELLOW}警告: 未找到配置文件 config/config.yaml${NC}"
        echo "将使用默认配置"
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

# 主函数
main() {
    # 默认值
    PORT=8080
    HOST="0.0.0.0"
    RELOAD=""
    WORKERS=1
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port)
                PORT=$2
                shift 2
                ;;
            --host)
                HOST=$2
                shift 2
                ;;
            --reload)
                RELOAD="--reload"
                shift
                ;;
            --workers)
                WORKERS=$2
                shift 2
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
    
    # 环境检查
    check_python
    check_dependencies
    check_config
    
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
    
    # 设置环境变量
    export CONFIG_PATH="$(pwd)/config/config.yaml"
    export PORT=$PORT
    export PYTHONPATH="$(pwd)"
    
    # 启动服务
    echo -e "${GREEN}🚀 启动 MicroStack 微服务...${NC}"
    echo -e "${BLUE}📍 地址: http://${HOST}:${PORT}${NC}"
    echo -e "${BLUE}📚 API文档: http://${HOST}:${PORT}/docs${NC}"
    echo -e "${BLUE}📋 配置文件: ${CONFIG_PATH}${NC}"
    echo ""
    
    if [ ! -z "$RELOAD" ]; then
        echo -e "${YELLOW}🔄 开发模式 (热重载已启用)${NC}"
        echo -e "${YELLOW}按 Ctrl+C 停止服务${NC}"
        echo ""
        python3 -m uvicorn app:app --host ${HOST} --port ${PORT} ${RELOAD}
    else
        echo -e "${GREEN}🏭 生产模式 (${WORKERS} 个工作进程)${NC}"
        echo -e "${YELLOW}按 Ctrl+C 停止服务${NC}"
        echo ""
        python3 -m uvicorn app:app --host ${HOST} --port ${PORT} --workers ${WORKERS}
    fi
}

# 执行主函数
main "$@"