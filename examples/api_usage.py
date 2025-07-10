#!/usr/bin/env python3
"""
MicroStack API 使用示例

演示如何通过API网关访问各个微服务
"""

import requests
import json

# API网关地址
API_GATEWAY = "http://localhost:8080"

def test_health_checks():
    """测试所有服务的健康检查"""
    print("=== 健康检查测试 ===")
    
    services = [
        ("API网关", f"{API_GATEWAY}/health"),
        ("用户服务", "http://localhost:8081/health"),
        ("示例服务", "http://localhost:8082/health")
    ]
    
    for name, url in services:
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                print(f"✓ {name}: 健康")
            else:
                print(f"✗ {name}: 不健康 ({response.status_code})")
        except requests.RequestException as e:
            print(f"✗ {name}: 连接失败 ({e})")

def test_user_service():
    """测试用户服务"""
    print("\n=== 用户服务测试 ===")
    
    # 获取用户列表
    print("获取用户列表...")
    response = requests.get(f"{API_GATEWAY}/api/user/users")
    if response.status_code == 200:
        users = response.json()
        print(f"获取到 {len(users.get('users', []))} 个用户")
    else:
        print(f"获取用户列表失败: {response.status_code}")
    
    # 创建新用户
    print("创建新用户...")
    user_data = {
        "name": "测试用户",
        "email": "test@example.com"
    }
    response = requests.post(
        f"{API_GATEWAY}/api/user/users",
        json=user_data,
        headers={'Content-Type': 'application/json'}
    )
    if response.status_code == 201:
        print("✓ 用户创建成功")
    else:
        print(f"✗ 用户创建失败: {response.status_code}")

def test_example_service():
    """测试示例服务"""
    print("\n=== 示例服务测试 ===")
    
    # 测试hello端点
    response = requests.get(f"{API_GATEWAY}/api/example/hello")
    if response.status_code == 200:
        print("✓ Hello API 调用成功")
        print(f"  响应: {response.json()}")
    else:
        print(f"✗ Hello API 调用失败: {response.status_code}")
    
    # 测试状态端点
    response = requests.get(f"{API_GATEWAY}/api/example/status")
    if response.status_code == 200:
        print("✓ Status API 调用成功")
        print(f"  服务状态: {response.json()}")
    else:
        print(f"✗ Status API 调用失败: {response.status_code}")

def main():
    """主函数"""
    print("MicroStack API 使用示例")
    print("=" * 40)
    
    test_health_checks()
    test_user_service()
    test_example_service()
    
    print("\n测试完成!")

if __name__ == "__main__":
    main()