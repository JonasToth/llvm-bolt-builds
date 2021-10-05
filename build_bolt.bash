#!/bin/bash

echo "Cloning bolt"

git clone --deepth=1 https://github.com/facebookincubator/BOLT.git llvm-bolt


mkdir -p build-bolt || (echo "Could not create build-bolt directory"; exit 1)
cd build-bolt

echo "== Deactivate everything but 'llvm-bolt'"

cmake -G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
	-DLLVM_ENABLE_ASSERTIONS=ON \
	-DLLVM_ENABLE_PROJECTS="clang;lld;bolt" \
	-DCMAKE_EXE_LINKER_FLAGS="-Wl,--push-state -Wl,-whole-archive -ljemalloc_pic -Wl,--pop-state -lpthread -lstdc++ -lm -ldl" \
	../llvm-bolt/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Build 'llvm-bolt'"
ninja || (echo "Could not build 'llvm-bolt'"; exit 1)

echo
echo "== Install 'llvm-bolt'"
ninja install-llvm-bolt install-perf2bolt install-merge-fdata \
      install-llvm-boltdiff install-bolt_rt
|| (echo "Could not install 'llvm-bolt'"; exit 1)


cd $SCRIPT_PATH
