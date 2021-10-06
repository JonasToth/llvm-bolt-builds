#!/bin/sh

set -e
set pipefail

BOLD=$(tput bold)
OFFBOLD=$(tput sgr0)
CYAN=$(tput setaf 12)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
OCKER=$(tput setaf 3)
WHITE=$(tput setaf 15)

echo "${BOLD}${CYAN}=== This script generates a bootstrapped, everything LLVM compiler${WHITE}${OFFBOLD}"
echo

cc_host=clang
cxx_host=clang++
ld_host=ldd

repo_dir="/fast_data2/llvm-project"
build_dir="/fast_data2/llvm-native-pgo"
enabled_projects="clang;clang-tools-extra;lld;compiler-rt;libunwind;libcxx;libcxxabi"
install_prefix="/usr"
install_destdir="/fast_data2/bootstrapped_result"
echo "${RED}--- general settings${WHITE}"
echo " * Repo directory: ${BOLD}${repo_dir}${OFFBOLD}"
echo " * Build directory: ${BOLD}${build_dir}${OFFBOLD}"
echo " * Install Prefix: ${BOLD}${install_prefix}${OFFBOLD}"
echo " * Install Destdir Prefix: ${BOLD}${install_destdir}${OFFBOLD}"
echo "${CYAN}--- stage1 settings${WHITE}"
echo " * C++-Compiler: ${BOLD}${cc_host}${OFFBOLD}"
echo " * C-Compiler: ${BOLD}${cxx_host}${OFFBOLD}"
echo " * Linker: ${BOLD}${ld_host}${OFFBOLD}"
echo " * Enabled LLVM Projects: ${BOLD}${enabled_projects}${OFFBOLD}"
echo " * Using C++17"

passthrough_args="LLVM_CXX_STD;CMAKE_INSTALL_PREFIX"
echo "${OCKER}--- stage2 passthrough arguments${WHITE}"
echo "${BOLD}${passthrough_args}${OFFBOLD}"
bs_stdlib="libc++"
bs_linker="lld"
bs_rtlib="compiler-rt"
bs_unwindlib="libunwind"
echo "${GREEN}--- stage2 bootstrap arguments${WHITE}"
echo " * BS-std-lib: ${BOLD}${bs_stdlib}${OFFBOLD}"
echo " * BS-linker: ${BOLD}${bs_linker}${OFFBOLD}"
echo " * BS-rt-lib: ${BOLD}${bs_rtlib}${OFFBOLD}"
echo " * BS-unwind-lib: ${BOLD}${bs_rtlib}${OFFBOLD}"
echo
bs_rtlib_use_libcxx="ON"
echo " * BS-compiler-rt-use-libcxx: ${BOLD}${bs_rtlib_use_libcxx}${OFFBOLD}"
echo
bs_libcxxabi_use_compiler_rt="ON"
bs_libcxxabi_use_llvm_unwinder="ON"
echo " * BS-libcxxabi-use-compiler-rt: ${BOLD}${bs_libcxxabi_use_compiler_rt}${OFFBOLD}"
echo " * BS-libcxxabi-use-llvm-unwinder: ${BOLD}${bs_libcxxabi_use_llvm_unwinder}${OFFBOLD}"
echo
bs_libcxx_use_compiler_rt="ON"
echo " * BS-libcxx-use-compiler-rt: ${BOLD}${bs_libcxx_use_compiler_rt}${OFFBOLD}"
echo
bs_libunwind_use_compiler_rt="ON"
echo " * BS-libunwind-use-compiler-rt: ${BOLD}${bs_libunwind_use_compiler_rt}${OFFBOLD}"
echo
bs_llvm_enable_libcxx="ON"
bs_llvm_enable_lld="ON"
bs_llvm_enable_lto="OFF"
bs_llvm_enable_modules="ON"
bs_llvm_parallel_compile=$(nproc)
bs_llvm_parallel_link=$(nproc)
echo " * BS-LLVM-enable_libcxx: ${BOLD}${bs_llvm_enable_libcxx}${OFFBOLD}"
echo " * BS-LLVM-enable_lld: ${BOLD}${bs_llvm_enable_lld}${OFFBOLD}"
echo " * BS-LLVM-enable-lto: ${BOLD}${bs_llvm_enable_lto}${OFFBOLD}"
echo " * BS-LLVM-enable-modules: ${BOLD}${bs_llvm_enable_modules}${OFFBOLD}"
echo " * BS-LLVM-parallel-compile: ${BOLD}${bs_llvm_parallel_compile}${OFFBOLD}"
echo " * BS-LLVM-parallel-link: ${BOLD}${bs_llvm_parallel_link}${OFFBOLD}"

echo
echo " - sleeping 2 seconds"
sleep 2

echo " - Switching to ${BOLD}${build_dir}${OFFBOLD}"
cd ${build_dir}

echo " - Configuring LLVM"

CC=${cc_host} \
CXX=${cxx_host} \
LD=${ld_host} \
cmake   -G Ninja \
        -DCMAKE_INSTALL_PREFIX=${install_prefix} \
        -DLLVM_ENABLE_PROJECTS=${enabled_projects} \
        -DLLVM_CXX_STD=c++17 \
        -DCLANG_ENABLE_BOOTSTRAP=ON \
        -DCLANG_BOOTSTRAP_PASSTHROUGH=${passthrough_args} \
        -DBOOTSTRAP_CLANG_DEFAULT_CXX_STDLIB=${bs_stdlib} \
        -DBOOTSTRAP_CLANG_DEFAULT_LINKER=${bs_linker} \
        -DBOOTSTRAP_CLANG_DEFAULT_RTLIB=${bs_rtlib} \
        -DBOOTSTRAP_CLANG_DEFAULT_UNWINDLIB=${bs_unwindlib} \
        -DBOOTSTRAP_COMPILER_RT_USE_LIBCXX=${bs_rtlib_use_libcxx} \
        -DBOOTSTRAP_LIBCXXABI_USE_COMPILER_RT=${bs_libcxxabi_use_compiler_rt} \
        -DBOOTSTRAP_LIBCXXABI_USE_LLVM_UNWINDER=${bs_libcxxabi_use_llvm_unwinder} \
        -DBOOTSTRAP_LIBCXX_USE_COMPILER_RT=${bs_libcxx_use_compiler_rt} \
        -DBOOTSTRAP_LIBUNWIND_USE_COMPILER_RT=${bs_libunwind_use_compiler_rt} \
        -DBOOTSTRAP_LLVM_ENABLE_LIBCXX=${bs_llvm_enable_libcxx} \
        -DBOOTSTRAP_LLVM_ENABLE_LLD=${bs_llvm_enable_lld} \
        -DBOOTSTRAP_LLVM_ENABLE_LTO=${bs_llvm_enable_lto} \
        -DBOOTSTRAP_LLVM_ENABLE_MODULES=${bs_llvm_enable_modules} \
        -DBOOTSTRAP_LLVM_PARALLEL_COMPILE_JOBS=${bs_llvm_parallel_compile} \
        -DBOOTSTRAP_LLVM_PARALLEL_LINK_JOBS=${bs_llvm_parallel_link} \
        ${repo_dir}/llvm || (echo "${BOLD}${RED}FAILED TO CONFIGURE BOOTSTRAPPED CLANG${WHITE}${OFFBOLD}"; exit 1)
echo "${BOLD}${GREEN}=== Successfully configured the bootstrap build${WHITE}${OFFBOLD}"

echo " - Running ${BOLD}ninja stage2${OFFBOLD}"
echo "   This compile the stage2 compiler with the bootstrap, but does not test it"
echo
ninja stage2 || (echo "${BOLD}${RED}FAILED TO BUILD BOOTSTRAPPED CLANG${WHITE}${OFFBOLD}"; exit 1)
echo "${BOLD}${GREEN}=== Successfully built a bootstrapped LLVM-only clang and llvm${WHITE}${OFFBOLD}"
echo

echo " - Runinng ${BOLD}ninja stage2-check-all${OFFBOLD}"
echo "   This will test the build compiler and LLVM and ensure everything is fine."
echo
ninja stage2-check-all || (echo "${BOLD}${RED}FAILED TO TEST BOOTSTRAPPED CLANG/LLVM${WHITE}${OFFBOLD}"; exit 1)
echo "${BOLD}${GREEN}=== Successfully tested the LLVM-only clang and llvm${WHITE}${OFFBOLD}"
echo

echo " - Installing final binaries into staging directory ${BOLD}${install_destdir}${OFFBOLD}"
DESTDIR=${install_destdir} ninja stage2-install || (echo "${BOLD}${RED}FAILED TO INSTALL BOOTSTRAPPED CLANG INTO STAGING DIRECTORY${WHITE}${OFFBOLD}"; exit 1)
echo "${BOLD}${GREEN}=== Successfully installed the LLVM-only clang into staging directory${WHITE}${OFFBOLD}"
echo

echo "${CYAN}${BOLD}You can check the final result in ${WHITE}${install_destdir}${OFFBOLD}"
echo " - Done."
