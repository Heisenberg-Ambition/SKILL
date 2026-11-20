---
name: comment-conventions
description: >
  Write, review, and place code comments across C, C++, Python, Lua, shell,
  PowerShell, JavaScript/TypeScript, C#, Java, Go, and Rust. Use when adding
  file headers, explanations, category markers, TODOs, or API documentation
  comments. Prefer a few high-value comments over line-by-line narration.
version: 1.0.0
tags: [comments, documentation, code-review, cpp, python, lua, powershell, shell]
---

# 跨语言注释规则

## 目标与优先顺序

注释只解决代码本身无法清楚表达的问题: 意图, 约束, 风险, 原因和后续动作.

优先级:

1. 项目已有注释风格和文档工具.
2. 本文件的标记, 位置和内容规则.
3. 语言官方注释规范.
4. 个人偏好.

本规则比 Google C++ 和 PEP 8 更严格: 解释性注释统一放在被注释代码的上一行, 不写行尾注释. 工具指令和作用域收尾标签是例外.

## 文件开头

文件开头可以简述作用, 但必须短. 优先一到两行, 说明这个文件为什么存在, 不写功能清单, 不写修改历史.

顺序:

1. shebang, 编码声明或工具必需指令.
2. 法律或许可证声明.
3. 文件用途, 一到两句.
4. 生成文件的只读标记.

禁止:

- 作者, 日期, 修改记录和版本历史. 这些由版本控制保存.
- 大段 ASCII 横幅和装饰框.
- `new`, `old`, `final`, `copy` 之类文件状态.
- 逐步解释每个函数.

示例:

```cpp
// Orchestrates startup and shutdown for registered application components.
```

```python
"""Orchestrate startup and shutdown for registered application components."""
```

```lua
-- Orchestrate startup and shutdown for registered application components.
```

```bash
# Orchestrate startup and shutdown for registered application components.
```

```powershell
# Orchestrate startup and shutdown for registered application components.
```

文件名和类型名已经说明用途时, 文件说明可以省略. 公开模块的文档可以稍长, 但仍只描述职责, 边界和入口.

## 什么时候写注释

只为以下情况写注释:

- 新语言特性, 新语法或新标准库用法, 且读者可能不熟悉.
- 非直觉的语义, 隐式转换, 求值顺序, 生命周期或所有权.
- 精妙但正确的算法, 不变量, 状态机约束.
- 性能取舍, 复杂度, 分配, 拷贝, 缓存, 锁粒度或批处理原因.
- 安全, 并发, 资源释放, 权限或外部系统约束.
- 业务规则, 协议要求, 兼容性原因或历史包袱.
- 故意偏离常规写法, 且不这样写会引入 bug.
- TODO, FIXME, HACK 和待移除的兼容代码.
- 公共 API 的契约. 类型系统和函数名表达不了的前置条件, 后置条件, 错误, 副作用和线程安全需要写清楚.

判断标准: 删掉注释后, 有经验的读者是否会误解代码, 重复踩坑或做错修改. 如果不会, 不写.

## 什么时候不写注释

- 代码已经一眼看懂: `i++`, 简单 getter, 直白的空值检查, 直观的循环.
- 注释只是重复函数名, 类型名或语句动作.
- 注释在解释语言基础语法.
- 注释用来弥补糟糕的命名. 先改名.
- 注释掉的旧代码. 用版本控制.
- 没有负责人, 没有动作, 没有完成条件的 TODO.
- 过时的计划, 猜测和未经验证的性能结论.
- 每个字段, 每个分支都写一段说明.

反例:

```cpp
// Increment i.
++i;

// Return the state.
return state_;

// Check whether the component is running.
if (component.is_running()) {
}
```

## 标记体系

符号前缀用于视觉区分, 后面的大写标签用于搜索和审查. 符号可以省略, 标签不能省略.

| 用途 | C 系语言 | Python / Shell / PowerShell | Lua |
| --- | --- | --- | --- |
| 普通说明 | `// ` | `# ` | `-- ` |
| 关键不变量或性能点 | `//* ` | `#* ` | `--* ` |
| 非直觉语义 | `//~ ` | `#~ ` | `--~ ` |
| 风险或前置条件 | `//! ` | `# WARNING: ` | `-- WARNING: ` |
| 待办 | `// TODO(...)` | `# TODO(...)` | `-- TODO(...)` |

C 系语言包括 C, C++, C#, Java, JavaScript, TypeScript 和 Go.

约束:

- `//*`, `//~`, `//!` 只用于对应类别, 不用于普通说明.
- 符号后必须跟大写标签和冒号, 例如 `//* INVARIANT: ...`.
- 不使用 `//******` 这类装饰线.
- Python, Shell 和 PowerShell 的 `#!` 在首行是 shebang, 不作为普通标记. 风险统一写 `# WARNING:`.
- Rust 的 `//!` 是内层文档注释, C++ Doxygen 也可能把 `//!` 当文档. 这两类文件用 `// WARNING:` 表示风险, 不用 `//!` 标记.
- Lua 的 `--!` 没有统一文档含义, 风险统一写 `-- WARNING:`.
- 标签使用英文大写, 保持可搜索: `INVARIANT`, `PERF`, `SUBTLE`, `WARNING`, `SAFETY`, `TODO`, `FIXME`, `HACK`.

### 标记说明

`//* INVARIANT:`

说明必须始终成立的条件. 如果条件被破坏, 后续逻辑失效.

```cpp
//* INVARIANT: components_ is stored in dependency-first order.
//  The reverse walk stops dependents before their dependencies.
```

`//* PERF:`

说明性能取舍和原因. 有测量数据或 issue 时给出链接, 不写未经验证的猜测.

```cpp
//* PERF: reserve avoids repeated reallocation for the known batch size.
components_.reserve(component_count);
```

`//~ SUBTLE:`

说明语言特性, 隐式行为或容易误读的语义.

```cpp
//~ SUBTLE: string_view does not own storage.
//  The referenced name must outlive this object.
std::string_view failed_start_;
```

```python
#~ SUBTLE: default arguments are evaluated once at definition time.
```

```lua
--~ SUBTLE: assigning a table copies the reference, not the table contents.
```

```bash
#~ SUBTLE: local and assignment are split to preserve the command exit status.
```

```powershell
#~ SUBTLE: pipeline output is fully enumerated before assignment.
```

`//! WARNING:`

说明调用者必须满足的条件, 危险操作或可能导致数据损坏的行为.

```cpp
//! WARNING: caller must hold mutex_; this function does not lock.
void reset_state();
```

Rust 或 Doxygen 项目写成:

```cpp
// WARNING: caller must hold mutex_; this function does not lock.
```

`// SAFETY:`

Rust unsafe 块必须说明为什么满足安全前置条件. 其他语言涉及 FFI, 裸内存或未检查边界时使用 `//! SAFETY:`.

```rust
// SAFETY: index is checked against len immediately above.
let value = unsafe { *buffer.get_unchecked(index) };
```

`// TODO(...)`

写明负责人或追踪项, 以及具体动作.

```cpp
// TODO(alice): replace with std::expected when the toolchain baseline allows.
```

```python
# TODO(#142): remove the compatibility branch after the next major release.
```

`// FIXME(...)`

已知缺陷. 必须写清触发条件和影响, 不能只写 `FIXME`.

`// HACK(...)`

临时绕过. 必须写原因, 追踪项和移除条件.

```cpp
// HACK(#318): vendor SDK writes past the buffer; remove after the 2.4 upgrade.
```

## 注释位置

- 解释性注释放在被注释语句, 表达式或代码块的上一行.
- 注释缩进与被注释代码一致.
- 注释和代码之间不留空行.
- 多行表达式在表达式上方说明, 不塞进参数列表或运算符之间.
- `switch` 分支说明放在 `case` 标签上一行.
- 文档注释紧贴声明, 中间不留空行.
- 公共 API 文档放在声明处. 实现文件只在实现有特殊技巧时补充.
- 同一段代码只放一个注释块, 不重复说明.
- 注释不跨越多层嵌套结构. 需要解释整个块时放在块入口上方.

禁止:

```cpp
do_work(); // Start the worker.
int count = 0; // Number of retries.
```

应改为:

```cpp
// Start the worker before registering callbacks.
do_work();

// Number of retries before the caller receives an error.
int count = 0;
```

例外:

- `// NOLINT`, `# noqa` 等工具指令可能要求行尾. 只用于最小范围, 不写解释性行尾注释.
- `// clang-format off`, `# shellcheck disable=...`, `// eslint-disable-next-line` 等指令放在目标代码上一行.
- `} // namespace`, `#endif // HEADER_H_` 等作用域收尾标签是结构标记, 不是解释性注释, 按语言风格保留.
- 公共 API 文档工具要求参数或返回值标签时, 使用文档注释, 不使用行尾注释.

## 多行注释

普通多行说明使用连续单行注释, 每行一个标记和空格. 这样 diff 清晰, 不产生嵌套问题, 也不会误伤代码.

```cpp
// The platform rounds timeouts up to the next scheduler tick.
// Keep this value below the watchdog interval.
constexpr int kTimeoutMs = 250;
```

```python
# The platform rounds timeouts up to the next scheduler tick.
# Keep this value below the watchdog interval.
TIMEOUT_MS = 250
```

```lua
-- The platform rounds timeouts up to the next scheduler tick.
-- Keep this value below the watchdog interval.
local timeout_ms = 250
```

`//*`, `//~`, `//!` 只出现在注释块第一行, 续行使用普通注释前缀, 并与正文对齐.

C 系语言的 `/* ... */` 不用于普通解释. 只在以下情况使用:

- 需要兼容只接受 C 风格注释的工具或 C89 源码.
- 语言文档工具明确要求块注释, 例如 Javadoc 的 `/** ... */`.
- 临时禁用代码. C++ 优先使用 `#if 0` / `#endif`, 不用大段注释包代码.

Python 的 `"""..."""` 是 docstring, 不是普通多行注释. 普通多行说明使用每行 `#`.

Lua 的 `--[[ ... ]]` 只用于临时禁用或工具要求的块, 普通说明使用每行 `--`.

PowerShell 的 `<# ... #>` 用于 comment-based help 或临时禁用, 普通说明使用每行 `#`.

## 文档注释

公共 API 使用语言原生文档系统, 不用自定义标记代替.

| 语言 | 文档注释 |
| --- | --- |
| C++ | 项目使用 Doxygen 时用 `///` 或 `/** ... */`, 否则用普通 `//` |
| Python | 模块, 类, 公共函数使用 docstring; PEP 257 格式 |
| Lua | 使用 LDoc 时用 `---`; 否则用普通 `--` |
| Shell | 无统一文档工具, 在函数上方用 `#` 说明输入, 输出和副作用 |
| PowerShell | 导出的命令使用 comment-based help `<# .SYNOPSIS ... #>` |
| JavaScript/TypeScript | JSDoc `/** ... */` |
| C# | XML 文档 `///` |
| Java | Javadoc `/** ... */` |
| Go | 声明上一行使用 `//`, 首句以声明名开头 |
| Rust | 外层文档 `///`, 模块或 crate 内层文档 `//!` |

文档注释写契约, 不写实现:

- 做什么, 为什么存在.
- 前置条件, 后置条件.
- 参数, 返回值, 错误或异常.
- 所有权, 生命周期, 线程安全和副作用.
- 非显然的限制和兼容性.

不要在头文件和实现文件重复同一份文档. 声明处写接口契约, 实现处只写实现细节.

## TODO, FIXME 与 HACK

- `TODO(owner):` 后续动作, 或 `TODO(#issue):` 追踪项.
- `FIXME(owner):` 已知缺陷, 写触发条件和影响.
- `HACK(issue):` 临时绕过, 写原因和移除条件.
- 没有负责人, issue 或明确完成条件的 TODO 不进入公共代码.
- 一个 TODO 只描述一件事.
- TODO 放在受影响代码的上一行. 全局债务放文件顶部或 issue, 不散落.
- 完成后删除对应注释, 不留下 `DONE` 历史.
- 文档工具原生支持 `@todo` 时可以在 API 文档内使用, 普通代码仍用 `TODO(...)`.

## 注释语言和文字质量

- 默认使用英文; 团队统一使用中文时, 同一文件只能使用一种语言.
- 使用 ASCII 标点, 不混用全角标点和半角标点.
- 普通说明写完整句子, 首字母大写, 句末加句号.
- 标记行可以使用短语, 但仍要完整表达约束或动作.
- 拼写和语法必须正确.
- 不使用 emoji, 颜文字, 讽刺和个人评价.
- 不写 `we`, `I`, `obviously`, `simply`, `just` 这类主观词.
- 引用外部算法, 协议或论文时给出可追踪来源.

## 明确避免

- 复述代码动作的注释.
- 行尾解释性注释.
- 注释掉的代码.
- 大段横幅和装饰框.
- 作者, 日期和修改历史.
- 过期或与代码矛盾的注释.
- 无 owner, 无 issue, 无动作的 TODO.
- 用注释掩盖糟糕的命名或结构.
- 在每个字段和分支上写模板化说明.
- 用 `//!` 破坏 Rust 文档或 Doxygen 文档.
- 用 `#!` 作为 Python 或 Shell 的普通标记.
- 把 docstring 当普通多行注释.
- 把 `/* ... */` 当作默认多行注释.
- 注释与代码之间隔空行.
- 注释缩进和代码不一致.

## 审查清单

- [ ] 文件开头说明是否简短, 必要, 且没有作者日期.
- [ ] 注释是否只出现在关键逻辑, 风险和契约处.
- [ ] 每条注释是否解释了 why, 约束, 后果或取舍.
- [ ] 是否删除了重复代码动作的注释.
- [ ] 是否使用了正确的标签和符号.
- [ ] 标记是否可搜索, 没有装饰性符号.
- [ ] 多行普通注释是否使用连续单行注释.
- [ ] 文档注释是否使用语言原生格式.
- [ ] 注释是否位于代码上一行, 缩进一致.
- [ ] 是否避免了行尾注释, 工具指令和收尾标签例外.
- [ ] TODO, FIXME, HACK 是否有负责人或追踪项.
- [ ] 注释是否与代码同步, 没有过期信息.
- [ ] 是否删除了注释掉的代码.
- [ ] 是否避免了 `//!` 和 `#!` 的语言冲突.
- [ ] 注释语言和标点是否统一.
- [ ] 文档工具或构建是否能正常生成文档.

## 参考来源

- LLVM Coding Standards, commenting: https://llvm.org/docs/CodingStandards.html#commenting
- Google C++ Style Guide, comments: https://google.github.io/styleguide/cppguide.html#Comments
- Python PEP 8, comments: https://peps.python.org/pep-0008/#comments
- Python PEP 257, docstrings: https://peps.python.org/pep-0257/
- Google Python Style Guide, comments and docstrings: https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings
- Google Shell Style Guide, comments: https://google.github.io/styleguide/shellguide.html#comments
- Microsoft C# XML documentation comments: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/
- Microsoft PowerShell comment-based help: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help
- JSDoc: https://jsdoc.app/
- Go Doc Comments: https://go.dev/doc/comment
- Rustdoc documentation: https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html
- LuaRocks Lua Style Guide: https://github.com/luarocks/lua-style-guide
