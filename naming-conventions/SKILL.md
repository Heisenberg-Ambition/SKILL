---
name: naming-conventions
description: >
  Define and apply consistent names for files, types, variables, functions,
  constants, tests, and modules across C++, Python, shell, PowerShell,
  JavaScript/TypeScript, C#, Java, Go, and Rust. Use when naming new code,
  reviewing identifiers, or renaming symbols and files. Project conventions and
  the C++ reference profile take precedence over generic rules.
version: 1.0.0
tags: [naming, conventions, cpp, python, powershell, shell, typescript, csharp, java, go, rust]
---

# 跨语言命名规则

## 目标与权威顺序

本文件统一约束文件, 类型, 变量, 函数, 常量, 测试和模块的命名. 目标是让名字可读, 可搜索, 可维护, 并且在同一种语言内保持一致.

优先级:

1. 项目已公开的命名约定和公共 API 契约.
2. 本文件的语言专属规则.
3. 本文件的跨语言通用原则.
4. 个人偏好.

C++ 部分以项目参考头文件 `ApplicationLifecycle.h` 为准. 该风格与 Google C++ Style 的命名部分存在有意差异: 文件使用 `PascalCase`, 方法和函数使用 `snake_case`, 枚举值使用 `PascalCase` 而不是 `k` 前缀.

修改已有文件时优先保持局部一致, 不把无关代码批量改名. 新模块和新文件使用本规则. 引用标准库, 系统 API 或第三方库的名称时保留原始拼写.

## 跨语言通用原则

### 1. 名字表达语义, 不表达实现

名字回答"这是什么"或"做什么", 不描述类型, 存储方式或临时实现.

- 好: `active_users`, `retry_count`, `parse_request`.
- 差: `user_list_vector`, `int_count`, `do_stuff`.

### 2. 同一概念只用一个词

同一业务概念在文件, 类型, 函数, 参数和日志中使用同一个词. 不要同时使用 `user`, `account`, `customer` 表示同一个实体. 不要同时使用 `fetch`, `get`, `retrieve` 表示同一个操作.

项目应维护一个简短领域词表. 新名字从词表选词, 不临时发明同义词.

### 3. 作用域决定名字长度

- 1 到 3 行的循环或 lambda 可以用 `i`, `j`, `x`, `it`.
- 函数参数使用可读短名.
- 公共 API, 跨模块接口和持久化字段使用完整描述名.
- 名字离声明处越远, 越需要描述性.

不要为了缩短而删除单词内部字母. `customer_id` 可以, `cstmr_id` 不可以.

### 4. 布尔值使用肯定语义

布尔变量和谓词使用 `is`, `has`, `can`, `should`, `needs` 等前缀, 避免双重否定.

- 好: `is_ready`, `has_children`, `can_retry`, `should_stop`.
- 差: `not_ready`, `disable_cache` 表示布尔值, `is_not_empty`.

参数需要表达关闭状态时使用正向名字加布尔值, 例如 `cache_enabled = false`, 不用 `no_cache = true`.

### 5. 名词和动词分工

- 类型, 变量, 字段, 属性使用名词或名词短语.
- 函数和方法使用动词或动词短语.
- 简单访问器可以省略 `get`, 直接使用名词: `state()`, `name`, `size`.
- 谓词使用 `is_`, `has_`, `can_`, `should_` 或对应驼峰形式.
- 事件处理器使用 `handle_` / `handleX`; 事件回调用 `on_` / `onX`.

语言已有强制前缀时服从语言, 例如 C# 接口的 `I` 前缀和 PowerShell 的 `Verb-Noun`.

### 6. 单复数必须表达结构

- 标量使用单数: `user`, `file_count`.
- 集合使用复数: `users`, `failed_items`.
- 映射表达键和值: `users_by_id` / `usersById`.
- 索引表达位置: `user_index`.
- 避免 `user_list` 这类只描述容器的后缀, 除非容器类型本身是领域概念.

### 7. 禁止编码类型和实现细节

不使用匈牙利命名法, 不把类型写进名字.

- 禁止: `str_name`, `i_count`, `p_object`, `arr_items`, `b_is_ready`.
- 使用: `name`, `count`, `object`, `items`, `is_ready`.

C# 的 `I` 接口前缀, Python 的 `_` 可见性约定和 C++ 的成员尾随 `_` 是语言惯例, 不属于匈牙利命名.

### 8. 单位写进名字

数值带单位时必须写单位, 避免含义不明的 `timeout`, `size`, `delay`.

- `timeout_ms`, `size_bytes`, `delay_seconds`, `angle_degrees`.
- 同一项目统一基本单位. 不混用秒和毫秒.
- 时间点用 `_at`, 时长用 `_duration` 或明确单位.
- 百分比用 `_percent` 或 `_ratio`, 不混用.

### 9. 缩写必须可解释

只使用广泛理解的缩写: `id`, `url`, `http`, `https`, `api`, `json`, `xml`, `html`, `uuid`, `cpu`, `io`, `dns`.

- 不用团队内部才知道的缩写.
- 不创造缩写.
- 同一缩写在同一语言中保持固定大小写.
- 语言规则冲突时服从语言, 例如 Go 的 `URL` / `url` 和 C# 的 `Http` / `IO`.

### 10. 避免空泛词

以下词单独出现时通常没有信息量:

`data`, `info`, `manager`, `helper`, `util`, `utils`, `common`, `misc`, `base`, `core`, `impl`, `object`, `thing`, `tmp`, `temp`, `foo`, `bar`.

可以使用, 但必须加限定语并表达真实职责, 例如 `request_parser`, 不用 `helper`; `user_repository`, 不用 `manager`.

### 11. 不靠大小写区分名字

外部可见 API 不允许只靠大小写区分两个名字. PowerShell, Windows 文件系统, C# 和部分工具链可能大小写不敏感. 禁止 `userId` 和 `userID` 同时存在.

### 12. 文件与主职责一致

文件名表达主要类型或主要职责, 不使用 `utils`, `helpers`, `misc`, `stuff` 作为唯一名称.

- 文件名使用 ASCII, 不使用空格和不符合语言约定的标点.
- 一个文件有主类型时, 文件名与主类型一致.
- 测试文件使用语言标准测试后缀.
- 文件名不写作者, 日期, 版本号, `new`, `old`, `final`, `copy`.
- 改名文件时同步修改导入, 构建脚本, 文档和测试.

### 13. 测试名描述行为

测试名描述被测场景和预期结果, 不描述实现细节.

- 好: `rejects_expired_token`, `ApplicationLifecycleTests.Stop_WhenStartFailed_CleansUp`.
- 差: `test1`, `test_stop`, `works`.

### 14. 公共名称优先保持兼容

已发布的公共 API 不因风格偏好直接改名. 需要改名时先提供兼容别名或弃用周期. 私有名称可以直接重构, 但仍要全仓库搜索引用.

### 15. 标识符使用 ASCII 英文

标识符使用 ASCII 英文, 不使用拼音, 全角字符, 空格或 emoji. 领域实体没有自然英文名时, 使用项目词表中的固定译名, 不在不同文件里分别音译.

### 16. 避开语言保留名称

不使用语言关键字, 内置函数, 标准库名称, 平台宏和自动变量作为项目标识符. 必须引用外部名称时保留原名, 不为了命名规则修改第三方 API.

## C++ 命名规则

参考头文件体现的项目风格:

- 文件: `ApplicationLifecycle.h`.
- 命名空间: `atlas::bootstrap`.
- 类型和接口: `ApplicationComponent`, `ApplicationLifecycle`.
- 枚举类型: `ApplicationState`; 枚举值: `Created`, `Running`, `StartFailed`.
- 方法和函数: `start`, `stop`, `state`, `failed_start_component`, `cleanup`.
- 参数和局部变量: `components`, `value`.
- 私有数据成员: `components_`, `entered_`, `state_`, `failed_start_`.

### C++ 类型与文件

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 普通头文件 | 词干 `PascalCase`, `.h` | `ApplicationLifecycle.h` |
| 源文件 | 词干与头文件一致, `.cc` 或项目统一扩展名 | `ApplicationLifecycle.cc` |
| 测试文件 | 主类型加 `Test` | `ApplicationLifecycleTest.cc` |
| class, struct, union | `PascalCase` | `ApplicationLifecycle` |
| enum class | `PascalCase` | `ApplicationState` |
| 枚举值 | `PascalCase`, 不加 `k` | `ApplicationState::Running` |
| using 别名 | `PascalCase` | `ComponentList` |
| 模板类型参数 | `PascalCase`, 常用 `T` | `ValueT` |
| concept | `PascalCase` | `Startable` |

一个头文件原则上对应一个主类型. 文件名与主类型一致. 项目统一使用 `.cc` 或 `.cpp` 时保持全项目一致, 不混用.

### C++ 函数, 变量和成员

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 自由函数 | `snake_case` | `create_application` |
| 成员函数 | `snake_case` | `failed_start_component` |
| 访问器 | 名词 `snake_case` | `state`, `name`, `size` |
| 修改器 | `set_` 加属性名 | `set_state`, `set_name` |
| 布尔谓词 | `is_` / `has_` / `can_` / `should_` | `is_running`, `has_components` |
| 局部变量 | `snake_case` | `failed_component` |
| 函数参数 | `snake_case` | `component_count` |
| 私有数据成员 | `snake_case` 加 `_` | `components_`, `state_` |
| public struct 字段 | `snake_case`, 不加 `_` | `user_name` |
| 全局常量 | `k` 加 `PascalCase` | `kMaxRetryCount` |
| 局部常量 | `k` 加 `PascalCase` | `kBufferSize` |
| 宏 | `UPPER_SNAKE_CASE`, 带项目前缀 | `ATLAS_MAX_COMPONENTS` |

补充约束:

- 接口不加 `I` 前缀. 使用 `ApplicationComponent`, 不用 `IApplicationComponent`.
- 不添加 `C` 类前缀, `m_` 成员前缀或类型前缀.
- 私有成员尾随 `_` 只用于成员, 不用于局部变量.
- 自由函数和成员函数都以动词开头, 访问器和谓词除外.
- 回调成员使用 `on_started_`; 回调参数使用 `on_started`.
- 异步 API 使用 `start_async` / `stop_async`, 不把线程实现写进名字.
- 工厂函数使用 `create_application` 或 `make_application`, 同一项目只选一种.
- 错误类型使用 `Error` 或 `Exception` 后缀, 同一项目只选一种.
- 类型中的缩写按单词处理: `HttpClient`; 函数和变量中的缩写全小写: `parse_http_request`, `http_request`.

示例签名:

```cpp
StartResult start() noexcept;
bool stop() noexcept;
ApplicationState state() const noexcept;
std::string_view failed_start_component() const noexcept;
void set_state(ApplicationState state);
bool is_running() const noexcept;
```

## Python 命名规则

依据 PEP 8.

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 包 | 短小写, 尽量不用下划线 | `atlas` |
| 模块/文件 | `snake_case.py` | `application_lifecycle.py` |
| 类 | `CapWords` | `ApplicationLifecycle` |
| 异常 | `CapWords` 加 `Error` | `StartFailedError` |
| 函数/方法 | `snake_case` | `start_application` |
| 变量/参数 | `snake_case` | `failed_component` |
| 模块常量 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 类型变量 | `CapWords`, 短名 | `T`, `UserT` |
| 内部名称 | 单个前导 `_` | `_cleanup` |
| 名称改写 | 双前导 `__`, 仅继承冲突时 | `__state` |
| 魔术方法 | 仅使用语言定义的双下划线 | `__init__` |
| 测试 | `test_<module>.py`, 函数 `test_<behavior>` | `test_rejects_expired_token` |

补充约束:

- 实例方法第一个参数固定 `self`; 类方法第一个参数固定 `cls`.
- 与关键字冲突时使用尾随下划线, 例如 `class_`.
- 不自定义 `__name__` 形式的魔术名称.
- 不用 `l`, `O`, `I` 作为单字符变量.
- 模块公开 API 用 `__all__` 明确.
- 协变和逆变 TypeVar 使用 `_co` / `_contra` 后缀.
- 包名避免无意义缩写.

## Shell 命名规则

依据 Google Shell Style Guide 和 Bash 通用实践.

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 脚本文件 | 小写 `snake_case.sh` | `application_lifecycle.sh` |
| 库文件 | 小写 `snake_case.sh`, 不可执行 | `string_utils.sh` |
| 函数 | `snake_case` | `start_application` |
| 局部变量 | `snake_case`, 必须 `local` | `local failed_component` |
| 普通全局变量 | `snake_case` | `config_path` |
| 常量/只读变量 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 环境变量 | `UPPER_SNAKE_CASE` | `ATLAS_CONFIG_PATH` |
| 私有函数 | 单个前导 `_` 或项目前缀 | `_cleanup` |
| 测试 | `snake_case_test.sh` | `application_lifecycle_test.sh` |

补充约束:

- 文件名和函数名不使用连字符, 避免与命令参数混淆.
- 函数括号与函数名之间不留空格: `start_application() {`.
- 函数内变量必须 `local`; 命令替换后先 `local var`, 再单独赋值以保留退出码.
- 常量在文件顶部声明, 使用 `readonly`; 导出变量使用 `export`.
- 含多个函数的脚本提供 `main()` 并在末尾调用 `main "$@"`.
- 不定义与系统命令同名的函数; 必须覆盖时加项目前缀.
- 变量引用加引号: `"${config_path}"`.
- 不使用 camelCase. Shell 生态以 `snake_case` 和 `UPPER_SNAKE_CASE` 为主.

## PowerShell 命名规则

依据 Microsoft approved verbs 和 PowerShell 社区通用风格.

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 函数/命令 | 已批准动词 + 单数名词, `PascalCase` | `Get-ApplicationState` |
| 模块函数 | `Verb-PrefixNoun` 避免冲突 | `Get-AtlasApplication` |
| 参数 | `PascalCase` | `$ComputerName`, `$ApplicationState` |
| 局部变量 | `camelCase` | `$failedComponent` |
| 全局/脚本变量 | `PascalCase` | `$Script:ApplicationRoot` |
| 常量/只读变量 | `PascalCase` | `$MaxRetryCount` |
| 类/枚举/属性 | `PascalCase` | `ApplicationState` |
| 脚本文件 | 实现单个命令时与命令同名 | `Get-DiskReport.ps1` |
| 模块文件 | `PascalCase.psm1` | `ApplicationLifecycle.psm1` |
| 测试 | Pester `*.Tests.ps1` | `ApplicationLifecycle.Tests.ps1` |

补充约束:

- 函数必须使用 `Get-Verb` 中的 approved verb, 不使用 `Delete`, `Fetch`, `Make` 等同义词替代 `Remove`, `Get`, `New`.
- 名词使用单数, 即使参数接受多个对象: `Get-Service`, 不是 `Get-Services`.
- 公共模块函数给名词加产品前缀, 例如 `Get-AtlasUser`.
- 参数名优先复用内置 cmdlet 约定, 例如 `Path`, `Name`, `ComputerName`, `Credential`.
- 局部变量可以 camelCase, 参数必须 PascalCase.
- PowerShell 变量不区分大小写, 禁止只靠大小写区分两个变量.
- 共享脚本禁用别名和位置参数调用, 使用完整命令名和命名参数.
- 私有函数仍使用 approved verb, 通过模块作用域隐藏, 不靠奇怪前缀绕过规则.
- 用 `Invoke-ScriptAnalyzer` 检查 `PSUseApprovedVerbs`, `PSUseSingularNouns`, `PSAvoidUsingCmdletAliases`.

## 其他语言规则

### JavaScript 与 TypeScript

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 文件 | 默认 `kebab-case`; React 组件可用 `PascalCase` | `application-lifecycle.ts`, `ApplicationLifecycle.tsx` |
| 类/接口/类型/枚举 | `UpperCamelCase` | `ApplicationLifecycle` |
| 函数/方法/变量/参数 | `lowerCamelCase` | `startApplication`, `failedComponent` |
| 全局常量 | `CONSTANT_CASE` | `MAX_RETRY_COUNT` |
| 枚举值 | `CONSTANT_CASE` | `ApplicationState.RUNNING` |
| 私有成员 | 使用 `private`, 不加 `_` | `private state` |
| 泛型参数 | `T` 或 `UpperCamelCase` | `T`, `ValueT` |
| 测试 | `*.test.ts` / `*.spec.ts` | `application-lifecycle.test.ts` |

补充约束:

- 接口不加 `I` 前缀, 不加 `Interface` 后缀.
- React 组件和 hooks 使用生态约定: 组件 `PascalCase`, hooks `useXxx`, 事件处理器 `handleXxx`, props 回调 `onXxx`.
- 不使用 `$` 前缀, 除非项目使用 Observable 约定.
- 文件名遵循项目既有风格. 新项目默认 kebab-case, 同一目录不混用 kebab-case, snake_case 和 PascalCase.
- 不使用 `#private` 字段名风格, 使用 TypeScript `private`.
- 未使用参数可用 `_` 前缀, 尾部未使用参数直接省略.

### C#

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 文件 | 每个文件一个主类型, `PascalCase.cs` | `ApplicationLifecycle.cs` |
| 命名空间 | `PascalCase` | `Atlas.Bootstrap` |
| 类/结构/记录/枚举 | `PascalCase` | `ApplicationLifecycle` |
| 接口 | `I` 加 `PascalCase` | `IApplicationComponent` |
| 方法/属性/事件 | `PascalCase` | `Start`, `FailedStartComponent` |
| 公共字段/常量 | `PascalCase` | `MaxRetryCount` |
| 私有实例字段 | `_camelCase` | `_failedStartComponent` |
| 参数/局部变量 | `camelCase` | `failedComponent` |
| 泛型参数 | `T` 或 `TDescription` | `TValue` |
| 异步方法 | 加 `Async` 后缀 | `StartAsync` |
| 异常/特性/事件参数 | 使用 `Exception`, `Attribute`, `EventArgs` 后缀 | `StartFailedException` |

补充约束:

- 公共 API 不使用下划线. 私有字段的 `_camelCase` 是项目惯例, 若现有项目统一使用 camelCase, 保持项目一致.
- 两个字母缩写全大写, 例如 `IOStream`; 超过两个字母按单词处理, 例如 `HttpClient`, `HtmlTag`.
- 不依赖大小写区分公共成员.
- 布尔属性使用 `Is`, `Has`, `Can` 前缀.
- 测试类使用 `<Type>Tests`, 测试方法描述行为和预期.

### Java

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 包 | 全小写反向域名 | `com.atlas.bootstrap` |
| 文件 | 与 public 类同名 | `ApplicationLifecycle.java` |
| 类/接口/枚举/记录 | `PascalCase` | `ApplicationLifecycle` |
| 方法/变量/参数 | `camelCase` | `startApplication`, `failedComponent` |
| 常量 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 枚举类型 | `PascalCase`; 枚举值 `UPPER_SNAKE_CASE` | `ApplicationState.RUNNING` |
| 泛型参数 | `T`, `K`, `V` 或 `UpperCamelCase` | `TValue` |
| 测试 | `<Type>Test.java` | `ApplicationLifecycleTest.java` |

补充约束:

- 接口不加 `I` 前缀.
- 变量不以 `_` 或 `$` 开头.
- 不使用匈牙利命名.
- 类名使用名词; 方法名使用动词.
- 布尔方法使用 `is`, `has`, `can` 前缀.

### Go

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| 包 | 小写单字, 不用下划线 | `bootstrap` |
| 文件 | 小写 `snake_case.go` | `application_lifecycle.go` |
| 测试文件 | `_test.go` 后缀 | `application_lifecycle_test.go` |
| 导出类型/函数/方法 | `PascalCase` | `ApplicationLifecycle`, `Start` |
| 未导出类型/函数/方法 | `mixedCaps` | `applicationLifecycle`, `start` |
| 变量/参数 | `mixedCaps`, 短作用域可短名 | `failedComponent`, `i` |
| 常量 | 按可见性使用 `PascalCase` / `mixedCaps` | `MaxRetryCount`, `maxRetryCount` |
| 接口 | 单方法接口常用方法名加 `er` | `Reader`, `Writer` |

补充约束:

- 首字母大小写决定导出性, 不要为了风格隐藏真正需要导出的符号.
- Initialism 保持统一大小写: `URL` / `url`, `HTTP` / `http`, `appID` 而不是 `appId`.
- Getter 不使用 `Get` 前缀, 字段 `owner` 的 getter 叫 `Owner()`.
- 方法接收者使用 1 到 2 个字母, 全类型一致, 不使用 `this`, `self`, `me`.
- 包名不使用 `util`, `common`, `misc`, `api`, `types`, `interfaces`.
- 错误字符串小写开头, 不加结尾标点; 错误变量常用 `err`.

### Rust

| 类别 | 规则 | 示例 |
| --- | --- | --- |
| crate | `snake_case` | `application_lifecycle` |
| 模块/文件 | `snake_case` | `application_lifecycle.rs` |
| 类型/trait/枚举 | `UpperCamelCase` | `ApplicationLifecycle` |
| 枚举变体 | `UpperCamelCase` | `ApplicationState::Running` |
| 函数/方法/变量 | `snake_case` | `start_application`, `failed_component` |
| 常量/静态变量 | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 泛型参数 | 简短 `UpperCamelCase` | `T`, `ValueT` |
| 生命周期 | 短小写 | `'a`, `'input` |
| 宏 | `snake_case!` | `application_state!` |
| 测试 | 模块内 `#[cfg(test)] mod tests` | `mod tests` |

补充约束:

- 类型级构造用 `UpperCamelCase`, 值级构造用 `snake_case`.
- 缩写按一个词处理: `Uuid`, 不是 `UUID`; 常量中仍全大写.
- Getter 不加 `get_` 前缀, 例如 `first()`.
- 转换方法使用 `as_`, `to_`, `into_` 表达成本或所有权.
- 迭代器方法使用 `iter`, `iter_mut`, `into_iter`.
- 错误类型使用动词-宾语-`Error` 顺序, 例如 `ParseAddressError`.

## 常见语义模式

| 语义 | 推荐命名 | 避免 |
| --- | --- | --- |
| 本地读取属性 | `get` 或直接名词访问器 | 对本地字段使用 `fetch` |
| 远程获取 | `fetch` | `get` 表示网络请求 |
| 从磁盘加载/反序列化 | `load` | `read` 表示整个加载流程 |
| 读取流 | `read` | `load` 表示逐块读取 |
| 创建对象 | `create` / `new` | `make` 与 `create` 混用 |
| 构造复杂对象 | `build` | 与 `create` 无差别混用 |
| 持久化 | `save` / `persist` | `store` 与 `save` 混用 |
| 修改已有对象 | `update` | `set` 表示整体更新 |
| 从集合移除 | `remove` | `delete` 表示仅从容器移除 |
| 销毁资源 | `delete` / `destroy` / `dispose` | `remove` 表示释放资源 |
| 生命周期开始/结束 | `start` / `stop` | `open` / `close` 表示生命周期 |
| 资源打开/关闭 | `open` / `close` | `start` / `stop` 表示文件句柄 |
| 范围 | `begin` 含首, `end` 不含尾 | `start` / `finish` 混用 |
| 成对值 | `source` / `target` | `from` / `to` 作为变量名 |
| 请求响应 | `request` / `response` | `req` / `resp` 用于公共 API |
| 期望实际 | `expected` / `actual` | `want` / `got` 用于测试库接口 |

`req`, `resp`, `ctx`, `cfg`, `err` 只在局部短作用域或语言社区固定习惯中使用. 公共 API 写完整词.

## 重命名流程

1. 判断名称是否属于公共 API, 协议字段, 序列化格式或外部契约.
2. 在代码, 测试, 文档, 配置, 脚本和构建文件中搜索旧名字.
3. 搜索字符串字面量, 反射, 序列化键, 模板和日志字段.
4. 使用 IDE 或语言工具做符号级重命名, 不用全局正则盲替换.
5. 文件改名用版本控制工具, 并同步修改 import, include, 构建和部署配置.
6. Windows 或大小写不敏感文件系统上做仅大小写改名时, 先改成临时名, 再改成目标名.
7. 公共 API 改名先提供别名或弃用周期, 不同步破坏下游.
8. 运行格式化, 编译, 静态检查和测试, 确认没有遗漏引用.
9. 不把重命名和逻辑修改混在同一个大规模提交中.

## 明确避免

- `data`, `info`, `manager`, `helper`, `util`, `common`, `misc` 单独作为名字.
- `temp`, `tmp`, `foo`, `bar`, `baz`, `test1`, `value2` 等占位名进入生产代码.
- `strName`, `iCount`, `pObject`, `arrItems` 等类型前缀.
- `not_ready`, `no_cache`, `disable_feature` 作为肯定布尔值.
- `get` 和 `fetch` 表示同一操作.
- 单数和复数混用表示同一集合.
- 只靠大小写区分两个名字.
- 在公共 API 使用无法解释的缩写.
- 文件名使用 `utils`, `helpers`, `misc`, `stuff`.
- 用名字掩盖实现, 例如 `fast_path`, `new_parser`, `v2_final`.
- 改名后保留无期限的旧别名.
- 跨语言强行统一大小写. 领域词一致, 大小写服从语言.

## 审查清单

- [ ] 名字表达业务语义, 不表达类型或临时实现.
- [ ] 同一概念全仓库使用同一个词.
- [ ] 布尔值使用肯定语义和 `is` / `has` / `can` / `should`.
- [ ] 集合是复数, 标量是单数, 映射名表达键值关系.
- [ ] 数值名称带单位.
- [ ] 缩写是公认缩写, 大小写符合语言规则.
- [ ] 公共 API 没有 `l`, `O`, `I` 这类易混淆单字符名.
- [ ] 没有只靠大小写区分的名字.
- [ ] 文件名与主类型或主职责一致.
- [ ] 测试名描述行为和预期.
- [ ] C++ 文件名, `snake_case` 方法与 `PascalCase` 枚举值符合 `ApplicationLifecycle.h` 参考风格.
- [ ] Python 使用 PEP 8 的 `snake_case` 和 `CapWords`.
- [ ] Shell 函数和局部变量使用 `snake_case`, 常量和环境变量使用 `UPPER_SNAKE_CASE`.
- [ ] PowerShell 函数使用 approved `Verb-Noun`, 参数使用 `PascalCase`.
- [ ] C# 接口使用 `I` 前缀, 私有字段使用 `_camelCase`.
- [ ] Go 的导出性由首字母正确表达, initialism 大小写一致.
- [ ] Rust 类型和值级命名区分 `UpperCamelCase` / `snake_case`.
- [ ] 公共名称改名有兼容方案.
- [ ] 全仓库搜索, 编译和测试通过.

## 参考来源

- Python PEP 8: https://peps.python.org/pep-0008/#naming-conventions
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html#naming-conventions
- Microsoft PowerShell approved verbs: https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands
- Microsoft PowerShell variable names: https://learn.microsoft.com/en-ie/training/modules/manage-variables-windows-powershell-scripts/3-create-variable-names
- PowerShell Practice and Style: https://poshcode.gitbooks.io/powershell-practice-and-style/Style-Guide/Code-Layout-and-Formatting.html
- Google TypeScript Style Guide: https://google.github.io/styleguide/tsguide.html#naming
- Microsoft C# naming guidelines: https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/naming-guidelines
- Microsoft .NET capitalization conventions: https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/capitalization-conventions
- Oracle Java naming conventions: https://www.oracle.com/java/technologies/javase/codeconventions-namingconventions.html
- Go Code Review Comments: https://go.dev/wiki/CodeReviewComments
- Go Effective Go names: https://go.dev/doc/effective_go#names
- Rust API Guidelines naming: https://rust-lang.github.io/api-guidelines/naming.html
