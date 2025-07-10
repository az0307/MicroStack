from flask import Flask, request, jsonify
import sys
import os
from datetime import datetime

# 添加shared模块到路径
sys.path.append(os.path.join(os.path.dirname(__file__), '../../'))

from shared.config.config import config
from shared.utils.logger import setup_logger
from shared.database.mongodb import MongoDBConnection

app = Flask(__name__)

# 设置日志
logger = setup_logger("user-service", config.get('logging.level', 'INFO'))

# 数据库连接
db_config = config.get('database.mongodb', {})
db = MongoDBConnection(db_config) if db_config else None

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查端点"""
    return jsonify({
        "status": "healthy", 
        "service": "user-service",
        "timestamp": datetime.utcnow().isoformat()
    })

@app.route('/api/users', methods=['GET'])
def get_users():
    """获取用户列表"""
    try:
        if db:
            users_collection = db.database.users
            users = list(users_collection.find({}, {"_id": 0}))
        else:
            # 示例数据
            users = [
                {"id": 1, "name": "Alice", "email": "alice@example.com"},
                {"id": 2, "name": "Bob", "email": "bob@example.com"}
            ]
        
        logger.info(f"返回 {len(users)} 个用户")
        return jsonify({"users": users})
        
    except Exception as e:
        logger.error(f"获取用户失败: {e}")
        return jsonify({"error": "Internal server error"}), 500

@app.route('/api/users', methods=['POST'])
def create_user():
    """创建新用户"""
    try:
        data = request.get_json()
        
        if not data or 'name' not in data or 'email' not in data:
            return jsonify({"error": "Name and email are required"}), 400
        
        user = {
            "name": data['name'],
            "email": data['email'],
            "created_at": datetime.utcnow().isoformat()
        }
        
        if db:
            result = db.database.users.insert_one(user)
            user['id'] = str(result.inserted_id)
        else:
            user['id'] = 999  # 示例ID
        
        logger.info(f"创建用户: {user['name']}")
        return jsonify({"user": user}), 201
        
    except Exception as e:
        logger.error(f"创建用户失败: {e}")
        return jsonify({"error": "Internal server error"}), 500

@app.route('/api/users/<user_id>', methods=['GET'])
def get_user(user_id):
    """获取特定用户"""
    try:
        if db:
            user = db.database.users.find_one({"_id": user_id}, {"_id": 0})
        else:
            # 示例数据
            user = {"id": user_id, "name": "Sample User", "email": "user@example.com"}
        
        if not user:
            return jsonify({"error": "User not found"}), 404
            
        return jsonify({"user": user})
        
    except Exception as e:
        logger.error(f"获取用户失败: {e}")
        return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    port = config.get('services.user.port', 8081)
    host = config.get('app.host', '0.0.0.0')
    debug = config.get('app.debug', False)
    
    logger.info(f"用户服务启动在 {host}:{port}")
    app.run(host=host, port=port, debug=debug)