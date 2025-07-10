from pymongo import MongoClient
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class MongoDBConnection:
    """MongoDB连接管理类"""
    
    def __init__(self, config: dict):
        self.config = config
        self._client: Optional[MongoClient] = None
        self._database = None
    
    def connect(self):
        """建立数据库连接"""
        try:
            connection_string = self._build_connection_string()
            self._client = MongoClient(connection_string)
            self._database = self._client[self.config.get('database', 'microstack')]
            
            # 测试连接
            self._client.admin.command('ping')
            logger.info("MongoDB连接成功")
            
        except Exception as e:
            logger.error(f"MongoDB连接失败: {e}")
            raise
    
    def _build_connection_string(self) -> str:
        """构建MongoDB连接字符串"""
        host = self.config.get('host', 'localhost')
        port = self.config.get('port', 27017)
        username = self.config.get('username')
        password = self.config.get('password')
        
        if username and password:
            return f"mongodb://{username}:{password}@{host}:{port}"
        else:
            return f"mongodb://{host}:{port}"
    
    @property
    def database(self):
        """获取数据库实例"""
        if self._database is None:
            self.connect()
        return self._database
    
    def close(self):
        """关闭数据库连接"""
        if self._client:
            self._client.close()
            logger.info("MongoDB连接已关闭")