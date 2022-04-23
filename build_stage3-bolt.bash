#!/bin/bash

export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir ${TOPLEV}/stage3-bolt  || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/stage3-bolt
CPATH=${TOPLEV}/llvm-bolt/bin


echo "== Configure Build"
echo "== Build with stage2-prof-use-tools -- $CPATH"

cmake -G Ninja \
    -DLLVM_BINUTILS_INCDIR=/usr/include \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
    -DCMAKE_AR=${CPATH}/llvm-ar \
    -DCMAKE_C_COMPILER=${CPATH}/clang \
    -DCLANG_TABLEGEN=${CPATH}/clang-tblgen \
    -DCMAKE_CXX_COMPILER=${CPATH}/clang++ \
    -DLLVM_USE_LINKER=${CPATH}/ld.lld \
    -DLLVM_TABLEGEN=${CPATH}/llvm-tblgen \
    -DCMAKE_RANLIB=${CPATH}/llvm-ranlib \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_ENABLE_PROJECTS="clang" \
    ../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo "== Start Training Build"
perf record -o ${TOPLEV}/perf.data --max-size=10G -F 1500 -e cycles:u -j any,u -- ninja clang || (echo "Could not build project for training!"; exit 1)

cd ${TOPLEV}

echo "Converting profile to a more aggreated form suitable to be consumed by BOLT"

${CPATH}/stage1/bin/perf2bolt ${CPATH}/clang-15 \
    -p ${TOPLEV}perf.data \
    -o ${TOPLEV}/clang-15.fdata || (echo "Could not convert perf-data to bolt for clang-15"; exit 1)

echo "Optimizing Clang with the generated profile"

${TOPLEV}/stage1/install/bin/llvm-bolt ${CPATH}/clang-15 \
    -o ${CPATH}/clang-15.bolt \
    --data ${TOPLEV}/clang-15.fdata \
    -reorder-blocks=cache+ \
    -reorder-functions=hfsort+ \
    -split-functions=3 \
    -split-all-cold \
    -dyno-stats \
    -icf=1 \
    -use-gnu-stack || (echo "Could not optimize binary for clang-15"; exit 1)

echo "move bolted binary to clang-15"
mv ${CPATH}/clang-15 ${CPATH}/clang-15.org
mv ${CPATH}/clang-15.bolt ${CPATH}/clang-15

echo "You can now use the compiler with export PATH=${CPATH}:${PATH}"
