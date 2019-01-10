#!/bin/bash

if [ $# -ne 0 ]; then
    echo "Usage: $0"
    echo
    echo "This script will clone the git-monorepo, go for the right commit"
    echo "and add llvm-bolt and the necessary patches into the repo."
    exit 1
fi

echo "== Cloning git-monorepo for LLVM"
git clone https://github.com/llvm-project/llvm-project-20170507.git llvm-project

echo "== Choosing right revision (as required by facebook)"
cd llvm-project
git checkout -b bolt_experiment 55bdff2ae913bf5af541654e17dd0c9a337536e2

echo "== Getting llvm-bolt from facebookincubator"
cd llvm/tools/
git clone https://github.com/facebookincubator/BOLT llvm-bolt

echo "== Patching LLVM"
cd ..
patch -p 1 < tools/llvm-bolt/llvm.patch 
