# Nginx 部署指南

本文档说明如何将定价服务的 Nginx 配置部署到生产环境。

## 前置要求

1. **Nginx 已安装**: 确保系统已安装 Nginx（建议版本 1.18+）
2. **OpenResty**: 由于使用 Lua，需要安装 OpenResty 或 Nginx with LuaJIT
3. **Lua 模块**: 确保所需的 Lua 模块已安装

## 安装 OpenResty

### Ubuntu/Debian

```bash
# 添加 OpenResty 仓库
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y "ppa:openresty/ppa"
sudo apt-get update

# 安装 OpenResty
sudo apt-get install -y openresty
```

### CentOS/RHEL

```bash
# 添加 OpenResty 仓库
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo

# 安装 OpenResty
sudo yum install -y openresty
```

## 配置步骤

### 1. 复制配置文件

```bash
# 复制配置文件到 Nginx 配置目录
sudo cp pricing_nginx.conf /etc/nginx/conf.d/
sudo cp pricing_routes.conf /etc/nginx/conf.d/
```

### 2. 修改主配置文件

编辑 `/etc/nginx/nginx.conf`，在 `http` 块中添加：

```nginx
http {
    # 包含定价服务配置
    include /etc/nginx/conf.d/pricing_nginx.conf;
    
    server {
        # 设置 Lua 源代码路径
        set $lua_src_path /path/to/pricing-service-demo;
        
        # 包含路由配置
        include /etc/nginx/conf.d/pricing_routes.conf;
    }
}
```

### 3. 设置 Lua 包路径

在 `http` 块中添加：

```nginx
lua_package_path "/path/to/pricing-service-demo/?.lua;/path/to/pricing-service-demo/?.lua;;";
```

### 4. 验证配置

```bash
# 检查配置语法
sudo nginx -t

# 如果配置正确，应该看到：
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### 5. 重新加载配置

```bash
# 重新加载 Nginx（不中断服务）
sudo nginx -s reload

# 或者重启 Nginx
sudo systemctl restart nginx
```

## 测试部署

### 健康检查

```bash
curl http://localhost/api/v3/pricing/health
```

预期响应：
```json
{"status":"ok","service":"pricing"}
```

### 预览定价接口

```bash
curl -X POST http://localhost/api/v3/pricing/preview_pricing \
  -H "Content-Type: application/json" \
  -d '{
    "target_id": "user123",
    "target_type": 1,
    "purchasing_entity_ids": [
      {"entity_id": "offer1", "quantity": 1}
    ]
  }'
```

## 安全配置

### 1. 启用 HTTPS

```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}
```

### 2. 添加认证

在生产环境中，建议添加认证中间件：

```nginx
location = /api/v3/pricing/preview_pricing {
    # 认证检查
    access_by_lua_block {
        -- 验证 JWT token 或其他认证方式
    }
    
    content_by_lua_file $lua_src_path/pricing/routes/PreviewPricing.lua;
}
```

### 3. IP 白名单（可选）

```nginx
location = /api/v3/pricing/preview_pricing {
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    content_by_lua_file $lua_src_path/pricing/routes/PreviewPricing.lua;
}
```

## 性能优化

### 1. 调整共享内存大小

根据实际负载调整 `lua_shared_dict` 大小：

```nginx
lua_shared_dict pricing_cache 50m;  # 增加缓存大小
```

### 2. 调整限流参数

根据实际流量调整限流配置：

```nginx
limit_req_zone $binary_remote_addr zone=pricing:50m rate=100r/s;
```

### 3. 启用 Gzip 压缩

```nginx
gzip on;
gzip_types application/json text/plain;
gzip_min_length 1000;
```

## 监控和日志

### 1. 访问日志

确保访问日志已配置：

```nginx
access_log /var/log/nginx/pricing-access.log main;
```

### 2. 错误日志

```nginx
error_log /var/log/nginx/pricing-error.log warn;
```

### 3. 监控指标

可以集成 Prometheus 或其他监控系统收集指标。

## 故障排查

### 检查 Nginx 状态

```bash
sudo systemctl status nginx
```

### 查看错误日志

```bash
sudo tail -f /var/log/nginx/error.log
```

### 检查 Lua 模块

```bash
# 测试 Lua 模块加载
lua -e "require 'pricing.PricingEngine'"
```

### 常见问题

1. **502 Bad Gateway**: 检查 Lua 模块路径和依赖
2. **404 Not Found**: 检查路由配置和文件路径
3. **500 Internal Server Error**: 查看错误日志，检查 Lua 代码

## 回滚步骤

如果部署出现问题，可以快速回滚：

```bash
# 恢复之前的配置
sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf

# 重新加载
sudo nginx -s reload
```

## 注意事项

- 这是一个**简化版配置**，实际生产环境需要更多安全措施
- 确保所有路径都是绝对路径
- 定期备份配置文件
- 在生产环境部署前，先在测试环境验证
