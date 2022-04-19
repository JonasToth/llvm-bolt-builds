#!/bin/bash
jobs="$(echo $(( $(nproc) * 4/4 )) | cut -d '.' -f1)"
BASE_DIR=$(pwd)
CPATH="$(pwd)/stage1/install/bin"

mkdir -p stage2-prof-use-lto-reloc || (echo "Could not create stage2-prof-use-lto-reloc directory"; exit 1)
cd stage2-prof-use-lto-reloc

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"
echo "== Build includes bolt-enabled relocations"
export LDFLAGS="-Wl,-q"
CC=${CPATH}/clang CXX=${CPATH}/clang++ LD=${CPATH}/lld \
	cmake 	-G Ninja \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
  -DLLVM_HOST_TRIPLE="x86_64-pc-linux-gnu" \
	-DCLANG_ENABLE_ARCMT=OFF \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DCLANG_PLUGIN_SUPPORT=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_DOCS=OFF \
	-DCLANG_VENDOR="Clang-BOLT" \
	-DLLVM_ENABLE_LLD=ON \
	-DLLVM_ENABLE_LTO=THIN \
  -DENABLE_LINKER_BUILD_ID=ON \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt;polly" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(jobs)" \
	-DLLVM_PARALLEL_LINK_JOBS="$(jobs)" \
	-DLLVM_PROFDATA_FILE=${BASE_DIR}/stage2-prof-generate/profiles/clang.prof \
	-DLLVM_TARGETS_TO_BUILD="all" \
	-DLLVM_TOOL_CLANG_BUILD=ON \
	-DCMAKE_INSTALL_PREFIX=${BASE_DIR}/stage2-prof-use-lto-reloc/install \
	-DLLVM_TOOL_LLD_BUILD=ON \
  	../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo
echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
