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
