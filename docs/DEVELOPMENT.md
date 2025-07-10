# 开发指南

本文档详细介绍了如何在 MicroStack 基础上进行开发。

## 项目结构详解

### 目录说明

```
MicroStack/
├── apps/                    # 微服务应用目录
│   ├── api-gateway/        # API网关服务
│   │   └── app.py         # 网关主程序
│   ├── user-service/       # 用户管理服务
│   │   └── app.py         # 用户服务主程序
│   └── example-service/    # 示例服务
│       └── app.py         # 示例服务主程序
├── shared/                 # 共享组件库
│   ├── config/            # 配置管理
│   │   ├── config.py      # 配置加载器
│   │   └── config.yaml    # 主配置文件
│   ├── database/          # 数据库抽象层
│   │   └── mongodb.py     # MongoDB连接器
│   └── utils/             # 工具类
│       └── logger.py      # 日志工具
├── infrastructure/         # 基础设施配置
│   └── docker/            # Docker相关文件
│       ├── Dockerfile.base     # 基础镜像
│       └── Dockerfile.service  # 服务镜像模板
├── scripts/               # 脚本工具
│   └── deploy.sh         # 部署脚本
└── examples/              # 使用示例
    └── api_usage.py      # API调用示例
```

## 添加新的微服务

### 步骤1: 创建服务目录

```bash
mkdir apps/my-new-service
cd apps/my-new-service
```

### 步骤2: 创建服务主程序

创建 `app.py` 文件：

```python
from flask import Flask, jsonify
import sys
import os

# 添加shared模块到路径
sys.path.append(os.path.join(os.path.dirname(__file__), '../../'))

from shared.config.config import config
from shared.utils.logger import setup_logger

app = Flask(__name__)
logger = setup_logger("my-new-service")

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "my-new-service"})

@app.route('/api/my-endpoint', methods=['GET'])
def my_endpoint():
    return jsonify({"message": "Hello from my new service!"})

if __name__ == '__main__':
    port = config.get('services.my_new_service.port', 8083)
    app.run(host='0.0.0.0', port=port, debug=True)
```

### 步骤3: 更新 Docker Compose

在 `docker-compose.yml` 中添加新服务：

```yaml
  my-new-service:
    build:
      context: .
      dockerfile: infrastructure/docker/Dockerfile.service
      args:
        SERVICE_NAME: my-new-service
        BASE_IMAGE: microstack-base:latest
    container_name: microstack-my-new-service
    ports:
      - "8083:8083"
    environment:
      - CONFIG_PATH=/app/config/config.yaml
      - PORT=8083
    networks:
      - microstack-network
    restart: unless-stopped
```

### 步骤4: 更新API网关路由

在 `apps/api-gateway/app.py` 中添加新服务：

```python
SERVICES = {
    'user': 'http://user-service:8081',
    'example': 'http://example-service:8082',
    'my_new_service': 'http://my-new-service:8083'  # 新增
}
```

## 配置管理

### 环境变量

配置文件支持环境变量替换：

```yaml
database:
  mongodb:
    host: "${MONGO_HOST:localhost}"
    port: "${MONGO_PORT:27017}"
```

### 配置文件层级

1. 默认配置: `shared/config/config.yaml`
2. 环境变量覆盖
3. 代码中动态配置

### 使用配置

```python
from shared.config.config import config

# 获取简单配置
port = config.get('app.port', 8080)

# 获取复杂配置
db_config = config.database
redis_config = config.redis
```

## 数据库集成

### MongoDB

```python
from shared.database.mongodb import MongoDBConnection

# 初始化连接
db_config = config.get('database.mongodb', {})
db = MongoDBConnection(db_config)

# 使用数据库
collection = db.database.my_collection
result = collection.find_one({"_id": "123"})
```

### 添加其他数据库

在 `shared/database/` 目录下创建新的数据库连接器：

```python
# shared/database/mysql.py
import mysql.connector

class MySQLConnection:
    def __init__(self, config):
        self.config = config
        self._connection = None
    
    def connect(self):
        self._connection = mysql.connector.connect(**self.config)
    
    @property
    def connection(self):
        if self._connection is None:
            self.connect()
        return self._connection
```

## 日志管理

### 使用日志

```python
from shared.utils.logger import setup_logger

logger = setup_logger("my-service", "INFO")
logger.info("服务启动")
logger.error("发生错误", exc_info=True)
```

### 日志配置

在配置文件中调整日志设置：

```yaml
logging:
  level: "DEBUG"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
```

## 测试

### 单元测试

创建测试文件：

```python
# tests/test_user_service.py
import unittest
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '../'))

from apps.user_service.app import app

class TestUserService(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
    
    def test_health_check(self):
        response = self.app.get('/health')
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()
```

### 集成测试

```bash
# 启动测试环境
docker-compose -f docker-compose.test.yml up -d

# 运行测试
python -m pytest tests/

# 清理测试环境
docker-compose -f docker-compose.test.yml down
```

## 性能优化

### Docker优化

1. 使用多阶段构建减少镜像大小
2. 合理设置资源限制
3. 使用健康检查确保服务可用性

### 应用优化

1. 启用 Gunicorn 生产部署
2. 配置连接池
3. 实现缓存策略

```python
# 生产环境启动
gunicorn -w 4 -b 0.0.0.0:8080 app:app
```

## 监控和调试

### 健康检查

每个服务都应该实现健康检查：

```python
@app.route('/health', methods=['GET'])
def health_check():
    # 检查数据库连接
    # 检查外部依赖
    return jsonify({"status": "healthy"})
```

### 调试技巧

1. 使用 Docker logs 查看日志
2. 进入容器调试: `docker exec -it container_name bash`
3. 使用断点调试器

## 部署最佳实践

### 环境分离

```bash
# 开发环境
./scripts/deploy.sh dev

# 生产环境
./scripts/deploy.sh prod
```

### 配置管理

1. 使用环境变量管理敏感信息
2. 版本化配置文件
3. 实现配置热更新

### 安全考虑

1. 不要在代码中硬编码密码
2. 使用 HTTPS 通信
3. 实现认证和授权
4. 定期更新依赖