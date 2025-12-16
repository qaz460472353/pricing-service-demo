# Pricing Service Demo

这是一个简化的定价服务演示项目，展示了微服务架构中的定价计算核心功能。

## 项目概述

Pricing Service 是一个用于计算商品和服务价格的微服务。它支持多种定价场景，包括：
- 基础价格计算
- 折扣计算
- 费用计算
- 税费计算
- 总价汇总

## 架构设计

### 核心组件

1. **PricingEngine** - 定价引擎，协调整个定价计算流程
2. **Executor** - 执行器，按阶段执行定价计算
3. **PricingInternalData** - 内部数据结构，存储计算过程中的所有数据
4. **Phases** - 计算阶段配置，定义各个计算阶段的执行顺序
5. **Calculators** - 各种计算器（基础价格、折扣、费用、税费）
6. **Aggregators** - 价格聚合器，汇总各个组件的价格

### 计算流程

```
Request → PricingEngine → PricingInternalData → Executor → Phases → Calculators → Aggregators → Output
```

### 计算阶段

1. **LIST_PRICE_PHASE** - 计算基础价格
2. **DISCOUNT_PHASE** - 计算折扣
3. **FEE_PHASE** - 计算费用
4. **TAX_PHASE** - 计算税费
5. **TOTAL_PHASE** - 汇总总价

## 目录结构

```
pricing-service-demo/
├── PricingEngine.lua          # 核心定价引擎
├── Executor.lua                # 执行器
├── routes/                     # API 路由
│   ├── PreviewPricing.lua      # 预览定价接口
│   └── validators/            # 请求验证器
├── calculator/                # 计算器模块
│   ├── BasePriceCalculator.lua
│   ├── DiscountCalculator.lua
│   ├── FeeCalculator.lua
│   ├── TaxCalculator.lua
│   └── PriceAggregator.lua
├── struct/                     # 数据结构
│   ├── PricingInternalData.lua
│   ├── Phases.lua
│   └── output/
│       └── Adapter.lua
├── utils/                      # 工具类
│   ├── Enums.lua
│   └── RouteHelper.lua
└── resources/                  # 资源文件
    ├── nginx/                  # Nginx 配置
    │   ├── pricing_nginx.conf  # 主配置文件
    │   ├── pricing_routes.conf # 路由配置
    │   ├── nginx.example.conf  # 集成示例
    │   └── README.md           # 配置说明
    └── spec/                   # 单元测试
        ├── test_setup.lua      # 测试环境设置
        ├── PricingEngine_spec.lua
        ├── Executor_spec.lua
        ├── calculator/         # 计算器测试
        ├── struct/             # 数据结构测试
        └── README.md           # 测试说明文档
```

## 设计模式

### 1. 阶段化处理模式

定价计算被分解为多个独立的阶段，每个阶段负责特定的计算任务。这种设计使得：
- 易于扩展新的计算阶段
- 便于测试和维护
- 支持并行处理

### 2. 内部数据结构模式

使用统一的内部数据结构（PricingInternalData）来存储计算过程中的所有数据，使得：
- 不同输入格式可以转换为统一格式
- 不同输出格式可以从统一格式转换
- 便于在不同阶段之间传递数据

### 3. 适配器模式

使用适配器模式将内部数据结构转换为不同的输出格式，支持：
- 多种 API 接口格式
- 不同运营商的需求
- 灵活的响应格式

## 使用示例

### 预览定价

```lua
local pricing_engine = require "pricing.PricingEngine"

local calc_context = {
    operator_name = "demo_operator",
    target_id = "user123",
    target_type = 1,
    calculation_timestamp = os.time(),
    purchasing_entity_ids = {
        { entity_id = "offer1", quantity = 1 }
    }
}

local result, err = pricing_engine.preview_pricing("demo_operator", calc_context)
if err then
    print("Error: ", err)
else
    print("Total price: ", result.total_price.amount)
end
```

## 技术特点

1. **模块化设计** - 每个组件职责单一，易于维护
2. **可扩展性** - 易于添加新的计算阶段和计算器
3. **类型安全** - 使用 checks 模块进行参数验证
4. **错误处理** - 完善的错误处理和日志记录
5. **代码规范** - 遵循 Lua 编码标准和最佳实践
6. **测试覆盖** - 包含完整的单元测试，展示规范的测试编写方式

## 单元测试

项目包含完整的单元测试，展示了规范的测试编写方式：

### 测试结构

- **测试文件命名**: 以 `_spec.lua` 结尾
- **测试组织**: 使用 `describe` 和 `it` 块组织测试
- **测试隔离**: 使用 `before_each` 和 `after_each` 进行测试隔离
- **AAA 模式**: 遵循 Arrange-Act-Assert 模式

### 测试覆盖

- ✅ Calculator 模块测试（BasePriceCalculator, DiscountCalculator, TaxCalculator, PriceAggregator）
- ✅ Core 模块测试（PricingEngine, Executor）
- ✅ Struct 模块测试（PricingInternalData, OutputAdapter）

### 运行测试

```bash
# 运行所有测试
./githooks/docker-run-busted resources/spec

# 运行特定测试文件
./githooks/docker-run-busted resources/spec/calculator/BasePriceCalculator_spec.lua
```

详细的测试说明请参考 [resources/spec/README.md](resources/spec/README.md)

## 注意事项

这是一个简化版的演示项目，实际生产环境中的实现会更加复杂，包括：
- 与外部服务（目录服务、用户服务、税务服务）的集成
- 复杂的业务规则处理
- 缓存和性能优化
- 异步处理支持
- 完整的错误处理和重试机制

## 许可证

本项目仅用于演示目的。
