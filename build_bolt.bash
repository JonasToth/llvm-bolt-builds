#!/bin/bash

mkdir -p build-bolt || (echo "Could not create build-bolt directory"; exit 1)
cd build-bolt

echo "== Deactivate everything but 'llvm-bolt'"

cmake -G Ninja ../llvm-project/llvm \
	-DLLVM_ENABLE_PROJECTS="bolt" \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_ASSERTIONS=ON \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" && \
	ninja bolt

cd $SCRIPT_PATH
