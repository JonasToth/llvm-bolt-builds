#!/bin/bash


echo "== Checking for existence of 'llvm-project' directory"
if [ -d "llvm-project" ]; then
  echo "* 'llvm-project' already exists. Stopping"
  exit 0
fi

echo "Coning llvm-project"

git clone https://github.com/llvm/llvm-project.git

cd $SCRIPT_PATH
