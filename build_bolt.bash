#!/bin/bash

echo "Cloning bolt"

git clone https://github.com/facebookincubator/BOLT.git llvm-bolt


mkdir -p build-bolt || (echo "Could not create build-bolt directory"; exit 1)
cd build-bolt

echo "== Deactivate everything but 'llvm-bolt'"

cmake -G Ninja \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
	-DLLVM_ENABLE_PROJECTS="clang;lld;bolt" \
	../llvm-bolt/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Build 'llvm-bolt'"
ninja || (echo "Could not build 'llvm-bolt'"; exit 1)

echo
echo "== Install 'llvm-bolt'"
ninja install
|| (echo "Could not install 'llvm-bolt'"; exit 1)


cd $SCRIPT_PATH
