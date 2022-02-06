#!/bin/bash
BASE_DIR=$(pwd)
CPATH="$(pwd)/stage1/install/bin"

mkdir -p stage2-prof-use-lto-reloc || (echo "Could not create stage2-prof-use-lto-reloc directory"; exit 1)
cd stage2-prof-use-lto-reloc

echo "== Configure Build"
echo "== Build with stage1-tools -- $CPATH"
echo "== Build includes bolt-enabled relocations"

CC=${CPATH}/clang CXX=${CPATH}/clang++ LD=${CPATH}/lld \
	cmake 	-G Ninja \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install" \
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
	-DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	-DCOMPILER_RT_BUILD_XRAY=OFF \
	-DCOMPILER_RT_BUILD_LIBFUZZER=OFF  \
	-DLLVM_ENABLE_LTO=THIN \
    -DCMAKE_CXX_FLAGS="-O3 -march=native -m64 -mavx -fomit-frame-pointer" \
    -DCMAKE_C_FLAGS="-O3 -march=native -m64 -mavx -fomit-frame-pointer" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--as-needed -Wl,--build-id=sha1 -Wl,--emit-relocs" \
    -DENABLE_LINKER_BUILD_ID=ON \
	-DLLVM_ENABLE_PROJECTS="clang;lld;compiler-rt" \
	-DLLVM_PARALLEL_COMPILE_JOBS="$(nproc)"\
	-DLLVM_PARALLEL_LINK_JOBS="$(nproc)" \
	-DLLVM_PROFDATA_FILE=${BASE_DIR}/stage2-prof-generate/profiles/clang.prof \
	-DLLVM_TARGETS_TO_BUILD="X86" \
	-DLLVM_TOOL_CLANG_BUILD=ON \
	-DLLVM_TOOL_LLD_BUILD=ON \
  	../llvm-project/llvm || (echo "Could not configure project!"; exit 1)

echo
echo "== Start Build"
ninja || (echo "Could not build project!"; exit 1)

echo
echo "== Install to $(pwd)/install"
ninja install || (echo "Could not install project!"; exit 1)
