#!/usr/bin/env python3
"""
MicroStack 微服务应用
这是基于 MicroStack 脚手架创建的微服务应用模板
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import os
import sys
from datetime import datetime

# 添加shared模块到路径
sys.path.append(os.path.dirname(__file__))

from shared.config.config import config
from shared.utils.logger import setup_logger
from shared.database.mongodb import MongoDBConnection

# 创建FastAPI应用
app = FastAPI(
    title=config.get('app.name', 'MicroStack Service'),
    description="基于 MicroStack 脚手架构建的微服务",
    version=config.get('app.version', '1.0.0'),
    docs_url="/docs",
    redoc_url="/redoc"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 设置日志
logger = setup_logger(
    config.get('app.name', 'microstack-service'), 
    config.get('logging.level', 'INFO')
)

# 数据库连接
db_config = config.get('database.mongodb', {})
db = MongoDBConnection(db_config) if db_config else None

# Pydantic模型
class HealthResponse(BaseModel):
    status: str
    service: str
    timestamp: str
    version: str

class ItemCreate(BaseModel):
    name: str
    description: Optional[str] = None
    value: Optional[float] = None

class ItemResponse(BaseModel):
    id: Optional[str] = None
    name: str
    description: Optional[str] = None
    value: Optional[float] = None
    created_at: Optional[str] = None

# 启动事件
@app.on_event("startup")
async def startup_event():
    """应用启动时执行"""
    logger.info(f"🚀 {config.get('app.name', 'MicroStack Service')} 服务启动")
    
    # 数据库连接测试
    if db:
        try:
            # 测试数据库连接
            db.database.command('ismaster')
            logger.info("✅ 数据库连接成功")
        except Exception as e:
            logger.warning(f"⚠️ 数据库连接失败: {e}")

# 关闭事件
@app.on_event("shutdown")
async def shutdown_event():
    """应用关闭时执行"""
    logger.info("🛑 服务正在关闭...")

@app.get("/", tags=["基础"])
async def root():
    """服务根路径"""
    return {
        "service": config.get('app.name', 'MicroStack Service'),
        "version": config.get('app.version', '1.0.0'),
        "docs": "/docs",
        "health": "/health"
    }

@app.get("/health", response_model=HealthResponse, tags=["健康检查"])
async def health_check():
    """健康检查端点"""
    return HealthResponse(
        status="healthy",
        service=config.get('app.name', 'microstack-service'),
        timestamp=datetime.utcnow().isoformat(),
        version=config.get('app.version', '1.0.0')
    )

@app.get("/api/items", response_model=List[ItemResponse], tags=["业务接口"])
async def get_items():
    """
    获取所有项目
    
    这是一个示例业务接口，展示如何使用数据库和日志
    """
    try:
        if db:
            # 从数据库获取数据
            items_collection = db.database.items
            items = list(items_collection.find({}, {"_id": 0}))
        else:
            # 示例数据
            items = [
                {
                    "id": "1",
                    "name": "示例项目1",
                    "description": "这是第一个示例项目",
                    "value": 100.0,
                    "created_at": "2024-01-01T10:00:00Z"
                },
                {
                    "id": "2", 
                    "name": "示例项目2",
                    "description": "这是第二个示例项目",
                    "value": 200.0,
                    "created_at": "2024-01-02T11:00:00Z"
                }
            ]
        
        logger.info(f"返回 {len(items)} 个项目")
        return items
        
    except Exception as e:
        logger.error(f"获取项目失败: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.post("/api/items", response_model=ItemResponse, status_code=201, tags=["业务接口"])
async def create_item(item: ItemCreate):
    """
    创建新项目
    
    - **name**: 项目名称（必填）
    - **description**: 项目描述
    - **value**: 项目值
    """
    try:
        item_dict = {
            "name": item.name,
            "description": item.description,
            "value": item.value,
            "created_at": datetime.utcnow().isoformat()
        }
        
        if db:
            # 保存到数据库
            result = db.database.items.insert_one(item_dict)
            item_dict['id'] = str(result.inserted_id)
            item_dict.pop('_id', None)
        else:
            # 示例ID
            item_dict['id'] = "new_item_id"
        
        logger.info(f"创建项目: {item.name}")
        return ItemResponse(**item_dict)
        
    except Exception as e:
        logger.error(f"创建项目失败: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/api/items/{item_id}", response_model=ItemResponse, tags=["业务接口"])
async def get_item(item_id: str):
    """
    获取特定项目
    
    - **item_id**: 项目ID
    """
    try:
        if db:
            from bson import ObjectId
            try:
                item = db.database.items.find_one({"_id": ObjectId(item_id)}, {"_id": 0})
                if item:
                    item['id'] = item_id
            except:
                item = None
        else:
            # 示例数据
            if item_id in ["1", "2"]:
                item = {
                    "id": item_id,
                    "name": f"示例项目{item_id}",
                    "description": "示例描述",
                    "value": 100.0,
                    "created_at": datetime.utcnow().isoformat()
                }
            else:
                item = None
        
        if not item:
            raise HTTPException(status_code=404, detail="Item not found")
            
        return ItemResponse(**item)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"获取项目失败: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/api/config", tags=["系统接口"])
async def get_config():
    """
    获取服务配置信息
    
    返回当前服务的配置信息（不包含敏感数据）
    """
    return {
        "app": {
            "name": config.get('app.name', 'microstack-service'),
            "version": config.get('app.version', '1.0.0'),
            "debug": config.get('app.debug', False)
        },
        "database": {
            "type": config.get('database.type', 'none'),
            "connected": db is not None
        },
        "logging": {
            "level": config.get('logging.level', 'INFO')
        }
    }

def find_available_port(start_port, max_attempts=50):
    """查找可用端口"""
    import socket
    
    for i in range(max_attempts):
        current_port = start_port + i
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        
        try:
            result = sock.connect_ex(('localhost', current_port))
            if result != 0:  # 端口未被占用
                sock.close()
                return current_port
        except:
            pass
        finally:
            sock.close()
    
    return None

if __name__ == '__main__':
    import uvicorn
    
    original_port = int(os.getenv('PORT', config.get('app.port', 8080)))
    host = config.get('app.host', '0.0.0.0')
    debug = config.get('app.debug', False)
    
    # 查找可用端口
    port = find_available_port(original_port)
    if port is None:
        logger.error(f"无法找到可用端口 (尝试范围: {original_port}-{original_port + 49})")
        sys.exit(1)
    
    if port != original_port:
        logger.warning(f"原端口 {original_port} 被占用，已自动切换到端口 {port}")
    
    logger.info(f"服务启动在 {host}:{port}")
    logger.info(f"API文档地址: http://{host}:{port}/docs")
    
    try:
        uvicorn.run(
            "app:app" if __name__ == "__main__" else app,
            host=host,
            port=port,
            reload=debug
        )
    except OSError as e:
        if "Address already in use" in str(e):
            logger.error(f"端口 {port} 仍然被占用，请手动指定其他端口")
            logger.info("尝试使用: python app.py 或 ./run.sh --port <其他端口>")
        else:
            logger.error(f"启动失败: {e}")
        sys.exit(1)