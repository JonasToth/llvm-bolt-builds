#!/bin/bash
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

echo "Building Clang with PGO and LTO"

mkdir ${TOPLEV}/stage2-prof-use-lto
cd ${TOPLEV}/stage2-prof-use-lto
CPATH=${TOPLEV}/stage1/bin/

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"

cmake -G Ninja ${TOPLEV}/llvm-project/llvm \
  -DCLANG_ENABLE_ARCMT=OFF \
  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
  -DCLANG_PLUGIN_SUPPORT=OFF \
  -DLLVM_ENABLE_BINDINGS=OFF  \
  -DLLVM_ENABLE_OCAMLDOC=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DCMAKE_C_COMPILER=$CPATH/clang \
  -DCLANG_TABLEGEN=$CPATH/clang-tblgen \
  -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
  -DLLVM_USE_LINKER=$CPATH/ld.lld \
  -DLLVM_TABLEGEN=$CPATH/llvm-tblgen \
  -DCMAKE_RANLIB=$CPATH/llvm-ranlib \
  -DLLVM_ENABLE_PROJECTS="clang;compiler-rt;lld;polly" \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_CRT=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DLLVM_TARGETS_TO_BUILD=X86 \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_WARNINGS=OFF \
  -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage2-prof-use-lto/install \
  -DLLVM_PROFDATA_FILE=${TOPLEV}/stage2-prof-gen/profiles/clang.profdata \
  -DLLVM_ENABLE_LTO=Thin \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--emit-relocs" \
  -DLLVM_ENABLE_PLUGINS=ON \
  -DLLVM_ENABLE_TERMINFO=OFF  || (echo "Could not configure project!"; exit 1)

echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)
