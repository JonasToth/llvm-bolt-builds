#!/bin/bash

export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir ${TOPLEV}/stage3-bolt  || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/stage3-bolt
CPATH=${TOPLEV}/stage2-prof-use-lto/install/bin
export PATH=${CPATH}:${PATH}

echo "== Configure Build"
echo "== Build with stage2-prof-use-tools -- $CPATH"

cmake -G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DCMAKE_C_COMPILER=clang \
	-DCMAKE_CXX_COMPILER=clang++ \
	-DLLVM_USE_LINKER=lld \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DLLVM_ENABLE_PROJECTS="clang" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo "== Start Training Build"
perf record -o ../perf.data -c 2500 -e cycles:u -j any,u -- ninja clang || (echo "Could not build project for training!"; exit 1)

sleep 30s

cd ..

export PATH=${TOPLEV}/stage1/bin:${PATH}

echo "Converting profile to a more aggreated form suitable to be consumed by BOLT"

perf2bolt ${CPATH}/clang-15 \
	-p perf.data \
	-o clang-15.fdata || (echo "Could not convert perf-data to bolt for clang-15"; exit 1)

echo "Optimizing Clang with the generated profile"

llvm-bolt ${CPATH}/clang-15 \
	-o ${CPATH}/clang-15.bolt \
	--data clang-15.fdata \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack || (echo "Could not optimize binary for clang-15"; exit 1)
