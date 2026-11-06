---
name: clang-tidy-cpp17
description: 生成并维护符合 Google Style + C++ Core Guidelines 共识的 .clang-tidy 配置文件，目标标准 C++17。当用户需要创建、修复或审查 .clang-tidy 配置，或排查 clangd/clang-tidy 警告时使用。
version: 1.0.0
tags: [cpp, cpp17, clang-tidy, static-analysis, code-quality]
---

# clang-tidy C++17 配置技能

## 何时使用

- 用户要求创建 / 修复 / 审查 `.clang-tidy` 配置文件
- 用户遇到 clangd 或 clang-tidy 的警告、误报、配置不生效问题
- 用户需要 C++17 项目的静态分析基线

## 前置条件

- 目标标准：C++17
- 编译器：clang 15+（部分检查在旧版本不存在，会被忽略，不导致失败）
- 构建：存在 `compile_commands.json`（`-p build` 或 CMake `CMAKE_EXPORT_COMPILE_COMMANDS=ON`）
- 格式：项目根目录有 `.clang-format`

## 核心配置

将以下内容写入项目根目录 `.clang-tidy`：

```yaml
# .clang-tidy
# 基线: LLVM clang-tidy 官方推荐 + C++ Core Guidelines (通用子集)
# 目标标准: C++17
# 原则: 优先启用高信号检查；对高噪声 / 依赖 GSL / 风格偏好过强的检查显式禁用

Checks: >
  -*,
  clang-analyzer-*,
  bugprone-*,
  modernize-*,
  performance-*,
  readability-*,
  misc-*,
  google-explicit-constructor,
  google-build-using-namespace,
  google-runtime-int,
  cppcoreguidelines-slicing,

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

  -modernize-avoid-c-arrays,
  -modernize-macro-to-enum,
  -modernize-redundant-void-arg,
  -modernize-use-designated-initializers,
  -modernize-use-integer-sign-comparison,
  -modernize-use-nodiscard,
  -modernize-use-std-numbers,
  -modernize-use-trailing-return-type,
  -modernize-use-using,

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
  -misc-use-internal-linkage,

WarningsAsErrors: >
  bugprone-*,
  clang-analyzer-*,
  google-build-using-namespace,
  google-explicit-constructor,
  modernize-use-nullptr,
  modernize-use-override

CheckOptions:
  - key: modernize-use-nullptr.NullMacros
    value: 'NULL'

  - key: readability-identifier-naming.VariableCase
    value: lower_case
  - key: readability-identifier-naming.GlobalVariableCase
    value: lower_case
  - key: readability-identifier-naming.MemberCase
    value: lower_case
  - key: readability-identifier-naming.MemberSuffix
    value: '_'
  - key: readability-identifier-naming.ConstantCase
    value: CamelCase
  - key: readability-identifier-naming.ConstantPrefix
    value: 'k'

HeaderFilterRegex: '.*'
FormatStyle: file