# Pricing Service 单元测试

本目录包含定价服务的单元测试文件，展示了规范的测试编写方式。

## 测试结构

测试文件遵循以下命名规范：
- 测试文件以 `_spec.lua` 结尾
- 测试文件位置与源代码结构对应
- 例如：`calculator/BasePriceCalculator.lua` 的测试文件为 `calculator/BasePriceCalculator_spec.lua`

## 测试标准

### 1. 测试文件结构

每个测试文件应包含：

```lua
require "spec.test_setup"

local module_under_test = require "path.to.module"

describe("ModuleName", function()
    local snapshot

    before_each(function()
        snapshot = assert:snapshot()
    end)

    after_each(function()
        snapshot:revert()
    end)

    it("should perform specific action when condition", function()
        -- Arrange: 设置测试数据
        -- Act: 执行被测试的功能
        -- Assert: 验证结果
    end)
end)
```

### 2. 测试组织

- **describe 块**: 用于组织相关的测试用例
- **it 块**: 用于描述单个测试用例
- **before_each**: 在每个测试前执行设置
- **after_each**: 在每个测试后执行清理

### 3. 测试命名

测试用例名称应清晰描述测试场景：
- ✅ `should calculate base price successfully`
- ✅ `should return error for invalid input`
- ❌ `test1` 或 `test_calculation`

### 4. AAA 模式

每个测试应遵循 AAA 模式：
- **Arrange**: 准备测试数据和环境
- **Act**: 执行被测试的功能
- **Assert**: 验证结果是否符合预期

### 5. 测试覆盖

测试应覆盖：
- ✅ 正常流程（Happy Path）
- ✅ 边界条件（Boundary Conditions）
- ✅ 错误处理（Error Handling）
- ✅ 空值处理（Null/Empty Handling）

## 测试文件列表

### Calculator 测试
- `calculator/BasePriceCalculator_spec.lua` - 基础价格计算器测试
- `calculator/DiscountCalculator_spec.lua` - 折扣计算器测试
- `calculator/TaxCalculator_spec.lua` - 税费计算器测试
- `calculator/PriceAggregator_spec.lua` - 价格聚合器测试

### Core 测试
- `Executor_spec.lua` - 执行器测试
- `PricingEngine_spec.lua` - 定价引擎测试

### Struct 测试
- `struct/PricingInternalData_spec.lua` - 内部数据结构测试
- `struct/output/Adapter_spec.lua` - 输出适配器测试

## 运行测试

```bash
# 运行所有测试
./githooks/docker-run-busted resources/spec

# 运行特定测试文件
./githooks/docker-run-busted resources/spec/calculator/BasePriceCalculator_spec.lua
```

## 测试最佳实践

1. **独立性**: 每个测试应该独立，不依赖其他测试的执行顺序
2. **可重复性**: 测试应该可以重复运行并得到相同结果
3. **快速执行**: 单元测试应该快速执行
4. **清晰断言**: 使用清晰的断言，便于理解失败原因
5. **Mock 使用**: 适当使用 mock 隔离依赖

## 注意事项

- 本 demo 中的测试框架为简化版本
- 实际生产环境应使用完整的测试框架（如 busted）
- 测试应覆盖所有关键业务逻辑
- 保持测试代码的可读性和可维护性
