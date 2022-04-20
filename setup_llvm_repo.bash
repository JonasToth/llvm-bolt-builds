#!/bin/bash
export TOPLEV=~/toolchain/llvm
mkdir -p ~/toolchain/llvm
cd ${TOPLEV}
echo "Cloning LLVM 14 Branch"
git clone -b release/14.x https://github.com/llvm/llvm-project.git
