#!/bin/bash

jobs="$(echo $(( $(nproc) * 3/4 )) | cut -d '.' -f1)"
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir -p stage1 || (echo "Could not create stage1 directory"; exit 1)
cd stage1

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"

cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD=X86 \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_ASM_COMPILER=clang \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt;bolt;polly" \
	-DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF \
	-DCOMPILER_RT_BUILD_LIBFUZZER=OFF -DLLVM_USE_LINKER=lld \
	-DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage1/install || (echo "Could not configure project!"; exit 1)

echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
