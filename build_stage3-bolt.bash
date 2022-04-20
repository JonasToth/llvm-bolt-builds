#!/bin/bash

jobs="$(echo $(( $(nproc) * 3/4 )) | cut -d '.' -f1)"
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir ${TOPLEV}/stage3  || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/stage3
CPATH=${TOPLEV}/stage2-prof-use-lto/install/bin/

echo "== Configure Build"
echo "== Build with stage2-prof-use-tools -- $CPATH"

cmake -G Ninja ../llvm-project/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang \
	-DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
	-DLLVM_USE_LINKER=lld -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage3/install

echo "== Start Training Build"
perf record -o ../perf.data -e cycles:u -j any,u -- ninja clang || (echo "Could not build project for training!"; exit 1)

sleep 30s

cd ..

export PATH=${TOPLEV}/stage1/install/bin:${PATH}

echo "Converting profile to a more aggreated form suitable to be consumed by BOLT"

perf2bolt ${CPATH}/clang-14 \
	-p perf.data \
	-o clang-14.fdata \
	-w clang-14.yaml || (echo "Could not convert perf-data to bolt for clang-14"; exit 1)

echo "Optimizing Clang with the generated profile"

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
