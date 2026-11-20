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
