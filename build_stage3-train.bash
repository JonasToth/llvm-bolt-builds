#!/bin/bash

BASE_DIR=$(pwd)
CPATH="$(pwd)/stage2-prof-generate/install/bin"

mkdir -p stage3-train || (echo "Could not create stage3-train directory"; exit 1)
cd stage3-train

echo "== Configure Build"
echo "== Build with stage2-prof-generate-tools -- $CPATH"
cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
	-DLLVM_USE_LINKER=lld -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage3/install

perf record -e cycles:u -j any,u -- ninja

echo
echo "== Start Build"
ninja clang || (echo "Could not build project for training!"; exit 1)

echo
echo "== Merge Profile data"
cd ../stage2-prof-generate/profiles/ || (echo "Could not switch to profile directory, inconsistent directory layout detected!"; exit 1)
${BASE_DIR}/stage1/install/bin/llvm-profdata merge -output=clang.prof *.profraw || (echo "Could not merge profile-data!"; exit 1)
