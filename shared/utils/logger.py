import logging
import sys
from typing import Optional

def setup_logger(
    name: str,
    level: str = "INFO",
    format_str: Optional[str] = None
) -> logging.Logger:
    """设置日志记录器"""
    
    if format_str is None:
        format_str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # 创建logger
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, level.upper(), logging.INFO))
    
    # 避免重复添加handler
    if not logger.handlers:
        # 创建console handler
        handler = logging.StreamHandler(sys.stdout)
        handler.setLevel(getattr(logging, level.upper(), logging.INFO))
        
        # 创建formatter
        formatter = logging.Formatter(format_str)
        handler.setFormatter(formatter)
        
        # 添加handler到logger
        logger.addHandler(handler)
    
    return logger