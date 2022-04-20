#!/bin/bash
jobs="$(echo $(( $(nproc) * 3/4 )) | cut -d '.' -f1)"
export TOPLEV=~/toolchain/llvm
cd ${TOPLEV}

echo "Building Clang with PGO and LTO"

mkdir ${TOPLEV}/stage2-prof-use-lto
cd ${TOPLEV}/stage2-prof-use-lto
CPATH=${TOPLEV}/stage1/install/bin/

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"

export LDFLAGS="-Wl,-q"

CC=${CPATH}/clang CXX=${CPATH}/clang++ LD=${CPATH}/lld \
cmake -G Ninja ${TOPLEV}/llvm-project/llvm -DLLVM_TARGETS_TO_BUILD="all" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=$CPATH/clang -DCMAKE_CXX_COMPILER=$CPATH/clang++ \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_ENABLE_LTO=Thin \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--as-needed -Wl,--build-id=sha1 -Wl,--emit-relocs" \
   -DENABLE_LINKER_BUILD_ID=ON \
  -DLLVM_PARALLEL_LINK_JOBS="$(jobs)" -DLLVM_PARALLEL_COMPILE_JOBS="$(jobs)" \
  -DLLVM_PROFDATA_FILE=${TOPLEV}/stage2-prof-gen/profiles/clang.profdata \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_INSTALL_PREFIX=${TOPLEV}/stage2-prof-use-lto/install || (echo "Could not configure project!"; exit 1)

echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
