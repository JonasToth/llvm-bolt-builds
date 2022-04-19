#!/bin/bash

mkdir -p stage1 || (echo "Could not create stage1 directory"; exit 1)
cd stage1

echo "== Configure Build"
echo "== Build with clang and lld host compiler"

CC=clang CXX=clang++ LD=lld \
	cmake -G Ninja \
 -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
 -DCOMPILER_RT_BUILD_CRT=OFF \
 -DCOMPILER_RT_BUILD_XRAY=OFF \
 -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
 -DLLVM_TARGETS_TO_BUILD="all" \
 -DCMAKE_BUILD_TYPE=Release \
 -DLLVM_BUILD_UTILS=OFF \
 -DLLVM_ENABLE_BACKTRACES=OFF \
 -DLLVM_ENABLE_WARNINGS=OFF \
 -DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt;bolt" \
 -DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)" \
 -DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
 -DCLANG_VENDOR=LLVM-BOLT \
 -DLLVM_INCLUDE_TESTS=OFF \
 -DLLVM_ENABLE_TERMINFO=OFF \
 -DCLANG_ENABLE_ARCMT=OFF \
 -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
 -DCLANG_PLUGIN_SUPPORT=OFF \
 -DLLVM_ENABLE_BINDINGS=OFF \
 -DLLVM_ENABLE_OCAMLDOC=OFF \
 -DLLVM_INCLUDE_DOCS=OFF \
 -DLLVM_INCLUDE_EXAMPLES=OFF \
  	../llvm-project/llvm|| (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo
echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
