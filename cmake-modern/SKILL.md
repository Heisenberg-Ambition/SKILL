---
name: cmake-modern
description: >
  Create, review, and simplify modern CMake builds for C and C++ projects.
  Use when adding or fixing CMakeLists.txt, source discovery, compile_commands,
  debug warnings, parallel builds, toolchains, or platform build scripts.
  Prefer target-based commands supported by the project minimum, not the
  newest commands installed on the machine.
version: 1.3.0
tags: [cmake, cpp, build, toolchain, compile-commands, bash]
---

# CMake 现代构建规则

## 适用范围

本规则只管构建系统: CMake 版本, 目标定义, 源文件发现, 编译选项, `compile_commands.json` 和构建脚本. 不定义 C++ 语言风格, 命名, 注释或静态分析规则.

本 SKILL 自包含, 完整 `CMakeLists.txt`, Linux `build.sh` 和 Windows `build.ps1` 都在本文中, 不依赖同目录的其他文件.

## 核心原则

1. 以项目现有的 `cmake_minimum_required` 为兼容下限. 不为了使用新语法擅自提高下限.
2. "最新命令"指项目下限允许的最新命令, 不是机器安装的最新 CMake 命令.
3. 优先 target-based 命令: `target_sources`, `target_include_directories`, `target_compile_options`, `target_link_libraries`.
4. 不写死源文件名. 在 `src` 下自动发现 `.cpp`, `.cc`, `.cxx`.
5. 语言标准由项目传入, 不在模板里写死 `17` 或 `20`.
6. 文件开头设置标准约束和 `compile_commands` 导出.
7. 只在 Debug 配置启用编译器警告, 不污染 Release 配置.
8. 默认按机器可用 CPU 数并行编译, 允许用 `JOBS` 覆盖.
9. CMakeLists 保持短小. 不添加没有实际作用的变量, 函数, 注释和宏.
10. 修改已有项目时, 只改必要部分, 不重排无关配置.

## 版本兼容规则

不要盲目复制最新 CMake 示例. 先看项目下限, 再选择命令. 需要新能力时, 用版本判断保护, 或明确说明必须提高下限.

| CMake 版本 | 可用能力 | 使用建议 |
| --- | --- | --- |
| 3.10 | `target_*`, `CMAKE_CXX_STANDARD`, `CMAKE_EXPORT_COMPILE_COMMANDS` | 可作为旧项目兼容底线 |
| 3.12 | `file(... CONFIGURE_DEPENDS)`, `cmake --build --parallel` | 可用自动源文件发现和并行构建 |
| 3.13 | `cmake -S`, `cmake -B` | 优先使用现代命令形式 |
| 3.19 | CMake Presets | 已有 presets 时不要重复配置 |
| 3.23 | `target_sources(FILE_SET)` | 需要管理头文件集合时使用 |
| 3.24 | `CMAKE_COMPILE_WARNING_AS_ERROR` | 需要把警告提升为错误时使用 |
| 3.25 | `SYSTEM` 包含目录属性 | 系统头目录隔离时使用 |

版本判断示例:

```cmake
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
  file(GLOB_RECURSE APP_SOURCES CONFIGURE_DEPENDS
    "${APP_SOURCE_DIR}/*.cpp"
  )
else()
  file(GLOB_RECURSE APP_SOURCES
    "${APP_SOURCE_DIR}/*.cpp"
  )
endif()
```

不要使用项目下限不支持的语法. 不要仅为了使用新命令而升级项目 CMake 下限.

## 完整 CMakeLists.txt 模板

将下面完整内容保存为项目根目录的 `CMakeLists.txt`, 再修改:

- `project(MyProject ...)` 的项目名.
- `src` 目录路径.
- `app` 目标名.
- 编译器和平台需要的附加选项.

```cmake
cmake_minimum_required(VERSION 3.10)

project(MyProject LANGUAGES CXX)

if(NOT DEFINED CMAKE_CXX_STANDARD)
  message(FATAL_ERROR "CMAKE_CXX_STANDARD is required. Set it from the project or pass -DCMAKE_CXX_STANDARD=<standard>.")
endif()

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(APP_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
  file(GLOB_RECURSE APP_SOURCES CONFIGURE_DEPENDS
    "${APP_SOURCE_DIR}/*.cpp"
    "${APP_SOURCE_DIR}/*.cc"
    "${APP_SOURCE_DIR}/*.cxx"
  )
else()
  file(GLOB_RECURSE APP_SOURCES
    "${APP_SOURCE_DIR}/*.cpp"
    "${APP_SOURCE_DIR}/*.cc"
    "${APP_SOURCE_DIR}/*.cxx"
  )
endif()

if(NOT APP_SOURCES)
  message(FATAL_ERROR "No C++ sources found under ${APP_SOURCE_DIR}.")
endif()

add_executable(app ${APP_SOURCES})
target_include_directories(app PRIVATE "${APP_SOURCE_DIR}")

if(MSVC)
  target_compile_options(app PRIVATE
    $<$<CONFIG:Debug>:/W4>
    $<$<CONFIG:Debug>:/permissive->
  )
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(app PRIVATE
    $<$<CONFIG:Debug>:-Wall>
    $<$<CONFIG:Debug>:-Wextra>
    $<$<CONFIG:Debug>:-Wpedantic>
  )
endif()
```

模板刻意不写:

- 具体源文件名.
- 具体 C++ 标准值.
- `include_directories()` 和 `link_libraries()` 这类全局命令.
- 无用的变量和注释.
- 不必要的 `install`, `enable_testing` 或打包规则.

### 源文件发现

说明:

- `CONFIGURE_DEPENDS` 让 CMake 在构建时检查源文件变化, 但会增加构建系统开销.
- CMake 官方更推荐显式源文件列表. 这里按“不写死文件名”的项目要求使用 glob, 属于有意识的取舍.
- `aux_source_directory` 不递归, 不会自动发现新文件, 不返回头文件, 顺序也未定义. 只在维护既有代码时保留, 新配置不用它.
- 两个脚本每次运行都会重新执行 configure, 因此即使项目下限低于 3.12, 新增文件也能被重新发现.

## 语言标准

`CMAKE_CXX_STANDARD` 必须来自项目配置, 构建参数或父工程. 模板不提供默认标准, 避免把某个项目的 C++17 或 C++20 强加到另一个项目.

推荐:

```bash
./build.sh -s 17
```

```powershell
.\build.ps1 -CxxStandard 17
```

或在项目配置中设置:

```cmake
set(CMAKE_CXX_STANDARD 17)
```

模板只设置:

```cmake
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
```

`CMAKE_EXPORT_COMPILE_COMMANDS ON` 放在目标定义之前. 它主要适用于 Makefile 和 Ninja 生成器; Visual Studio 多配置生成器不保证生成 `compile_commands.json`, 需要 clangd 时优先使用 Ninja.

## Debug 警告

只在 Debug 配置启用高信号警告:

```cmake
if(MSVC)
  target_compile_options(app PRIVATE
    $<$<CONFIG:Debug>:/W4>
    $<$<CONFIG:Debug>:/permissive->
  )
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(app PRIVATE
    $<$<CONFIG:Debug>:-Wall>
    $<$<CONFIG:Debug>:-Wextra>
    $<$<CONFIG:Debug>:-Wpedantic>
  )
endif()
```

不要默认加 `-Werror` 或 `/WX`. 需要警告即错误时, 用项目选项或 CI 单独开启.

## 构建脚本

脚本按平台分开, 不在一个文件里堆叠平台判断:

- Linux 使用 `build.sh`, Bash 和 `nproc`.
- Windows 使用 `build.ps1`, PowerShell 和 `[Environment]::ProcessorCount`.
- 两者都从当前项目目录读取 `CMakeLists.txt`.
- 两者都使用 `-S/-B`, `--parallel` 和明确命令行参数.
- 不使用环境变量前缀, 统一通过命令行参数传入配置.
- 脚本需要 CMake 3.13+; CMakeLists 本身仍保持 3.10 兼容.

### Linux build.sh

将下面完整内容保存为项目根目录的 `build.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./build.sh [-b Debug|Release|RelWithDebInfo|MinSizeRel] [-s STANDARD] [-j JOBS] [-t TARGET]

  -b  Build type, default: Debug
  -s  CMAKE_CXX_STANDARD, optional
  -j  Parallel jobs, default: nproc
  -t  Build target, optional
  -h  Show this help
EOF
}

BUILD_TYPE=Debug
CXX_STANDARD=""
JOBS="$(nproc)"
TARGET=""

while getopts ":b:s:j:t:h" opt; do
  case "$opt" in
    b) BUILD_TYPE="$OPTARG" ;;
    s) CXX_STANDARD="$OPTARG" ;;
    j) JOBS="$OPTARG" ;;
    t) TARGET="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) printf 'missing value for -%s\n' "$OPTARG" >&2; exit 2 ;;
    \?) printf 'unknown option: -%s\n' "$OPTARG" >&2; exit 2 ;;
  esac
done

case "$BUILD_TYPE" in
  Debug|Release|RelWithDebInfo|MinSizeRel) ;;
  *) printf 'invalid build type: %s\n' "$BUILD_TYPE" >&2; exit 2 ;;
esac
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || { printf 'invalid jobs: %s\n' "$JOBS" >&2; exit 2; }

[[ -f CMakeLists.txt ]] || { printf 'CMakeLists.txt not found in %s\n' "$PWD" >&2; exit 2; }
command -v cmake >/dev/null 2>&1 || { printf 'cmake not found\n' >&2; exit 2; }

cmake_args=(-S "$PWD" -B "$PWD/build" -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON)
[[ -n "$CXX_STANDARD" ]] && cmake_args+=("-DCMAKE_CXX_STANDARD=$CXX_STANDARD")

cmake "${cmake_args[@]}"

build_args=(--build "$PWD/build" --config "$BUILD_TYPE" --parallel "$JOBS")
[[ -n "$TARGET" ]] && build_args+=(--target "$TARGET")
cmake "${build_args[@]}"
```

执行:

```bash
chmod +x build.sh
./build.sh
```

```bash
./build.sh -b Release -s 17 -j 8 -t app
```

参数:

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `-b` | `Debug` | `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` |
| `-s` | 未设置 | 可选的 `CMAKE_CXX_STANDARD` |
| `-j` | `nproc` | 并行任务数 |
| `-t` | 空 | 可选构建目标 |
| `-h` | 空 | 显示帮助 |

`nproc` 只适用于 Linux. 容器或 CI 有 CPU 限额时显式传 `-j`. 不再使用环境变量前缀.

### Windows build.ps1

将下面完整内容保存为项目根目录的 `build.ps1`:

```powershell
[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Debug",

    [string]$CxxStandard = "",

    [int]$Jobs = [Environment]::ProcessorCount,

    [string]$Target = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SourceDir = (Get-Location).Path
$BuildDir = Join-Path $SourceDir "build"

if (-not (Test-Path (Join-Path $SourceDir "CMakeLists.txt"))) {
    throw "CMakeLists.txt not found in $SourceDir"
}

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw "cmake not found"
}

if ($Jobs -lt 1) {
    throw "Jobs must be a positive integer"
}

$cmakeArgs = @(
    "-S", $SourceDir,
    "-B", $BuildDir,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
)

if ($CxxStandard) {
    $cmakeArgs += "-DCMAKE_CXX_STANDARD=$CxxStandard"
}

& cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$buildArgs = @("--build", $BuildDir, "--config", $BuildType, "--parallel", "$Jobs")
if ($Target) {
    $buildArgs += @("--target", $Target)
}

& cmake @buildArgs
exit $LASTEXITCODE
```

执行:

```powershell
.\build.ps1
```

```powershell
.\build.ps1 -BuildType Release -CxxStandard 17 -Jobs 8 -Target app
```

参数:

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `-BuildType` | `Debug` | `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` |
| `-CxxStandard` | 未设置 | 可选的 `CMAKE_CXX_STANDARD` |
| `-Jobs` | CPU 数 | 并行任务数 |
| `-Target` | 空 | 可选构建目标 |

PowerShell 版使用 `[Environment]::ProcessorCount`, 不调用 `nproc`, 不做跨平台判断. `CMAKE_EXPORT_COMPILE_COMMANDS` 主要适用于 Make 和 Ninja; Visual Studio 生成器不保证生成 `compile_commands.json`.

## 使用流程

1. 读取项目现有 `CMakeLists.txt`, `CMakePresets.json`, 工具链文件和 CI.
2. 确认项目支持的 CMake 下限, 不擅自升级.
3. 确认语言标准来源. 不把示例中的标准值复制到其他项目.
4. 将模板和脚本写入项目根目录, 修改项目名, 源码目录和目标名.
5. 运行 `cmake --version` 和项目的配置命令.
6. 运行对应平台的 `build.sh` 或 `build.ps1`, 或项目原有构建命令.
7. 检查 `build/compile_commands.json` 是否存在, 路径是否符合预期.
8. 分别验证 Debug 和 Release. 警告只在 Debug 开启是预期行为.
9. 检查新增文件是否被 glob 发现, 删除文件后是否重新配置.
10. 不添加未使用的 CMake 函数, 变量和注释.

## 审查清单

- [ ] `cmake_minimum_required` 与项目实际支持范围一致.
- [ ] 没有为了新语法擅自提高下限.
- [ ] 使用 target-based 命令, 没有全局 `include_directories` 或 `link_libraries`.
- [ ] 源文件通过 `file(GLOB_RECURSE)` 发现, 没有写死单个文件名.
- [ ] CMakeLists 的旧版路径有回退, 新版语法有版本判断.
- [ ] `CMAKE_CXX_STANDARD` 由项目传入, 没有硬编码默认值.
- [ ] 设置了 `CMAKE_CXX_STANDARD_REQUIRED` 和 `CMAKE_CXX_EXTENSIONS`.
- [ ] 设置了 `CMAKE_EXPORT_COMPILE_COMMANDS`.
- [ ] Debug 警告只作用于 Debug 配置.
- [ ] 没有默认把警告提升为错误.
- [ ] Linux `build.sh` 使用 `nproc`, Windows `build.ps1` 使用 `ProcessorCount`.
- [ ] 两个脚本都使用明确命令行参数, 没有环境变量前缀.
- [ ] 两个脚本每次重新配置, 新增源文件可被发现.
- [ ] 配置和构建命令在项目支持的 CMake 版本上可运行.
- [ ] 没有无用配置, 重复命令和过度封装.

## 常见问题

**CMake 报 unknown command 或 unknown argument**

项目下限不支持该语法. 降级到兼容写法, 或用 `CMAKE_VERSION` 判断并保留回退, 不要直接提高项目下限.

**新增 .cpp 后没有参与构建**

项目下限低于 3.12 且没有 `CONFIGURE_DEPENDS` 时, CMake 不会自动发现. 运行对应平台的构建脚本重新配置, 或在构建目录执行 `cmake ..`.

**没有 compile_commands.json**

确认使用 Makefile 或 Ninja 生成器, 且 `CMAKE_EXPORT_COMPILE_COMMANDS` 为 `ON`. Visual Studio 多配置生成器不保证支持.

**Debug 有警告, Release 没有**

这是预期行为. 需求是只在 Debug 开启警告. 如果 Release 也要警告, 显式修改 generator expression, 并说明原因.

**并行任务过多导致内存不足**

使用 `./build.sh -j 4` 或 `.\build.ps1 -Jobs 4` 降低并发. 最大 CPU 数不等于最大安全并发数.

**glob 把生成文件也纳入**

限制 glob 到 `src` 目录, 不把构建目录, 生成目录或第三方目录放入扫描范围.

## 参考来源

- CMake documentation: https://cmake.org/documentation/
- `cmake-buildsystem`: https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html
- `file` command: https://cmake.org/cmake/help/latest/command/file.html
- `target_sources`: https://cmake.org/cmake/help/latest/command/target_sources.html
- `target_compile_options`: https://cmake.org/cmake/help/latest/command/target_compile_options.html
- `CMAKE_EXPORT_COMPILE_COMMANDS`: https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html
- `cmake --build`: https://cmake.org/cmake/help/latest/manual/cmake.1.html#build-tool-mode
