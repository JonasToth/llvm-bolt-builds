#!/bin/bash

if [ $# -ne 0 ]; then
    echo "Usage: $0"
    echo
    echo "This script will clone the git-monorepo, go for the right commit"
    echo "and add llvm-bolt and the necessary patches into the repo."
    exit 1
fi

echo "== Checking for existence of 'llvm-project' directory"
if [ -d "llvm-project" ]; then
  echo "* 'llvm-project' already exists. Stopping"
  exit 0
fi

echo "== Cloning git-monorepo for LLVM"
# Old mono-repo.
# git clone https://github.com/llvm-project/llvm-project-20170507.git llvm-project

# New mono-repo.
git clone https://github.com/llvm/llvm-project.git
