#!/bin/bash

# MicroStack 项目初始化脚本
# 基于 MicroStack 脚手架创建新的微服务项目

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}MicroStack 项目初始化脚本${NC}"
    echo ""
    echo "使用方法:"
    echo "  ./init.sh <project-name> [options]"
    echo ""
    echo "选项:"
    echo "  --port PORT     默认端口号 (默认: 8080)"
    echo "  --git           初始化Git仓库"
    echo "  --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  ./init.sh my-service                    # 创建名为my-service的项目"
    echo "  ./init.sh user-api --port 8081 --git   # 创建项目并初始化Git"
}

# 验证项目名称
validate_project_name() {
    local name=$1
    
    # 检查是否为空
    if [ -z "$name" ]; then
        echo -e "${RED}错误: 项目名称不能为空${NC}"
        return 1
    fi
    
    # 检查格式（只允许字母、数字、连字符）
    if [[ ! "$name" =~ ^[a-zA-Z0-9-]+$ ]]; then
        echo -e "${RED}错误: 项目名称只能包含字母、数字和连字符${NC}"
        return 1
    fi
    
    # 检查目录是否已存在
    if [ -d "$name" ]; then
        echo -e "${RED}错误: 目录 '$name' 已存在${NC}"
        return 1
    fi
    
    return 0
}

# 创建项目目录结构
create_project_structure() {
    local project_name=$1
    local port=$2
    
    echo -e "${YELLOW}📁 创建项目目录结构...${NC}"
    
    # 创建项目目录
    mkdir -p "$project_name"
    cd "$project_name"
    
    # 创建基本目录结构
    mkdir -p config
    mkdir -p shared/{config,database,utils}
    mkdir -p tests
    mkdir -p docs
    
    echo -e "${GREEN}✅ 目录结构创建完成${NC}"
}

# 复制核心文件
copy_core_files() {
    local project_name=$1
    local port=$2
    local source_dir=$3
    
    echo -e "${YELLOW}📄 复制核心文件...${NC}"
    
    # 复制主应用文件
    cp "$source_dir/app.py" .
    
    # 复制shared模块
    cp -r "$source_dir/shared"/* shared/
    
    # 复制配置文件
    cp "$source_dir/config/config.yaml" config/
    
    # 复制依赖文件
    cp "$source_dir/requirements.txt" .
    
    # 复制运行脚本
    cp "$source_dir/run.sh" .
    cp "$source_dir/run-docker.sh" .
    chmod +x run.sh run-docker.sh
    
    # 复制其他文件
    cp "$source_dir/.gitignore" .
    
    echo -e "${GREEN}✅ 核心文件复制完成${NC}"
}

# 自定义配置
customize_config() {
    local project_name=$1
    local port=$2
    
    echo -e "${YELLOW}⚙️  自定义项目配置...${NC}"
    
    # 更新配置文件
    sed -i.bak "s/microstack-service/$project_name/g" config/config.yaml
    sed -i.bak "s/port: 8080/port: $port/g" config/config.yaml
    rm config/config.yaml.bak
    
    echo -e "${GREEN}✅ 配置自定义完成${NC}"
}

# 创建项目文档
create_docs() {
    local project_name=$1
    local port=$2
    
    echo -e "${YELLOW}📚 创建项目文档...${NC}"
    
    # 创建README.md
    cat > README.md << EOF
# ${project_name}

基于 [MicroStack](https://github.com/your-org/microstack) 脚手架构建的微服务

## 快速开始

### 本地运行

\`\`\`bash
# 安装依赖
pip install -r requirements.txt

# 启动服务
./run.sh

# 开发模式（热重载）
./run.sh --reload
\`\`\`

### Docker运行

\`\`\`bash
# 构建并运行
./run-docker.sh --build

# 后台运行
./run-docker.sh --detach
\`\`\`

## API文档

启动服务后访问：
- **API文档**: http://localhost:${port}/docs
- **健康检查**: http://localhost:${port}/health

## 开发指南

### 项目结构

\`\`\`
${project_name}/
├── app.py              # 主应用入口
├── config/             # 配置文件
├── shared/             # 共享组件
│   ├── config/         # 配置管理
│   ├── database/       # 数据库连接
│   └── utils/          # 工具函数
├── tests/              # 测试文件
└── docs/               # 文档
\`\`\`

### 添加新的API端点

在 \`app.py\` 中添加新的FastAPI路由：

\`\`\`python
@app.get("/api/your-endpoint")
async def your_endpoint():
    return {"message": "Hello World"}
\`\`\`

### 配置管理

修改 \`config/config.yaml\` 来调整服务配置：

\`\`\`yaml
app:
  name: "${project_name}"
  port: ${port}
  debug: false
\`\`\`

## 许可证

[MIT License](LICENSE)
EOF

    # 创建开发文档
    cat > docs/DEVELOPMENT.md << EOF
# ${project_name} 开发指南

## 环境设置

### 依赖安装

\`\`\`bash
pip install -r requirements.txt
\`\`\`

### 环境变量

\`\`\`bash
export CONFIG_PATH=./config/config.yaml
export PORT=${port}
\`\`\`

## API开发

### 添加新端点

1. 在 \`app.py\` 中定义Pydantic模型
2. 添加路由函数
3. 添加适当的错误处理和日志

### 数据库操作

项目使用MongoDB作为默认数据库，通过 \`shared.database.mongodb\` 模块访问：

\`\`\`python
from shared.database.mongodb import MongoDBConnection

db_config = config.get('database.mongodb', {})
db = MongoDBConnection(db_config)

# 使用数据库
collection = db.database.your_collection
result = collection.insert_one(document)
\`\`\`

## 测试

\`\`\`bash
# 运行测试
pytest tests/

# 覆盖率测试
pytest --cov=app tests/
\`\`\`

## 部署

### Docker部署

\`\`\`bash
# 构建镜像
./run-docker.sh --build

# 生产环境运行
./run-docker.sh --detach --name ${project_name}-prod
\`\`\`
EOF

    echo -e "${GREEN}✅ 项目文档创建完成${NC}"
}

# 初始化Git仓库
init_git() {
    local project_name=$1
    
    echo -e "${YELLOW}🔧 初始化Git仓库...${NC}"
    
    git init
    git add .
    git commit -m "🎉 初始化 ${project_name} 微服务项目

基于 MicroStack 脚手架创建

- ✅ FastAPI应用框架
- ✅ 配置管理
- ✅ 数据库集成
- ✅ API文档
- ✅ Docker支持"
    
    echo -e "${GREEN}✅ Git仓库初始化完成${NC}"
}

# 显示完成信息
show_completion() {
    local project_name=$1
    local port=$2
    
    echo ""
    echo -e "${GREEN}🎉 项目创建成功！${NC}"
    echo ""
    echo -e "${BLUE}项目信息:${NC}"
    echo -e "  📁 项目名称: ${project_name}"
    echo -e "  🌐 默认端口: ${port}"
    echo -e "  📂 项目路径: $(pwd)"
    echo ""
    echo -e "${YELLOW}下一步:${NC}"
    echo -e "  1. 进入项目目录: ${BLUE}cd ${project_name}${NC}"
    echo -e "  2. 安装依赖: ${BLUE}pip install -r requirements.txt${NC}"
    echo -e "  3. 启动服务: ${BLUE}./run.sh${NC}"
    echo -e "  4. 访问API文档: ${BLUE}http://localhost:${port}/docs${NC}"
    echo ""
    echo -e "${GREEN}🚀 祝你开发愉快！${NC}"
}

# 主函数
main() {
    # 检查参数
    if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        show_help
        exit 0
    fi
    
    PROJECT_NAME=$1
    shift
    
    # 验证项目名称
    if ! validate_project_name "$PROJECT_NAME"; then
        show_help
        exit 1
    fi
    
    # 默认值
    PORT=8080
    INIT_GIT=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port)
                PORT=$2
                shift 2
                ;;
            --git)
                INIT_GIT="yes"
                shift
                ;;
            *)
                echo -e "${RED}错误: 未知参数 '$1'${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 获取脚手架源目录
    SOURCE_DIR=$(dirname $(realpath $0))
    
    echo -e "${BLUE}MicroStack 项目初始化${NC}"
    echo -e "项目名称: ${GREEN}${PROJECT_NAME}${NC}"
    echo -e "端口号: ${GREEN}${PORT}${NC}"
    echo ""
    
    # 执行创建流程
    create_project_structure "$PROJECT_NAME" "$PORT"
    copy_core_files "$PROJECT_NAME" "$PORT" "$SOURCE_DIR"
    customize_config "$PROJECT_NAME" "$PORT"
    create_docs "$PROJECT_NAME" "$PORT"
    
    # 初始化Git（如果需要）
    if [ ! -z "$INIT_GIT" ]; then
        init_git "$PROJECT_NAME"
    fi
    
    # 返回上级目录并显示完成信息
    cd ..
    show_completion "$PROJECT_NAME" "$PORT"
}

# 执行主函数
main "$@"