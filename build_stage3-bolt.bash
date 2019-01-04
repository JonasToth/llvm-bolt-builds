#!/bin/bash

BASE_DIR=$(pwd)
CPATH="$(pwd)/stage2-prof-use-lto-reloc/install/bin"

mkdir -p stage3-bolt || (echo "Could not create stage3-bolt directory"; exit 1)
cd stage3-bolt

echo "== Configure Build"
echo "== Build with stage2-prof-use-tools -- $CPATH"
CC=${CPATH}/clang CXX=${CPATH}/clang++ LD=${CPATH}/lld \
cmake 	-G Ninja \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DCLANG_ENABLE_ARCMT=OFF \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DCLANG_VENDOR="LogMeIn" \
	-DLLVM_ENABLE_LLD=ON \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	-DLLVM_POLLY_BUILD=ON \
	-DLLVM_TARGETS_TO_BUILD="all" \
	-DLLVM_TOOL_CLANG_BUILD=ON \
	-DLLVM_TOOL_CLANG_TOOLS_EXTRA_BUILD=OFF \
	-DLLVM_TOOL_COMPILER_RT_BUILD=ON \
	-DLLVM_TOOL_LLD_BUILD=ON \
	../../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
# perf record -o ../perf.data -e cycles:u -j any,u -- ninja clang || (echo "Could not build project for training!"; exit 1)

cd ..

# Do the bolt-processing of the binary.
export PATH="${BASE_DIR}/stage2-prof-use/install/bin:$PATH"

echo "Bolting Clang"
perf2bolt ${CPATH}/clang-7 \
	-p perf.data \
	-o clang-7.fdata \
	-w clang-7.yaml

llvm-bolt ${CPATH}/clang-7 \
	-o ${CPATH}/clang-7.bolt \
	-b clang-7.yaml \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack

echo "Bolting LLD"
perf2bolt ${CPATH}/lld \
	-p perf.data \
	-o lld.fdata \
	-w lld.yaml

llvm-bolt ${CPATH}/lld \
	-o ${CPATH}/lld.bolt \
	-b lld.yaml \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack
