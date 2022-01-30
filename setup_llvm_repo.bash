#!/bin/bash

echo "Cloning llvm-project"

git clone --depth 1 https://github.com/llvm/llvm-project.git

cd $SCRIPT_PATH
