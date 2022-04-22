#!/bin/bash
export TOPLEV=~/toolchain/llvm
mkdir -p ~/toolchain/llvm
cd ${TOPLEV}
echo "Cloning LLVM"
git clone https://github.com/llvm/llvm-project.git
