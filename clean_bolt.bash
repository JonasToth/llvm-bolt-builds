#!/bin/bash

echo "== Switching to repository"
cd llvm-project

echo "== Removing llvm/tools/llvm-bolt"
rm -rf llvm/tools/llvm-bolt

echo "== git clean the repo"
git clean -df *

echo "== Switching to master"
git checkout master

echo "== Deleting bolt_experiment-branch"
git branch -D bolt_experiment
