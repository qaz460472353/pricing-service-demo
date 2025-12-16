# Nginx 配置说明

本目录包含定价服务的 Nginx 配置文件。

## 文件说明

### pricing_nginx.conf
主配置文件，包含：
- Lua 共享内存字典配置（用于缓存）
- 限流配置

### pricing_routes.conf
路由配置文件，定义所有 API 端点：
- `/api/v3/pricing/preview_pricing` - 预览定价接口
- `/api/v3/pricing/health` - 健康检查接口
- `/api/v3/pricing/docs` - API 文档接口

## 配置说明

### 路由配置结构

每个路由配置包含以下部分：

1. **location 指令**: 定义 URL 路径
2. **limit_except**: 限制允许的 HTTP 方法
3. **limit_req**: 限流配置（防止滥用）
4. **CORS 头**: 跨域资源共享配置
5. **content_by_lua_file**: 执行 Lua 路由处理器

### 示例配置

```nginx
location = /api/v3/pricing/preview_pricing {
    limit_except OPTIONS POST {
        deny all;
    }
    
    limit_req zone=pricing burst=5 nodelay;
    
    content_by_lua_file $lua_src_path/pricing/routes/PreviewPricing.lua;
}
```

## 集成到主 Nginx 配置

在主 Nginx 配置文件中，需要包含这些配置：

```nginx
# 在 http 块中
http {
    # 包含共享内存配置
    include /path/to/pricing-service-demo/resources/nginx/pricing_nginx.conf;
    
    # 在 server 块中
    server {
        # 包含路由配置
        include /path/to/pricing-service-demo/resources/nginx/pricing_routes.conf;
    }
}
```

## 环境变量

配置中使用的变量：
- `$lua_src_path`: Lua 源代码路径（需要在主配置中定义）

## 安全考虑

1. **限流**: 使用 `limit_req` 防止 API 滥用
2. **方法限制**: 使用 `limit_except` 限制允许的 HTTP 方法
3. **CORS**: 根据需要配置跨域访问
4. **认证**: 在生产环境中应添加认证中间件

## 生产环境建议

在生产环境中，建议：

1. **更严格的限流**: 根据实际负载调整限流参数
2. **认证授权**: 添加 JWT 或 OAuth 认证
3. **SSL/TLS**: 启用 HTTPS
4. **日志记录**: 配置访问日志和错误日志
5. **监控**: 集成监控和告警系统
6. **缓存策略**: 优化共享内存字典大小

## 测试配置

可以使用以下命令测试配置：

```bash
# 检查配置语法
nginx -t

# 重新加载配置
nginx -s reload
```

## 注意事项

- 这是一个**简化版配置**，实际生产环境会更复杂
- 已移除敏感配置和复杂的业务逻辑
- 部分配置需要根据实际环境调整
- 确保 Lua 模块路径正确配置
