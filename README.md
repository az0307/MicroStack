# MicroStack

> 🚀 一个现代化的微服务架构快速启动模板

MicroStack 是一个完整的微服务架构模板，旨在帮助开发者快速搭建生产就绪的微服务应用。它提供了标准化的项目结构、配置管理、API网关、服务间通信等核心组件。

## ✨ 特性

- 🏗️ **模块化架构** - 清晰的微服务结构和组件分离
- 🐳 **Docker化部署** - 完整的容器化解决方案
- 🌐 **API网关** - 统一的服务入口和路由管理
- 📊 **服务监控** - 内置健康检查和状态监控
- 🔧 **配置管理** - 灵活的环境配置和参数管理
- 📚 **数据库抽象** - 支持MongoDB等多种数据库
- 🔄 **消息队列** - Redis集成用于异步处理
- 📖 **完整文档** - 详细的使用说明和示例代码

## 🏛️ 架构概览

```
MicroStack/
├── apps/                    # 微服务应用
│   ├── api-gateway/        # API网关 (端口: 8080)
│   ├── user-service/       # 用户服务 (端口: 8081)
│   └── example-service/    # 示例服务 (端口: 8082)
├── shared/                 # 共享组件
│   ├── config/            # 配置管理
│   ├── database/          # 数据库抽象层
│   ├── middleware/        # 中间件
│   └── utils/             # 工具类
├── infrastructure/         # 基础设施
│   ├── docker/            # Docker配置
│   ├── k8s/              # Kubernetes配置
│   └── monitoring/        # 监控配置
├── scripts/               # 部署脚本
├── examples/              # 使用示例
└── docs/                  # 项目文档
```

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 4GB 可用内存

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd MicroStack
```

### 2. 构建基础镜像

```bash
./build.sh
```

### 3. 启动开发环境

```bash
./dev.sh
```

### 4. 验证部署

访问以下地址验证服务是否正常运行：

- **API网关**: http://localhost:8080/health
- **用户服务**: http://localhost:8081/health  
- **示例服务**: http://localhost:8082/health

## 📡 API 使用

### 通过API网关访问服务

```bash
# 获取用户列表
curl http://localhost:8080/api/user/users

# 创建新用户
curl -X POST http://localhost:8080/api/user/users \
  -H "Content-Type: application/json" \
  -d '{"name": "张三", "email": "zhangsan@example.com"}'

# 访问示例服务
curl http://localhost:8080/api/example/hello
```

### 直接访问微服务

```bash
# 直接访问用户服务
curl http://localhost:8081/api/users

# 直接访问示例服务
curl http://localhost:8082/api/status
```

## 🛠️ 开发指南

### 添加新的微服务

1. 在 `apps/` 目录下创建新服务目录
2. 创建 `app.py` 作为服务入口
3. 在 `docker-compose.yml` 中添加服务配置
4. 更新API网关的服务注册表

### 配置管理

修改 `shared/config/config.yaml` 来调整服务配置：

```yaml
app:
  name: "my-service"
  port: 8080
  debug: false

database:
  mongodb:
    host: "${MONGO_HOST:localhost}"
    port: "${MONGO_PORT:27017}"
    database: "${MONGO_DB:myapp}"
```

### 环境变量

支持通过环境变量覆盖配置：

```bash
export MONGO_HOST=my-mongo-server
export REDIS_HOST=my-redis-server
./dev.sh
```

## 📊 监控和日志

### 健康检查

每个服务都提供健康检查端点：

```bash
curl http://localhost:8080/health
```

### 日志查看

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f user-service
```

## 🚢 部署

### 开发环境

```bash
./scripts/deploy.sh dev
```

### 生产环境

```bash
./scripts/deploy.sh prod
```

## 📝 示例代码

查看 `examples/` 目录获取完整的使用示例：

```bash
# 运行API使用示例
python examples/api_usage.py
```

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🆘 支持

如果你在使用过程中遇到问题：

1. 查看 [文档](docs/)
2. 搜索 [Issues](../../issues)
3. 创建新的 Issue

## 🔗 相关链接

- [Docker 文档](https://docs.docker.com/)
- [Flask 文档](https://flask.palletsprojects.com/)
- [MongoDB 文档](https://docs.mongodb.com/)
- [Redis 文档](https://redis.io/documentation)

---

**MicroStack** - 让微服务开发更简单 🚀