#!/bin/bash

# REQUIREMENT: LLVM Monorepo is setup and functional (see setup_llvm_repo.bash)

# Create vanilla build of LLVM toolchain, comparitivly slow, but contains the necessary tools we use (BOLT inclusively)
./build_stage1.bash

# Build a new instrumented LLVM with stage1, instrumentation allows PGO
./build_stage2-prof-generate.bash

# Rebuild LLVM with instrumented stage2 -> Gather performance data that can be fed into the optimizer
./build_stage3-train.bash

# Build an optimized LLVM (PGO+LTO) with the stage1 compiler. (faster ~30%)
./build_stage2-prof-use-lto-reloc.bash

# If possible, measure the runtime of the optimized stage2 compiler with perf
# and feed these measurements into BOLT, that will optimize the binary layout
# of clang for improved cache friendlyness

# Requires perf and CPU with LBR record
./build_stage3-bolt.bash
