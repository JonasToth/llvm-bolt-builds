#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <PATH-TO-COMPILER-INSTALL-BIN>"
  echo "Example: $0 \"\$(pwd)/stage1/install/bin\""
  exit 1
fi

CPATH="$1"

mkdir -p measure-build-time || (echo "Could not create build-directory!"; exit 1)
cd measure-build-time
echo "== Clean old build-artifacts"
rm -r *

echo "== Configure reference Clang-build with tools from ${CPATH}"

CC=${CPATH}/clang CXX=${CPATH}/clang++ LD=${CPATH}/lld \
  cmake 	-G Ninja \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
  -DLLVM_ENABLE_LLD=ON \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
  -DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  ../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
time ninja clang || (echo "Could not build project!"; exit 1)
