#!/bin/bash

export TOPLEV=~/tc-build
cd ${TOPLEV}

mkdir -p ${TOPLEV}/build/llvm/stage3-without-sampling/intrumentdata || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/build/llvm/stage3-without-sampling
CPATH=${TOPLEV}/install/bin


echo "Instrument clang with llvm-bolt"

${TOPLEV}/build/llvm/stage1/bin/llvm-bolt \
  --instrument \
  --instrumentation-file-append-pid \
  --instrumentation-file=${TOPLEV}/build/llvm/stage3-without-sampling/intrumentdata/clang-15.fdata \
  ${CPATH}/clang-15 \
  -o ${CPATH}/clang-15.inst

mv ${CPATH}/clang-15 ${CPATH}/clang-15.org
mv ${CPATH}/clang-15.inst ${CPATH}/clang-15
echo "== Configure Build"
echo "== Build with stage2-prof-use-lto instrumented clang -- $CPATH"

cmake -G Ninja ${TOPLEV}/llvm-project/llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DCMAKE_C_COMPILER=${CPATH}/clang \
  -DCMAKE_CXX_COMPILER=${CPATH}/clang++ \
  -DLLVM_USE_LINKER=${CPATH}/ld.lld \
  -DCMAKE_INSTALL_PREFIX=${TOPLEV}/build/llvm/stage3-without-sampling/install

echo "== Start Training Build"
ninja & read -t 180 || kill $!

echo "Merging generated profiles"
cd ${TOPLEV}/build/llvm/stage3-without-sampling/intrumentdata
${TOPLEV}/build/llvm/stage1/bin/merge-fdata *.fdata > combined.fdata
echo "Optimizing Clang with the generated profile"

${TOPLEV}/build/llvm/stage1/bin/llvm-bolt ${CPATH}/clang-15.org \
  --data ${TOPLEV}/build/llvm/stage3-without-sampling/intrumentdata/combined.fdata \
  -o ${CPATH}/clang-15 \
  -reorder-blocks=cache+ \
  -reorder-functions=hfsort+ \
  -split-functions=3 \
  -split-all-cold \
  -dyno-stats \
  -icf=1 \
  -use-gnu-stack || (echo "Could not optimize binary for clang-15"; exit 1)

echo "You can now use the compiler with export PATH=${CPATH}:${PATH}"
