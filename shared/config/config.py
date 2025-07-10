import os
import yaml
from functools import lru_cache
from typing import Dict, Any

class Config:
    """通用配置管理类"""
    
    def __init__(self, config_path: str = None):
        self.config_path = config_path or os.getenv('CONFIG_PATH', './config/config.yaml')
        self._config = None
    
    @lru_cache(maxsize=1)
    def load_config(self) -> Dict[str, Any]:
        """加载配置文件"""
        if self._config is None:
            try:
                with open(self.config_path, "r", encoding='utf-8') as stream:
                    self._config = yaml.safe_load(stream)
            except FileNotFoundError:
                print(f"配置文件未找到: {self.config_path}")
                self._config = {}
        return self._config
    
    def get(self, key: str, default=None):
        """获取配置值，支持点号分隔的嵌套键"""
        config = self.load_config()
        keys = key.split('.')
        value = config
        
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default
    
    @property
    def database(self) -> Dict[str, Any]:
        """数据库配置"""
        return self.get('database', {})
    
    @property
    def redis(self) -> Dict[str, Any]:
        """Redis配置"""
        return self.get('redis', {})
    
    @property
    def app(self) -> Dict[str, Any]:
        """应用配置"""
        return self.get('app', {})

# 全局配置实例
config = Config()