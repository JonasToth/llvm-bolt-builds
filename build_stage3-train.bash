#!/bin/bash

jobs="$(echo $(( $(nproc) * 3/4 )) | cut -d '.' -f1)"
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir ${TOPLEV}/stage3-train
cd ${TOPLEV}/stage3-train
CPATH=${TOPLEV}/stage2-prof-gen/install/bin

echo "Generating Profile for PGO"

cmake -G Ninja ${TOPLEV}/llvm-project/llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_PARALLEL_LINK_JOBS="$(jobs)" \
  -DLLVM_USE_LINKER=lld -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage3-train/install

echo "== Start Build"
ninja clang || (echo "Could not build project!"; exit 1)

echo "Merging PGO-Profiles"

cd ${TOPLEV}/stage2-prof-gen/profiles
${TOPLEV}/stage1/install/bin/llvm-profdata merge -output=clang.profdata *
