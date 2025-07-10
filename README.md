# MicroStack

[English](#english) | [中文](#中文) | [日本語](#日本語)

---

<a name="english"></a>
## 🚀 MicroStack - Microservices Scaffold Template

MicroStack is a production-ready microservices scaffold template that helps developers quickly bootstrap new microservice projects. It provides a standardized project structure, configuration management, database integration, API documentation, and containerization support.

### ✨ Features

- 🏗️ **Fast Scaffolding** - Create new microservice projects in seconds
- ⚡ **FastAPI Framework** - Modern, fast web framework with automatic API documentation
- 🔧 **Configuration Management** - Flexible YAML-based configuration with environment variable support
- 📚 **Database Integration** - Built-in MongoDB support with easy extension for other databases
- 🐳 **Docker Ready** - Complete containerization with development and production modes
- 📖 **Auto Documentation** - Interactive API documentation with Swagger UI
- 🔄 **Hot Reload** - Development mode with automatic code reloading
- 📝 **Logging System** - Structured logging with configurable levels
- 🔌 **Smart Port Management** - Automatic port conflict resolution with auto-increment

### 🏛️ Project Structure

```
MicroStack/
├── app.py                  # Main application entry point
├── run.sh                  # Local development runner
├── run-docker.sh           # Docker runner
├── init.sh                 # Project scaffolding script
├── config/                 # Configuration files
│   └── config.yaml         # Main configuration
└── shared/                 # Shared components
    ├── config/            # Configuration management
    ├── database/          # Database abstractions
    └── utils/             # Utility functions
```

### 🚀 Quick Start

#### Option 1: Create New Project (Recommended)

```bash
# Clone the scaffold
git clone <microstack-repo-url>
cd MicroStack

# Create a new project
./init.sh my-awesome-service --port 8080 --git

# Navigate to your new project
cd my-awesome-service

# Install dependencies and run
pip install -r requirements.txt
./run.sh --reload
```

#### Option 2: Use Template Directly

```bash
# Use the template directly for quick prototyping
cd MicroStack
pip install -r requirements.txt
./run.sh --reload
```

#### Access Your Service

- **API Documentation**: http://localhost:port/docs
- **Health Check**: http://localhost:port/health
- **Service Status**: http://localhost:port/api/config

> 🔌 Port conflicts are automatically resolved by incrementing to next available port

### 🛠️ Development

#### Local Development

```bash
# Development mode with hot reload
./run.sh --reload

# Custom port
./run.sh --port 8090

# Production mode with multiple workers
./run.sh --workers 4
```

#### Docker Development

```bash
# Build and run with Docker
./run-docker.sh --build

# Run in background
./run-docker.sh --detach

# Custom configuration
./run-docker.sh --build --port 8090 --name my-service
```

### 📍 Template Features

The scaffold includes:

- **FastAPI Application** (`app.py`) - Modern async web framework
- **Configuration Management** (`shared/config/`) - YAML-based with environment variables
- **Database Integration** (`shared/database/`) - MongoDB support with easy extension
- **Logging System** (`shared/utils/`) - Structured logging with configurable levels
- **Smart Port Management** - Automatic port conflict resolution
- **Docker Support** - Ready-to-use containerization

### 🔧 Configuration

Modify `config/config.yaml` to customize your service:

```yaml
app:
  name: "my-service"
  version: "1.0.0"
  port: 8080
  debug: false

database:
  mongodb:
    host: "${MONGO_HOST:localhost}"
    port: "${MONGO_PORT:27017}"
    database: "${MONGO_DB:myservice}"

logging:
  level: "INFO"
```

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<a name="中文"></a>
## 🚀 MicroStack - 微服务脚手架模板

MicroStack 是一个生产就绪的微服务脚手架模板，帮助开发者快速创建新的微服务项目。它提供了标准化的项目结构、配置管理、数据库集成、API文档和容器化支持。

### ✨ 特性

- 🏗️ **快速脚手架** - 几秒钟内创建新的微服务项目
- ⚡ **FastAPI框架** - 现代、快速的Web框架，自动生成API文档
- 🔧 **配置管理** - 基于YAML的灵活配置，支持环境变量
- 📚 **数据库集成** - 内置MongoDB支持，易于扩展其他数据库
- 🐳 **Docker就绪** - 完整的容器化支持，包含开发和生产模式
- 📖 **自动文档** - 带有Swagger UI的交互式API文档
- 🔄 **热重载** - 开发模式下自动代码重载
- 📝 **日志系统** - 结构化日志，可配置级别
- 🔌 **智能端口管理** - 自动端口冲突检测与递增分配

### 🏛️ 项目结构

```
MicroStack/
├── app.py                  # 主应用入口
├── run.sh                  # 本地开发运行脚本
├── run-docker.sh           # Docker运行脚本
├── init.sh                 # 项目脚手架脚本
├── config/                 # 配置文件
│   └── config.yaml         # 主配置文件
├── shared/                 # 共享组件
│   ├── config/            # 配置管理
│   ├── database/          # 数据库抽象
│   └── utils/             # 工具函数
├── apps/                  # 示例服务（供参考）
│   ├── api-gateway/       # API网关示例
│   ├── user-service/      # 用户服务示例
│   └── example-service/   # 基础服务示例
└── infrastructure/        # Docker和部署配置
```

### 🚀 快速开始

#### 方式1: 创建新项目（推荐）

```bash
# 克隆脚手架
git clone <microstack-repo-url>
cd MicroStack

# 创建新项目
./init.sh my-awesome-service --port 8080 --git

# 进入新项目
cd my-awesome-service

# 安装依赖并运行
pip install -r requirements.txt
./run.sh --reload
```

#### 方式2: 直接使用模板

```bash
# 直接使用模板进行快速原型开发
cd MicroStack
pip install -r requirements.txt
./run.sh --reload
```

#### 访问你的服务

- **API文档**: http://localhost:端口/docs
- **健康检查**: http://localhost:端口/health
- **服务状态**: http://localhost:端口/api/config

> 🔌 端口冲突会自动递增到下一个可用端口

### 🛠️ 开发

#### 本地开发

```bash
# 开发模式（热重载）
./run.sh --reload

# 自定义端口
./run.sh --port 8090

# 生产模式（多工作进程）
./run.sh --workers 4
```

#### Docker开发

```bash
# 构建并运行
./run-docker.sh --build

# 后台运行
./run-docker.sh --detach

# 自定义配置
./run-docker.sh --build --port 8090 --name my-service
```

### 📍 模板功能

脚手架包含：

- **FastAPI应用** (`app.py`) - 现代异步Web框架
- **配置管理** (`shared/config/`) - 基于YAML，支持环境变量
- **数据库集成** (`shared/database/`) - MongoDB支持，易于扩展
- **日志系统** (`shared/utils/`) - 结构化日志，可配置级别
- **智能端口管理** - 自动端口冲突解决
- **Docker支持** - 开箱即用的容器化

### 🔧 配置

修改 `config/config.yaml` 来自定义你的服务：

```yaml
app:
  name: "my-service"
  version: "1.0.0"
  port: 8080
  debug: false

database:
  mongodb:
    host: "${MONGO_HOST:localhost}"
    port: "${MONGO_PORT:27017}"
    database: "${MONGO_DB:myservice}"

logging:
  level: "INFO"
```

### 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

<a name="日本語"></a>
## 🚀 MicroStack - マイクロサービススキャフォールドテンプレート

MicroStackは、開発者が新しいマイクロサービスプロジェクトを迅速に作成できる、本番環境対応のマイクロサービススキャフォールドテンプレートです。標準化されたプロジェクト構造、設定管理、データベース統合、API文書化、コンテナ化サポートを提供します。

### ✨ 特徴

- 🏗️ **高速スキャフォールド** - 数秒で新しいマイクロサービスプロジェクトを作成
- ⚡ **FastAPIフレームワーク** - 自動API文書生成を備えたモダンで高速なWebフレームワーク
- 🔧 **設定管理** - 環境変数サポート付きの柔軟なYAMLベース設定
- 📚 **データベース統合** - 組み込みMongoDBサポート、他のデータベースへの拡張が容易
- 🐳 **Docker対応** - 開発・本番モードを含む完全なコンテナ化
- 📖 **自動文書化** - Swagger UIによるインタラクティブAPI文書
- 🔄 **ホットリロード** - 自動コードリロード付き開発モード
- 📝 **ログシステム** - 設定可能なレベルを持つ構造化ログ
- 🔌 **スマートポート管理** - 自動ポート競合解決とインクリメント割り当て

### 🏛️ プロジェクト構造

```
MicroStack/
├── app.py                  # メインアプリケーションエントリポイント
├── run.sh                  # ローカル開発ランナー
├── run-docker.sh           # Dockerランナー
├── init.sh                 # プロジェクトスキャフォールドスクリプト
├── config/                 # 設定ファイル
│   └── config.yaml         # メイン設定
├── shared/                 # 共有コンポーネント
│   ├── config/            # 設定管理
│   ├── database/          # データベース抽象化
│   └── utils/             # ユーティリティ関数
├── apps/                  # 参考用サンプルサービス
│   ├── api-gateway/       # APIゲートウェイサンプル
│   ├── user-service/      # ユーザーサービスサンプル
│   └── example-service/   # 基本サービステンプレート
└── infrastructure/        # DockerとデプロイメントConfig
```

### 🚀 クイックスタート

#### オプション1: 新プロジェクト作成（推奨）

```bash
# スキャフォールドをクローン
git clone <microstack-repo-url>
cd MicroStack

# 新しいプロジェクトを作成
./init.sh my-awesome-service --port 8080 --git

# 新しいプロジェクトに移動
cd my-awesome-service

# 依存関係インストールと実行
pip install -r requirements.txt
./run.sh --reload
```

#### オプション2: テンプレート直接使用

```bash
# クイックプロトタイピング用にテンプレートを直接使用
cd MicroStack
pip install -r requirements.txt
./run.sh --reload
```

#### サービスにアクセス

- **API文書**: http://localhost:ポート/docs
- **ヘルスチェック**: http://localhost:ポート/health
- **サービス状態**: http://localhost:ポート/api/config

> 🔌 ポート競合は自動的に解決され、次の利用可能ポートにインクリメントされます

### 🛠️ 開発

#### ローカル開発

```bash
# ホットリロード付き開発モード
./run.sh --reload

# カスタムポート
./run.sh --port 8090

# マルチワーカー本番モード
./run.sh --workers 4
```

#### Docker開発

```bash
# ビルドして実行
./run-docker.sh --build

# バックグラウンドで実行
./run-docker.sh --detach

# カスタム設定
./run-docker.sh --build --port 8090 --name my-service
```

### 📍 テンプレート機能

スキャフォールドに含まれるもの：

- **FastAPIアプリケーション** (`app.py`) - モダンな非Webフレームワーク
- **設定管理** (`shared/config/`) - YAMLベース、環境変数サポート
- **データベース統合** (`shared/database/`) - MongoDBサポート、拡張容易
- **ログシステム** (`shared/utils/`) - 構造化ログ、設定可能レベル
- **スマートポート管理** - 自動ポート競合解決
- **Dockerサポート** - すぐに使えるコンテナ化

### 🔧 設定

`config/config.yaml` を修正してサービスをカスタマイズ：

```yaml
app:
  name: "my-service"
  version: "1.0.0"
  port: 8080
  debug: false

database:
  mongodb:
    host: "${MONGO_HOST:localhost}"
    port: "${MONGO_PORT:27017}"
    database: "${MONGO_DB:myservice}"

logging:
  level: "INFO"
```

### 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています - 詳細は[LICENSE](LICENSE)ファイルをご覧ください。