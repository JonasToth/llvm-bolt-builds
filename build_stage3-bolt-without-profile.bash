#!/bin/bash

export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir ${TOPLEV}/stage3-without-sampling  || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/stage3-without-sampling
CPATH=${TOPLEV}/stage2-prof-use-lto/install/bin

export PATH=${TOPLEV}/stage1/bin:${PATH}

llvm-bolt \
--instrument \
--instrumentation-file=clang-15.fdata \
-o ${CPATH}/clang-15.inst

echo "== Configure Build"
echo "== Build with stage2-prof-use-lto -- $CPATH"

#export PATH=${CPATH}:${PATH}

cmake -G Ninja ../llvm-project/llvm
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_PROJECTS="clang"
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DCMAKE_C_COMPILER=$CPATH/clang.inst
	-DCMAKE_CXX_COMPILER=$CPATH/clang++ \
	-DLLVM_USE_LINKER=lld -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage3/install

echo "== Start Training Build"
ninja clang || (echo "Could not build project for training!"; exit 1)
mv clang-15.fdata clang-15-1.fdata
export PATH=${TOPLEV}/stage1/install/bin:${PATH}

echo "Optimizing Clang with the generated profile"

~/toolchain/llvm/stage1/llvm-bolt ${CPATH}/clang-15 \
	--data clang-15.fdata \
	-o ${CPATH}/clang-15.bolt \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack || (echo "Could not optimize binary for clang-15"; exit 1)
