from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import logging
import sys
import os

# 添加shared模块到路径
sys.path.append(os.path.join(os.path.dirname(__file__), '../../'))

from shared.config.config import config
from shared.utils.logger import setup_logger

app = Flask(__name__)
CORS(app)

# 设置日志
logger = setup_logger("api-gateway", config.get('logging.level', 'INFO'))

# 服务注册表 - 在生产环境中应使用服务发现
SERVICES = {
    'user': config.get('services.user.url', 'http://user-service:8081'),
    'example': config.get('services.example.url', 'http://example-service:8082')
}

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查端点"""
    return jsonify({"status": "healthy", "service": "api-gateway"})

@app.route('/api/<service>/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE'])
def proxy_request(service, path):
    """代理请求到对应的微服务"""
    
    if service not in SERVICES:
        return jsonify({"error": "Service not found"}), 404
    
    service_url = SERVICES[service]
    target_url = f"{service_url}/api/{path}"
    
    try:
        # 转发请求
        response = requests.request(
            method=request.method,
            url=target_url,
            json=request.get_json() if request.is_json else None,
            params=request.args,
            headers={k: v for k, v in request.headers if k.lower() != 'host'},
            timeout=30
        )
        
        logger.info(f"代理请求: {request.method} {target_url} -> {response.status_code}")
        
        return jsonify(response.json() if response.content else {}), response.status_code
        
    except requests.exceptions.RequestException as e:
        logger.error(f"请求代理失败: {e}")
        return jsonify({"error": "Service unavailable"}), 503

@app.route('/services', methods=['GET'])
def list_services():
    """列出所有可用服务"""
    return jsonify({"services": list(SERVICES.keys())})

if __name__ == '__main__':
    port = config.get('app.port', 8080)
    host = config.get('app.host', '0.0.0.0')
    debug = config.get('app.debug', False)
    
    logger.info(f"API网关启动在 {host}:{port}")
    app.run(host=host, port=port, debug=debug)