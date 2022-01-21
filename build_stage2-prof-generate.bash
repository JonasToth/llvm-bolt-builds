#!/bin/bash

BASE_DIR=$(pwd)
CPATH="$(pwd)/stage1/install/bin"

mkdir -p stage2-prof-generate || (echo "Could not create stage2-prof-generate directory"; exit 1)
cd stage2-prof-generate

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"
# AArch64 seems to be necessary for llvm-bolt (facebook thingie)
CC=${CPATH}/clang CXX=${CPATH}/clang++ LD=${CPATH}/lld \
	cmake 	-G Ninja \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DCLANG_ENABLE_ARCMT=OFF \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DCLANG_PLUGIN_SUPPORT=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DCLANG_VENDOR="CachyOS" \
	-DLLVM_BUILD_INSTRUMENTED=ON \
	-DCMAKE_C_FLAGS="-march=native -O3" \
	-DCMAKE_CXX_FLAGS="-march=native -O3" \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	../../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo
echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
