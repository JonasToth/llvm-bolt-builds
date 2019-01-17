#!/bin/bash


echo "== Choosing right revision (as required by facebook)"
cd llvm-project

# This commit ID is from the old mono-repo and uses the official supported
# commit for llvm-bolt.
# git checkout -b bolt_experiment 55bdff2ae913bf5af541654e17dd0c9a337536e2

# This commit ID from the new mono-repo and uses the official supported commit
# for llvm-bolt.
git checkout -b bolt_experiment 2fa1436206177291edb2d78c84d5822bb6e58cc9

echo "== Getting llvm-bolt from facebookincubator"
cd llvm/tools/
git clone https://github.com/facebookincubator/BOLT llvm-bolt

echo "== Patching LLVM"
cd ..
patch -p 1 < tools/llvm-bolt/llvm.patch 

echo "== Create commit from patch"
git commit -am "[BOLT] Apply bolt patch to mono-repo"
