
C++ 开发现代实践
工具链约束

- 编译器固定使用 g++-9（支持 C++17）/g++4.8（支持 C++11）。
- 不使用 C++20/23 特性（如 concepts、ranges、std::jthread、std::format）。
CMake 现代写法
- 使用 target-based 的现代 CMake（3.10+），优先使用 target_* 命令而非全局设置。
- CMakeLists.txt 中必须显式设置：
  - set(CMAKE_CXX_STANDARD 17)
  - set(CMAKE_CXX_STANDARD_REQUIRED ON)
  - set(CMAKE_CXX_EXTENSIONS OFF)
- 依赖管理优先使用 target_link_libraries(<target> PRIVATE/PUBLIC <lib>)，避免 include_directories() 和 link_libraries() 这类全局命令。
- 头文件搜索路径用 target_include_directories(<target> PUBLIC/PRIVATE <path>)。
- 推荐使用 add_library(<name> STATIC/SHARED ...) 和 add_executable(...) 明确目标类型。
代码生成规则
- 生成 C++ 代码时优先使用现代 C++11/C++14C++17/C++20 惯用法：
  - 资源管理用 RAII 和智能指针（std::unique_ptr、std::shared_ptr、std::make_unique）。
  - 可选值用 std::optional，错误处理可用 std::optional 或异常，视场景而定。
  - 字符串视图用 std::string_view 传递只读字符串参数。
  - 文件系统操作用 std::filesystem。
  - 编译期分支用 if constexpr。
- 避免裸 new/delete，避免 C 风格数组和裸指针管理所有权。
- 优先使用标准库算法（<algorithm>）而非手写循环。
- 禁止使用全角符号, 只能用半角符号加上一个空格, 无论中文还是英文.
- 只写关键注释, 尽量用: 为什么这么写而不是浅显描述作用
