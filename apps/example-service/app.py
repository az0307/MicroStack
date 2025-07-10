from flask import Flask, jsonify
import sys
import os
from datetime import datetime

# 添加shared模块到路径
sys.path.append(os.path.join(os.path.dirname(__file__), '../../'))

from shared.config.config import config
from shared.utils.logger import setup_logger

app = Flask(__name__)

# 设置日志
logger = setup_logger("example-service", config.get('logging.level', 'INFO'))

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查端点"""
    return jsonify({
        "status": "healthy", 
        "service": "example-service",
        "timestamp": datetime.utcnow().isoformat()
    })

@app.route('/api/hello', methods=['GET'])
def hello():
    """示例API端点"""
    return jsonify({
        "message": "Hello from Example Service!",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "example-service"
    })

@app.route('/api/status', methods=['GET'])
def status():
    """服务状态端点"""
    return jsonify({
        "service": "example-service",
        "version": config.get('app.version', '1.0.0'),
        "status": "running",
        "uptime": "这里可以添加运行时间计算"
    })

if __name__ == '__main__':
    port = config.get('services.example.port', 8082)
    host = config.get('app.host', '0.0.0.0')
    debug = config.get('app.debug', False)
    
    logger.info(f"示例服务启动在 {host}:{port}")
    app.run(host=host, port=port, debug=debug)