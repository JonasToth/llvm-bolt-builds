#!/bin/bash

BASE_DIR=$(pwd)
CPATH="$(pwd)/stage2-prof-generate/install/bin"

mkdir -p stage3-train || (echo "Could not create stage3-train directory"; exit 1)
cd stage3-train

echo "== Configure Build"
echo "== Build with stage2-prof-generate-tools -- $CPATH"

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
	-DCMAKE_C_FLAGS="-march=native -O3" \
	-DCMAKE_CXX_FLAGS="-march=native -O3" \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DLLVM_ENABLE_LLD=ON \
	-DLLVM_TOOL_CLANG_BUILD=ON \
	-DLLVM_TOOL_CLANG_TOOLS_EXTRA_BUILD=OFF \
	-DLLVM_TOOL_COMPILER_RT_BUILD=ON \
	-DLLVM_TOOL_LLD_BUILD=ON \
	../../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
ninja || (echo "Could not build project for training!"; exit 1)

echo
echo "== Merge Profile data"
cd ../stage2-prof-generate/profiles/ || (echo "Could not switch to profile directory, inconsistent directory layout detected!"; exit 1)
${BASE_DIR}/stage1/install/bin/llvm-profdata merge -output=clang.prof *.profraw || (echo "Could not merge profile-data!"; exit 1)
