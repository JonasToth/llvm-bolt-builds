#!/bin/bash
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}
mkdir -p ${TOPLEV}
git clone --depth=1 https://github.com/llvm/llvm-project.git
