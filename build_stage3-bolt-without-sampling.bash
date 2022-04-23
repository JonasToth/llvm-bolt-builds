#!/bin/bash

export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

mkdir -p ${TOPLEV}/stage3-without-sampling/intrumentdata || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/stage3-without-sampling
CPATH=${TOPLEV}/stage2-prof-use-lto/install/bin

export PATH=${TOPLEV}/stage1/bin:${PATH}


echo "Instrument clang with llvm-bolt"

llvm-bolt \
	--instrument \
	---instrumentation-file-append-pid \
	--instrumentation-file=${TOPLEV}/stage3-without-sampling/intrumentdata/clang-15.fdata \
	${CPATH}/clang-15 \
	-o ${CPATH}/clang-15.inst

mv ${CPATH}/clang-15 ${CPATH}/clang-15.org
mv ${CPATH}/clang-15.inst ${CPATH}/clang-15
echo "== Configure Build"
echo "== Build with stage2-prof-use-lto instrumented clang -- $CPATH"

export PATH=${CPATH}:${PATH}

cmake -G Ninja ../llvm-project/llvm \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DCMAKE_C_COMPILER=$CPATH/clang-15 \
  -DCLANG_TABLEGEN=$CPATH/clang-tblgen \
  -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
  -DLLVM_USE_LINKER=$CPATH/ld.lld \
  -DLLVM_TABLEGEN=$CPATH/llvm-tblgen \
  -DCMAKE_RANLIB=$CPATH/llvm-ranlib \
  -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage3-without-sampling/install

echo "== Start Training Build"
ninja clang || (echo "Could not build project for training!"; exit 1)

echo "Merging generated profiles"
export PATH=${TOPLEV}/stage1/bin:${PATH}
cd ${TOPLEV}/stage3-without-sampling/intrumentdata
merge-fdata *.fdata > combined.fdata
echo "Optimizing Clang with the generated profile"

llvm-bolt ${CPATH}/clang-15.org \
	--data combined.fdata \
	-o ${CPATH}/clang-15.bolt \
	-reorder-blocks=cache+ \
	-reorder-functions=hfsort+ \
	-split-functions=3 \
	-split-all-cold \
	-dyno-stats \
	-icf=1 \
	-use-gnu-stack || (echo "Could not optimize binary for clang-15"; exit 1)
