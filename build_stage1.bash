#!/bin/bash

mkdir -p stage1 || (echo "Could not create stage1 directory"; exit 1)
cd stage1

echo "== Configure Build"
echo "== Build with clang and lld host compiler"

CC=clang CXX=clang++ LD=lld \
cmake 	-G Ninja \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DCLANG_ENABLE_ARCMT=OFF \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DCLANG_VENDOR="CachyOS" \
	-DLLVM_ENABLE_LLD=ON \
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt;openmp;polly;lld;lldb" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	-DLLVM_POLLY_BUILD=ON \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DLLVM_TOOL_CLANG_BUILD=ON \
	-DLLVM_TOOL_CLANG_TOOLS_EXTRA_BUILD=OFF \
	-DLLVM_TOOL_COMPILER_RT_BUILD=ON \
	-DLLVM_TOOL_LLD_BUILD=ON \
	../../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo
echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
