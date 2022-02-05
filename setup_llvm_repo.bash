#!/bin/bash

echo "Cloning llvm-project"

git clone -b release/14.x https://github.com/llvm/llvm-project.git

cd $SCRIPT_PATH
