#!/bin/bash

echo "Cloning bolt"

git clone https://github.com/facebookincubator/BOLT.git llvm-bolt


mkdir -p build-bolt || (echo "Could not create build-bolt directory"; exit 1)
cd build-bolt

echo "== Deactivate everything but 'llvm-bolt'"

cmake -G Ninja ../llvm-bolt/llvm \
	-DLLVM_ENABLE_PROJECTS="bolt;clang;lld" \
	-DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_ASSERTIONS=ON \
	-DCMAKE_EXE_LINKER_FLAGS="-Wl,--push-state -Wl,-whole-archive -ljemalloc_pic -Wl,--pop-state -lpthread -lstdc++ -lm -ldl" \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" && \
	ninja install-llvm-bolt install-perf2bolt install-merge-fdata \
	install-llvm-boltdiff install-bolt_rt

cd $SCRIPT_PATH
