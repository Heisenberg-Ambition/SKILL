---
name: clang-tidy-cpp23
description: >
  Configure, explain, and apply LLVM clang-tidy for C++23 projects without
  assuming C++26 features. Use when creating or reviewing a .clang-tidy
  baseline, diagnosing clang-tidy or clangd findings, or checking generated
  C++23 code for safety, ownership, naming, and style compliance.
version: 2.0.0
tags: [cpp, cpp23, clang-tidy, static-analysis, code-quality]
---

# clang-tidy C++23 配置技能

## 何时使用

- 为 C++23 项目创建, 审查或修复 `.clang-tidy`.
- 处理 clang-tidy 或 clangd 的警告, 误报和配置不生效.
- 生成 C++23 代码后做静态检查, 确认检查建议没有超出标准或项目工具链能力.
- 需要与 `cpp-style-guide` 保持一致的命名, 安全, 所有权和并发规则.

## 与核心风格的关系

`../cpp-style-guide/SKILL.md` 定义代码应该是什么样. 本技能只负责如何用 clang-tidy 检查它.

优先级:

1. 用户当前任务和项目明确配置.
2. `cpp-style-guide` 的代码规则.
3. 本技能的静态分析基线.
4. clang-tidy 默认行为.

发生冲突时, 核心风格优先. 不为了消除警告而违反核心风格, 也不为了让 modernize 警告消失而使用项目工具链不支持的库设施.

本技能吸收了桌面 clang-tidy 基线中的以下规则:

- `InheritParentConfig: false`, 不继承父目录配置.
- 只报告问题, 不自动修复.
- `WarningsAsErrors` 为空, 不把警告提升为错误.
- 强制所有控制语句使用大括号.
- 启用悬空句柄, 异常逃逸, `sizeof` 误用, 可疑分号, 未定义内存操作, move 后使用等高信号检查.
- 启用 range copy, 不必要拷贝, 不必要值参数等性能检查.
- 启用 `modernize-use-nullptr`, `modernize-use-override` 和命名检查.
- `SystemHeaders: false`, 不检查系统头.
- `FormatStyle: file`.

桌面配置中的函数和方法使用 `lower_case`, 与参考头文件 `ApplicationLifecycle.h` 一致. 本技能保留 `snake_case` 函数命名, 枚举值使用 `PascalCase` 且不加 `k`, 私有成员保留尾随 `_`.

## 前置条件

- 目标语言标准: C++23. 可以使用 C++11 到 C++23 的标准设施, 但不得假设 C++26 专有能力.
- `clang-tidy` 20 或更新版本. C++23 相关检查在旧版本中可能不存在.
- 已有 `compile_commands.json`. 推荐 CMake 使用 `CMAKE_EXPORT_COMPILE_COMMANDS=ON`.
- 项目根目录有 `.clang-format`; `FormatStyle: file` 会读取它.
- 项目允许异常和 RTTI 的策略已经明确. 如果项目禁用异常, clang-tidy 的异常相关建议必须按项目策略解释.
- 使用的标准库必须实际支持相应设施. 仅有 C++23 编译选项不代表 `<format>`, `<print>` 或 ranges 一定完整可用.

## 标准边界

C++23 项目可以使用 C++11 到 C++23 的设施, 包括:

- C++11/14/17: 智能指针, lambda, `constexpr`, `enum class`, `std::optional`, `std::variant`, `std::string_view`, `std::filesystem`, 结构化绑定, `std::scoped_lock`, `std::shared_mutex`.
- C++20: concepts, requires, ranges, `std::span`, `std::jthread`, `std::format`, designated initializers, `contains`, `std::bit_cast`, `std::source_location`, `std::midpoint`, `std::erase_if`, `std::ssize`.
- C++23: `std::expected`, `std::print`, `std::byteswap`, `std::to_underlying`, `std::unreachable`, `std::mdspan`, `std::generator`, `std::flat_map`, `std::stacktrace`.

不默认使用 C++26 专有设施. C++26 项目可以套用本基线, 但反射, contracts, `std::execution` 等 C++26 能力必须由项目明确启用并有工具链支持, 不能因为 clang-tidy 或编译器接受就擅自引入.

`std::format` 和 `std::print` 的使用必须以标准库实现支持为前提. 若工具链缺少 `<format>` 或 `<print>`, 删除对应 modernize 检查或在项目配置中关闭, 不用第三方半兼容实现冒充标准设施.

## 核心配置

将以下内容写入项目根目录 `.clang-tidy`:

```yaml
# C++23 基线. 只报告问题, 不自动应用修复.
InheritParentConfig: false
Checks: >-
  -*,
  clang-analyzer-*,
  bugprone-*,
  performance-*,
  readability-*,
  misc-*,

  google-build-using-namespace,
  google-explicit-constructor,
  google-runtime-int,
  google-readability-casting,
  cppcoreguidelines-slicing,

  modernize-avoid-bind,
  modernize-avoid-c-arrays,
  modernize-concat-nested-namespaces,
  modernize-deprecated-headers,
  modernize-loop-convert,
  modernize-make-shared,
  modernize-make-unique,
  modernize-raw-string-literal,
  modernize-redundant-void-arg,
  modernize-replace-auto-ptr,
  modernize-replace-disallow-copy-and-assign-macro,
  modernize-replace-random-shuffle,
  modernize-return-braced-init-list,
  modernize-shrink-to-fit,
  modernize-type-traits,
  modernize-unary-static-assert,
  modernize-use-auto,
  modernize-use-bool-literals,
  modernize-use-constraints,
  modernize-use-default-member-init,
  modernize-use-designated-initializers,
  modernize-use-emplace,
  modernize-use-equals-default,
  modernize-use-equals-delete,
  modernize-use-integer-sign-comparison,
  modernize-use-noexcept,
  modernize-use-nullptr,
  modernize-use-override,
  modernize-use-ranges,
  modernize-use-scoped-lock,
  modernize-use-starts-ends-with,
  modernize-use-std-bit,
  modernize-use-std-format,
  modernize-use-std-numbers,
  modernize-use-std-print,
  modernize-use-string-view,
  modernize-use-structured-binding,
  modernize-use-transparent-functors,
  modernize-use-uncaught-exceptions,
  modernize-use-using,

  -clang-analyzer-security.insecureAPI.strcpy,
  -clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling,
  -clang-analyzer-optin.core.EnumCastOutOfRange,

  -bugprone-easily-swappable-parameters,
  -bugprone-implicit-widening-of-multiplication-result,
  -bugprone-invalid-enum-default-initialization,
  -bugprone-narrowing-conversions,
  -bugprone-signed-bitwise,
  -bugprone-switch-missing-default-case,
  -bugprone-unchecked-optional-access,

  -performance-enum-size,
  -performance-no-int-to-ptr,

  -readability-avoid-nested-conditional-operator,
  -readability-avoid-unconditional-preprocessor-if,
  -readability-function-cognitive-complexity,
  -readability-identifier-length,
  -readability-implicit-bool-conversion,
  -readability-magic-numbers,
  -readability-math-missing-parentheses,
  -readability-redundant-parentheses,
  -readability-suspicious-call-argument,
  -readability-trailing-comma,
  -readability-uppercase-literal-suffix,
  -readability-use-concise-preprocessor-directives,

  -misc-confusable-identifiers,
  -misc-include-cleaner,
  -misc-non-private-member-variables-in-classes,
  -misc-override-with-different-visibility,
  -misc-use-anonymous-namespace,
  -misc-use-internal-linkage

WarningsAsErrors: ''
HeaderFilterRegex: '(^|[/\\])(src|include|tests)[/\\]'
SystemHeaders: false
FormatStyle: file
CheckOptions:
  - key: readability-braces-around-statements.ShortStatementLines
    value: '0'
  - key: modernize-use-auto.MinTypeNameLength
    value: '5'
  - key: modernize-use-auto.RemoveStars
    value: 'false'
  - key: modernize-use-nullptr.NullMacros
    value: 'NULL'

  - key: readability-identifier-naming.NamespaceCase
    value: lower_case
  - key: readability-identifier-naming.ClassCase
    value: CamelCase
  - key: readability-identifier-naming.StructCase
    value: CamelCase
  - key: readability-identifier-naming.UnionCase
    value: CamelCase
  - key: readability-identifier-naming.EnumCase
    value: CamelCase
  - key: readability-identifier-naming.EnumConstantCase
    value: CamelCase
  - key: readability-identifier-naming.FunctionCase
    value: lower_case
  - key: readability-identifier-naming.MethodCase
    value: lower_case
  - key: readability-identifier-naming.VariableCase
    value: lower_case
  - key: readability-identifier-naming.GlobalVariableCase
    value: lower_case
  - key: readability-identifier-naming.ParameterCase
    value: lower_case
  - key: readability-identifier-naming.PrivateMemberCase
    value: lower_case
  - key: readability-identifier-naming.PrivateMemberSuffix
    value: '_'
  - key: readability-identifier-naming.PublicMemberCase
    value: lower_case
  - key: readability-identifier-naming.ProtectedMemberCase
    value: lower_case
  - key: readability-identifier-naming.ConstantCase
    value: CamelCase
  - key: readability-identifier-naming.ConstantPrefix
    value: 'k'
  - key: readability-identifier-naming.TypeAliasCase
    value: CamelCase
  - key: readability-identifier-naming.TypedefCase
    value: CamelCase
  - key: readability-identifier-naming.MacroDefinitionCase
    value: UPPER_CASE
```

`HeaderFilterRegex` 默认只分析 `src`, `include`, `tests`. 如果项目使用 `app`, `lib`, `domain` 等目录, 按实际路径修改, 不把整个第三方目录纳入检查.

## 检查集说明

- `clang-analyzer-*` 和 `bugprone-*` 负责空指针, 生命周期, 悬空引用, 异常逃逸, move 后使用等安全问题.
- `performance-*` 负责不必要拷贝, range copy, 值参数和低效容器操作.
- `readability-*` 负责大括号, 命名, const 使用, 布尔表达式和可维护性.
- `misc-*` 负责常见缺陷和未使用实体.
- `google-*` 只启用与核心风格一致的检查: 禁止 `using namespace`, 单参数构造 `explicit`, 固定宽度整数, C 风格转换.
- `modernize-*` 只启用 C++23 可用项, 不启用整套 `modernize-*`.
- C++20/23 检查只在目标标准允许时启用: concepts, ranges, designated initializers, `std::format`, `std::print`, `std::bit_cast` 等.
- `readability-container-contains` 在 C++23 中允许启用, 因为 `contains` 已可用.

命名映射:

| 类别 | 规则 |
| --- | --- |
| 命名空间 | `lower_case` |
| 类型, class, struct, enum | `CamelCase` |
| 函数和方法 | `lower_case` |
| 普通变量和参数 | `lower_case` |
| 私有成员 | `lower_case` 加 `_` |
| 常量 | `k` 加 `CamelCase` |
| 枚举值 | `CamelCase`, 不加 `k` |
| 类型别名 | `CamelCase` |
| 宏 | `UPPER_CASE` |

宏的项目前缀无法由该命名选项强制, 由核心规则和代码审查保证. `modernize-use-auto` 的建议只用于类型已明显的局部变量, 公共接口仍写明确类型. `modernize-use-emplace` 只在就地构造语义清楚时接受, 已有对象时 `push_back` 更清晰. `modernize-use-string-view` 的建议必须复核借用生命周期.

`modernize-avoid-c-arrays` 在 C ABI 或系统接口边界可能误报. 这类位置保留数组并用局部注释说明边界, 不为消除警告改成不兼容的容器类型.

## 使用步骤

1. 读取核心风格, 项目构建文件, 现有 `.clang-tidy` 和 `.clang-format`.
2. 确认项目确实以 C++23 编译, 且标准库支持计划使用的 C++20/23 设施.
3. 将配置写入项目根目录, 按实际源码目录调整 `HeaderFilterRegex`.
4. 验证配置:

```bash
clang-tidy --version
clang-tidy --verify-config --config-file=.clang-tidy
```

5. 使用编译数据库运行检查:

```bash
clang-tidy -p build --config-file=.clang-tidy path/to/file.cc
```

6. 只报告问题. 不运行 `--fix`, `--fix-errors` 或 `--fix-notes`.
7. 逐条判断后手工修复. 每条修复都必须保持 C++23 兼容, 并确认标准库实际支持.
8. 修复后重新运行同一文件和配置, 确认没有引入新警告.

## 输出格式

按严重程度输出:

- **错误**: 会导致编译失败, 未定义行为, 数据竞争, 资源泄漏或安全漏洞.
- **风险**: 可能引发悬空引用, 生命周期, 异常安全, 性能或可维护性问题.
- **建议**: 风格, 命名, modernize 和局部可读性改进.

每条问题包含:

- `文件:行:列`.
- clang-tidy 检查名.
- 具体原因.
- 最小修复方案.
- 是否属于 C++23 兼容修改.
- 若依赖可选库设施, 说明工具链条件.

如果 clang-tidy 建议使用项目未启用的 C++26 特性, 必须标记为不可直接应用. 如果建议与核心风格冲突, 明确说明核心风格优先.

## 快速审查清单

- [ ] 配置能被 `--verify-config` 加载.
- [ ] `InheritParentConfig` 为 `false`.
- [ ] `WarningsAsErrors` 为空.
- [ ] 没有启用整套 `modernize-*`.
- [ ] 所有 modernize 检查都适用于 C++23, 没有假设 C++26.
- [ ] 标准库确实支持 `std::format`, `std::print` 或 ranges, 再接受对应建议.
- [ ] 函数和方法使用 `lower_case`.
- [ ] 私有成员使用 `lower_case` 加 `_`.
- [ ] 常量使用 `k` 前缀, 枚举值使用 `CamelCase` 且不加 `k`.
- [ ] 大括号检查对所有控制语句生效.
- [ ] `HeaderFilterRegex` 覆盖项目源码, 排除第三方和系统头.
- [ ] 没有使用 `--fix`.
- [ ] 最终修复仍可在 C++23 工具链上构建.

## 常见问题

**配置报 unknown check**

当前 clang-tidy 版本不认识某个 C++20/23 检查. 升级到 20 或更新版本, 或删除该检查. 不要通过把项目标准降到 C++17 绕过问题.

**标准库没有 `<print>` 或 `<format>`**

删除 `modernize-use-std-print` 或 `modernize-use-std-format`, 或只保留报告不自动修改. 不要用不兼容的第三方库冒充标准设施.

**没有生成 `compile_commands.json`**

让 CMake 设置 `CMAKE_EXPORT_COMPILE_COMMANDS=ON`, 或在构建目录重新配置. 不要手工伪造编译参数.

**头文件没有告警**

检查 `HeaderFilterRegex` 是否覆盖实际目录. 不要改成 `.*` 后把第三方头文件噪声全部引入.

**函数名被报 CamelCase**

旧配置遗留了错误的大小写风格. 本技能按参考头文件使用 `lower_case`; 改为 `CamelCase` 会与项目命名冲突.

**modernize 建议使用 ranges 或 concepts**

只有项目标准, 编译器和标准库都支持时才接受. 不要因为 clang-tidy 能提示就引入半实现特性.

**auto 建议过多**

保留 `modernize-use-auto.MinTypeNameLength: 5` 和 `RemoveStars: false`. 只允许类型在初始化式右侧明显可见时使用 `auto`.
