#!/bin/bash

BASE_DIR=$(pwd)
BOLT_INSTALL="$(pwd)/../build-bolt/install/bin"
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
	-DCLANG_PLUGIN_SUPPORT=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DCLANG_VENDOR="CachyOS" \
	-DLLVM_ENABLE_LLD=ON \
	-DCMAKE_C_FLAGS="-march=native -O3" \
	-DCMAKE_CXX_FLAGS="-march=native -O3" \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	-DLLVM_TARGETS_TO_BUILD="all" \
	../../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Training Build"
perf record -o ../perf.data -e cycles:u -j any,u -- ninja clang || (echo "Could not build project for training!"; exit 1)

cd ..

# Do the bolt-processing of the binary.
export PATH="${BOLT_INSTALL}:$PATH"

echo "* Bolting Clang"
perf2bolt ${CPATH}/clang-14 \
	-p perf.data \
	-o clang-14.fdata \
	-w clang-14.yaml || (echo "Could not convert perf-data to bolt for clang-14"; exit 1)

llvm-bolt ${CPATH}/clang-14 \
	-o ${CPATH}/clang-14.bolt \
	-b clang-14.yaml \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack || (echo "Could not optimize binary for clang-14"; exit 1)

echo "* Bolting LLD"
perf2bolt ${CPATH}/lld \
	-p perf.data \
	-o lld.fdata \
	-w lld.yaml || (echo "Could not convert perf-data to bolt for lld-14"; exit 1)

llvm-bolt ${CPATH}/lld \
	-o ${CPATH}/lld.bolt \
	-b lld.yaml \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack || (echo "Could not optimize binary for lld-14"; exit 1)
