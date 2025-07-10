# MicroStack 使用指南

## 🚀 快速开始

### 作为脚手架使用（推荐）

```bash
# 1. 克隆脚手架
git clone <your-microstack-repo>
cd MicroStack

# 2. 创建新的微服务项目
./init.sh my-service --port 8080 --git

# 3. 进入新项目
cd my-service

# 4. 安装依赖并运行
pip install -r requirements.txt
./run.sh --reload
```

### 直接使用模板

```bash
# 1. 进入MicroStack目录
cd MicroStack

# 2. 安装依赖
pip install -r requirements.txt

# 3. 运行服务
./run.sh --reload          # 开发模式
./run.sh --workers 4       # 生产模式
./run-docker.sh --build    # Docker模式
```

## 📁 项目结构说明

```
MicroStack/
├── app.py              # 🔥 主应用模板
├── run.sh              # 🔥 本地运行脚本
├── run-docker.sh       # 🔥 Docker运行脚本
├── init.sh             # 🔥 脚手架初始化脚本
├── config/             # 🔥 配置文件
├── shared/             # 🔥 共享组件
├── requirements.txt    # 🔥 Python依赖
└── README.md           # 📄 项目说明
```

**🔥 = 核心文件**

## 🎯 三种使用方式

### 方式1: 脚手架创建新项目（推荐）
```bash
./init.sh my-awesome-api --port 8090 --git
cd my-awesome-api
./run.sh --reload
```

### 方式2: 直接使用模板开发
```bash
./run.sh --port 8080 --reload
# 然后修改 app.py 添加你的业务逻辑
```

### 方式3: Docker开发
```bash
./run-docker.sh --build --port 8080
```

## 🔌 端口管理

脚本会自动处理端口冲突：
- 如果指定端口被占用，自动递增查找可用端口
- 最多尝试50个端口
- 清晰的状态提示

```bash
# 端口8080被占用时，会自动切换到8081
./run.sh --port 8080
# 输出: ⚠️ 端口 8080 已被占用 → 💡 已自动切换到端口 8081
```

## 📚 API文档

服务启动后访问：
- **Swagger UI**: http://localhost:端口/docs  
- **ReDoc**: http://localhost:端口/redoc
- **健康检查**: http://localhost:端口/health

## 🛠️ 开发提示

1. **修改配置**: 编辑 `config/config.yaml`
2. **添加API**: 在 `app.py` 中添加FastAPI路由
3. **数据库**: 使用 `shared/database/mongodb.py`
4. **日志**: 使用 `shared/utils/logger.py`
5. **查看文档**: 阅读 `README.md` 和 `USAGE.md`

## 🎉 开始开发

选择你喜欢的方式开始：
- 想要独立项目 → 使用 `./init.sh`
- 想要快速原型 → 直接修改 `app.py`
- 想要容器化 → 使用 `./run-docker.sh`