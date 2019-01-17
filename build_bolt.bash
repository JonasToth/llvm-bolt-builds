#!/bin/bash

mkdir -p build-bolt || (echo "Could not create build-bolt directory"; exit 1)
cd build-bolt

echo "== Configure build for only llvm-bolt (facebookincubator project)"
echo "== Build with host-compiler, not part of the bootstrapping"
echo "== Deactivate everything but 'llvm-bolt'"

cmake -G Ninja \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
	-DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
	../../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Build 'llvm-bolt'"
ninja || (echo "Could not build 'llvm-bolt'"; exit 1)

echo
echo "== Install 'llvm-bolt'"
ninja install || (echo "Could not install 'llvm-bolt'"; exit 1)
