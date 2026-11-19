# C++17 编码 Skill

> 用途：可直接作为系统提示 / 规则文件，供大模型生成或审查 C++17 代码时遵守。  
> 基线：Google C++ Style Guide 中可自动检查的部分 + C++ Core Guidelines 共识 + C++17 标准。  
> 默认策略：允许异常用于错误传播，但要求异常安全；若项目明确采用 Google 内部风格，则启用附录中的“禁用异常/RTTI”配置。  
> 优先级：正确性 > 可读性 > 性能；一致性 > 个人偏好。

## 规则标记

- **[必须]** 强制遵守
- **[推荐]** 默认采纳
- **[避免]** 不应出现
- **[C++17]** 仅 C++17 可用特性
- **[Google]** Google 特有约定，项目可配置

---

## 1. 语言与标准

1.1 **[必须]** 目标标准为 C++17，编译使用 `-std=c++17`；不使用 C++20/23 特性（`concepts`、`ranges`、`std::format`、`consteval`、`constinit`、`std::jthread`、`std::span`、`std::expected` 等）。

1.2 **[必须]** 启用警告 `-Wall -Wextra -Wpedantic`，CI 中建议 `-Werror`；不使用编译器扩展，平台特定代码隔离到单独文件并用宏保护。

1.3 **[必须]** 不用 C 风格强制转换；优先 `static_cast`，`dynamic_cast` / `reinterpret_cast` / `const_cast` 审慎使用并局部化。

1.4 **[必须]** 用 `nullptr`，不用 `NULL` 或 `0` 表示空指针。

1.5 **[必须]** 用 `constexpr` / `inline constexpr` 替代宏常量；宏仅用于条件编译和头文件守卫，宏名全大写并带项目前缀。

1.6 **[推荐]** 用 `enum class` 而非 `enum`；用 `using` 别名而非 `typedef`。

1.7 **[推荐]** 当类型从初始化式明显可见时用 `auto`；接口语义、所有权语义处写明确类型或 `auto&` / `auto&&`。

1.8 **[必须]** `#include` 顺序：对应头文件 → C 系统头 → C++ 标准库 → 其他库 → 本项目头文件；头文件必须自包含；减少不必要 include，用前向声明（不要前向声明标准库类型）。

1.9 **[必须]** 头文件使用 include guard（Google 风格）或 `#pragma once`（团队统一），不要混用；非 `inline` / `template` 实现放在 `.cc` 中。

1.10 **[必须]** 头文件中不用 `using namespace`；源文件中也避免全局 `using namespace`；内部链接用匿名命名空间。

1.11 **[Google]** 命名默认：类型 `PascalCase`；函数 `PascalCase`；变量/参数 `snake_case`；类成员 `snake_case_`；常量 `kConstantName`；枚举值 `kEnumName`；命名空间 `snake_case`；宏 `PROJECT_MACRO`；文件 `snake_case`。格式由 `.clang-format`（Google 基础）强制。

1.12 **[必须]** 不向 `std` 命名空间添加声明，除非标准允许的对用户类型特化。

## 1.13 **[推荐]** 减少C语言的方式和头文件。

---
## 2. 资源管理与 RAII

2.1 **[必须]** 减少裸 `new` / `delete`；优先 `std::unique_ptr` / `std::shared_ptr` / 容器 / RAII 包装器。裸指针仅用于非拥有观察。

2.2 **[必须]** 用 `std::make_unique` / `std::make_shared` 而非显式 `new`。

2.3 **[推荐]** 所有权层级：栈对象 → `std::unique_ptr` → `std::shared_ptr`；`shared_ptr` 仅表示共享所有权，不表示生命周期。

2.4 **[必须]** 不要用同一裸指针构造多个智能指针；`shared_ptr` 循环引用用 `weak_ptr` 打破。

2.5 **[推荐]** 函数传 `shared_ptr`：需要共享所有权时按值；仅借用时用 `const shared_ptr&` 或 `T*` / `T&`；`unique_ptr` 转移所有权按值，借用按引用。

2.6 **[必须]** Rule of Zero；若手写析构、拷贝、移动中的任何一个，通常写全（Rule of Five）；移动构造/移动赋值应 `noexcept`。

2.7 **[必须]** 不要 `return std::move(local)`；不要返回局部对象的引用或指针。

2.8 **[必须]** 用 `{}` 初始化防止窄化；成员初始化用初始化列表 / `{}`，顺序与声明一致；避免构造函数体内赋值。

2.9 **[必须]** 多态基类析构函数应为 `virtual`，或使用 protected 非虚析构禁止基类删除；构造和析构过程中不调用虚函数。

2.10 **[推荐]** 小对象、局部对象优先栈分配；让对象拥有对象，而不是拥有指针。

2.11 **[C++17]** 用 `std::optional<T>` 表示可能缺失的返回值；错误用异常或错误码，不用 `optional` 表示错误。

2.12 **[C++17]** 用 `std::variant` + `std::visit` 替代类型标签联合；`std::any` 慎用。

2.13 **[C++17]** 用 `std::string_view` 作只读字符串参数；不要存储 `string_view`，不要从临时 `string` 构造后长期持有。

2.14 **[C++17]** 数值与字符串转换用 `<charconv>`（`from_chars` / `to_chars`），避免 `atoi` / `sprintf`；简单转换可用 `std::stoi` 但必须处理异常和越界。

2.15 **[C++17]** 时间用 `<chrono>`；随机数用 `<random>`（`mt19937` + distribution），不用 `rand()`；路径用 `std::filesystem`（禁用异常项目使用 `error_code` 重载）；简单匹配不用 `std::regex`。

---

## 3. 类、接口与 const

3.1 **[必须]** 能加 `const` 就加；不修改对象状态的成员函数标 `const`。

3.2 **[必须]** 成员变量应为 `private`；暴露行为而非数据；getter 按需提供，setter 谨慎。

3.3 **[必须]** 派生类覆盖虚函数标 `override`，不重复 `virtual`；禁止继续覆盖标 `final`。

3.4 **[必须]** 用 `= delete` 禁用函数，而非未定义的 private 声明；用 `= default` 显式默认。

3.5 **[必须]** 单参数构造函数和转换运算符标 `explicit`，除非有意隐式转换。

3.6 **[必须]** 区分名字隐藏、重载与覆盖；派生类同名函数隐藏基类所有重载，需要时用 `using Base::Func;` 引入。

3.7 **[必须]** 不重新定义继承而来的非虚函数；public 继承应建模 is-a；组合优于继承；多重继承审慎，通常限于接口式纯虚继承。

3.8 **[推荐]** 接口类使用纯虚函数 + 虚析构，或 protected 非虚析构。

3.9 **[推荐]** 成员函数按需标 `const` / `noexcept` / `final` / `override`；`noexcept` 承诺不抛异常，否则直接 `std::terminate()`。

3.10 **[推荐]** 函数参数：输入小类型按值，大类型 `const T&`；输出参数用指针（Google）或引用（团队统一），调用点应能识别输出参数。

3.11 **[必须]** 比较器、哈希、回调保持语义一致；不要重载 `&&` / `||` / `,`。

3.12 **[C++17]** `[[nodiscard]]` 用于不应忽略的返回值；`[[maybe_unused]]` 用于确实未使用；`[[fallthrough]]` 用于 switch 故意贯穿；`[[deprecated]]` 标记废弃；`[[noreturn]]` 标记不返回。

3.13 **[必须]** `switch` 分支以 `break` / `return` / `[[fallthrough]]` 结束；覆盖所有枚举值可不写 `default`，否则写 `default` 并处理。

3.14 **[推荐]** 用 `static_assert` 做编译期检查；C++17 优先 `if constexpr` 简化模板分支，但不要替代运行时分派。

---

## 4. STL、算法与 Lambda

4.1 **[推荐]** 默认容器 `std::vector`；固定大小 `std::array`；有序映射 `std::map` / `std::set`，哈希 `std::unordered_map` / `std::unordered_set`；`std::list` 少用，除非需要稳定迭代器或频繁中间插入。

4.2 **[必须]** 用 `emplace_back` 就地构造；已有对象时 `push_back` 可更清晰；`reserve` 预分配。

4.3 **[推荐]** 用迭代器或范围 `for` 遍历；只读用 `const auto&`，修改用 `auto&`；优先 `const_iterator`。

4.4 **[必须]** 删除元素用 erase-remove 惯用法（C++17 手写）；`std::remove` 不删除元素，必须配合 `erase`。

4.5 **[必须]** `std::map::operator[]` 会插入默认值；查找用 `find` / `at` / `count`。

4.6 **[必须]** 比较器满足严格弱序，不要用 `<=`；哈希函数与 `operator==` 保持一致。

4.7 **[推荐]** 用 STL 算法（`<algorithm>` / `<numeric>`）替代手写循环；C++17 可用 `std::clamp`、`std::size`、`std::as_const`。

4.8 **[必须]** Lambda 捕获列表显式写出；避免默认捕获 `[=]` / `[&]`，尤其异步或生命周期延长场景；`[this]` 注意对象生命周期。

4.9 **[推荐]** Lambda 优于 `std::bind`；通用引用用 `T&&` + `std::forward<T>`。

4.10 **[推荐]** `std::function` 有开销，性能敏感处用模板或函数指针；`std::vector<bool>` 是位压缩特化，需要普通 bool 用 `std::vector<char>` 或 `std::array<bool>`。

4.11 **[C++17]** 用结构化绑定解构 `pair` / `tuple` / 聚合结构体；范围 `for` 中注意 `auto&` / `const auto&` 避免拷贝。

4.12 **[C++17]** 嵌套命名空间用 `namespace a::b { ... }`；`inline` 变量用于头文件常量。

4.13 **[必须]** 不用 C 风格数组/字符串；用 `std::array` / `std::vector` / `std::string`；数组大小用 `std::size`。

4.14 **[推荐]** 字符串输出用 `'\n'` 而非 `std::endl`，除非确实需要刷新。

---

## 5. 并发

5.1 **[推荐]** 优先 `std::async` / `std::future` 而非裸 `std::thread`；必须使用线程时，确保析构前 join 或 detach（C++17 无 `std::jthread`）。

5.2 **[必须]** 用 `std::atomic` / `std::lock_guard` / `std::unique_lock` / `std::scoped_lock`（C++17）管理同步；避免手动 lock/unlock。

5.3 **[推荐]** 一次性结果用 `std::promise` / `std::future`，不用全局变量轮询；多次数据用 `std::queue` + `std::condition_variable` 构建生产者-消费者模型。

5.4 **[必须]** 条件变量等待用谓词形式 `wait(lock, pred)` 防虚假唤醒。

5.5 **[推荐]** 锁粒度尽量小；不持锁调用未知代码、IO 或回调；多锁用 `std::scoped_lock` 避免死锁。

5.6 **[必须]** `std::atomic` 默认 `memory_order_seq_cst`；需要放宽内存序必须有明确理由并证明正确；`volatile` 不用于并发同步。

5.7 **[推荐]** 一次性初始化用 `std::call_once` / `std::once_flag` 或函数局部静态（C++11 起线程安全）。

5.8 **[必须]** 明确对象线程安全契约；`const` 成员函数不自动线程安全；`shared_ptr` 引用计数原子，但对象访问不自动线程安全。

5.9 **[C++17]** 读写锁用 `std::shared_mutex` / `std::shared_lock`；多锁用 `std::scoped_lock`。

---

## 6. 错误处理与异常

6.1 **[推荐]** 默认允许异常用于错误传播，但要求异常安全（RAII，不泄漏）；不要用异常做正常控制流。

6.2 **[必须]** 按 `const` 引用捕获异常；不要 `catch(...)` 吞异常；析构函数不抛异常（默认 `noexcept`）。

6.3 **[推荐]** 移动构造、移动赋值、`swap` 标 `noexcept`；`noexcept` 函数中调用可能抛异常的代码必须处理。

6.4 **[Google/可选]** 若项目声明采用 Google 内部风格：禁用异常和 RTTI；用 `Status` / 错误码 / `optional` 传播错误；输出参数用指针；此时所有资源管理不得依赖异常。

6.5 **[必须]** `const_cast` 仅用于适配不修改的旧接口，不修改原 const 对象；`reinterpret_cast` 仅用于底层字节/硬件，类型双关用 `memcpy`。

---

## 7. 代码风格与可读性

7.1 **[推荐]** 不要过早优化；正确性 > 可读性 > 性能。

7.2 **[推荐]** Early return 处理错误和前置条件，减少嵌套；对等的二选一逻辑用对称 `if/else`。

7.3 **[推荐]** `switch` 表达“是什么”，`if/else` 表达“满足什么条件”；大量离散分支考虑查表或函数指针数组。

7.4 **[必须]** 一般不写 `this->`，除非出现名称遮蔽；`[*this]` 是 C++17 拷贝捕获，注意拷贝代价。

7.5 **[推荐]** 注释解释“为什么”，不是“是什么”；TODO 带负责人/日期；不保留注释掉的代码。

7.6 **[必须]** 行宽、缩进、大括号、指针符号按 `.clang-format`（Google 基础）统一；CI 运行 `clang-tidy`（`modernize-*`、`bugprone-*`、`performance-*`、`readability-*`）。

7.7 **[推荐]** 函数保持短小、单一职责；参数不宜过多；复杂条件提取具名布尔变量。

7.8 **[必须]** 不使用 `goto`，除非跳出多层循环且明显更清晰；不用 `register`、`std::auto_ptr`、`std::random_shuffle`、`std::bind1st` / `bind2nd`、`std::ptr_fun` / `mem_fun`、`std::unary_function` / `binary_function`、`std::iterator` 基类、动态异常说明、`<ccomplex>` / `<ciso646>` / `<cstdalign>` / `<cstdbool>` / `<ctgmath>`。

7.9 **[必须]** 无论函数体、`if`、`else`、`for`、`while`、`do` 是否为单行，都必须用大括号 `{}` 包裹；禁止省略大括号的单语句写法。

---

## 8. C++17 可用特性清单（积极采用）

- 结构化绑定、`if constexpr`、`if` / `switch` 初始化语句
- `std::optional`、`std::variant`、`std::any`（慎用）
- `std::string_view`（不存储）
- `inline` 变量、嵌套命名空间
- `[[nodiscard]]`、`[[maybe_unused]]`、`[[fallthrough]]`、`[[deprecated]]`、`[[noreturn]]`
- `std::scoped_lock`、`std::shared_mutex`
- `std::filesystem`、`std::charconv`
- `std::clamp`、`std::size`、`std::as_const`、`std::invoke`、`std::apply`
- `std::byte`（原始字节）
- 并行算法（按需，注意实现支持）

---

## 9. 明确避免

- **C++20/23 特性**：`concepts`、`ranges`、`std::format`、`consteval`、`constinit`、`std::jthread`、`std::span`、`std::bit_cast`、`std::source_location`、`std::ssize`、`std::erase_if`、`std::midpoint`
- **已移除/废弃**：`std::auto_ptr`、`std::random_shuffle`、`std::bind1st` / `bind2nd`、`std::ptr_fun` / `mem_fun`、`std::unary_function` / `binary_function`、`std::iterator` 基类、动态异常说明、`register`
- **C 风格**：`NULL`、C 强制转换、C 数组/字符串、`rand()`、`sprintf` 到固定缓冲区、头文件中 `using namespace`
- **危险做法**：同一裸指针构造多个智能指针、返回局部引用、`return std::move(local)`、默认捕获 lambda 跨生命周期、`volatile` 做同步、`catch(...)` 吞异常

---

## 10. 快速审查清单

生成代码后自检：

- [ ] 是否 C++17，无 C++20 特性？
- [ ] 有无裸 `new` / `delete`？智能指针/容器是否优先？
- [ ] 有无 C 风格转换、`NULL`、C 数组/字符串？
- [ ] 多态基类析构是否 `virtual`？覆盖是否 `override`？
- [ ] 是否 Rule of Zero/Five？移动是否 `noexcept`？有无 `return std::move`？
- [ ] `const` 正确性？成员是否 `private`？单参数构造是否 `explicit`？
- [ ] 容器遍历是否 `const` 引用？删除是否 erase-remove？`map` 查找是否避免 `operator[]`？
- [ ] Lambda 捕获是否显式？有无默认捕获跨生命周期？
- [ ] 并发是否用 RAII 锁？条件变量是否谓词等待？线程是否 join/detach？
- [ ] 头文件是否自包含？include 顺序？命名/格式是否符合 `clang-format`？
- [ ] 异常/RTTI 策略是否与项目一致？

---
