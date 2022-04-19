#!/bin/bash

jobs="$(echo $(( $(nproc) * 3/4 )) | cut -d '.' -f1)"
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir ${TOPLEV}/stage2-prof-gen || (echo "Could not create stage2-prof-generate directory"; exit 1)
cd ${TOPLEV}/stage2-prof-gen
CPATH=${TOPLEV}/stage1/install/bin/

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"

cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_PARALLEL_LINK_JOBS="$(jobs)" \
  -DLLVM_USE_LINKER=lld -DLLVM_BUILD_INSTRUMENTED=ON \
  -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage2-prof-gen/install || (echo "Could not configure project!"; exit 1)

echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
