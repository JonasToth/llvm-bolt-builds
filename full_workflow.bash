#!/bin/bash

SCRIPT_PATH=$(pwd)

cd ../
echo "Cloning LLVM REPO"
$SCRIPT_PATH/setup_llvm_repo.bash || (echo "Setting up mono-repo failed!"; exit 1)

#cd ../
#$SCRIPT_PATH/choose_latest_release.bash || (echo "Switching to latest stable LLVM-Release failed!"; exit 1)
#cd ../

echo  "build bolt"
$SCRIPT_PATH/build_bolt.bash || (echo "Building llvm-bolt separatly failed!"; exit 1)

cd $SCRIPT_PATH

echo "Create vanilla build of LLVM toolchain, comparitivly slow, but contains the necessary tools we use (without BOLT)"
./build_stage1.bash || (echo "Building Stage1-Toolchain failed!"; exit 1)

echo "Build a new instrumented LLVM with stage1, instrumentation allows PGO"
./build_stage2-prof-generate.bash || (echo "Building instrumented Stage2-Toolchain failed!"; exit 1)

echo "  Rebuild LLVM with instrumented stage2 -> Gather performance data that can be fed into the optimizer "
./build_stage3-train.bash || (echo "Generating training-data failed!"; exit 1)

echo " Build an optimized LLVM (PGO+LTO) with the stage1 compiler. (faster ~30%)"
./build_stage2-prof-use-lto-reloc.bash || (echo "Building optimized LTO+PGO Stage2-Toolchain failed!"; exit 1)

# If possible, measure the runtime of the optimized stage2 compiler with perf
# and feed these measurements into BOLT, that will optimize the binary layout
# of clang for improved cache friendlyness

echo "Only use it if you got perf and CPU with LBR record"
./build_stage3-bolt.bash || (echo "Optimizing Stage2-Toolchain further with llvm-bolt failed!"; exit 1)
