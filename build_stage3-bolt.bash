#!/bin/bash
jobs="$(echo $(( $(nproc) * 3/4 )) | cut -d '.' -f1)"
BASE_DIR=$(pwd)
STAGE_ONE="$(pwd)/stage1/install/bin"
CPATH="$(pwd)/stage2-prof-use-lto-reloc/install/bin"

mkdir -p stage3-bolt || (echo "Could not create stage3-bolt directory"; exit 1)
cd stage3-bolt

echo "== Configure Build"
echo "== Build with stage2-prof-use-tools -- $CPATH"

cmake -G Ninja ../llvm-project/llvm  -DLLVM_TARGETS_TO_BUILD=X86 -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
	-DLLVM_USE_LINKER=lld -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage3/install

echo
echo "== Start Training Build"
perf record -o ../perf.data -e cycles:u -j any,u -- ninja clang  || (echo "Could not build project for training!"; exit 1)


perf record -e cycles:u -j any,u -- ninja

sleep 30s

cd ..

# Do the bolt-processing of the binary.
export PATH="${STAGE_ONE}:$PATH"

echo "* Bolting Clang"
perf2bolt ${CPATH}/clang-14 \
	-p perf.data \
	-o clang-14.fdata \
	-w clang-14.yaml || (echo "Could not convert perf-data to bolt for clang-14"; exit 1)

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
