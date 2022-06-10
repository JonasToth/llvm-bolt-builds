#!/bin/bash

GCCVER=12
TOPLEV=~/toolchain/gcc
DATA=${TOPLEV}/instrument
mkdir ${TOPLEV}
cd ${TOPLEV}
mkdir -p ${DATA}/cc1
mkdir -p ${DATA}/cc1plus
GCCPATH=/usr/lib/gcc/x86_64-pc-linux-gnu/${GCCVER}
BOLTPATH=~/toolchain/llvm/stage1/bin


echo "Instrument clang with llvm-bolt"

${BOLTPATH}/llvm-bolt \
    --instrument \
    --instrumentation-file-append-pid \
    --instrumentation-file=${DATA}/cc1/cc1.fdata \
    ${GCCPATH}/cc1 \
    -o ${DATA}/cc1/cc1

${BOLTPATH}/llvm-bolt \
    --instrument \
    --instrumentation-file-append-pid \
    --instrumentation-file=${DATA}/cc1plus/cc1plus.fdata \
    ${GCCPATH}/cc1plus \
    -o ${DATA}/cc1plus/cc1plus

#echo "mooving instrumented binary"
#sudo mv ${GCCPATH}/cc1 ${GCCPATH}/cc1.org
#sudo mv ${DATA}/cc1/cc1 ${GCCPATH}/cc1
#echo "mooving instrumented binary"
#sudo mv ${GCCPATH}/cc1plus ${GCCPATH}/cc1plus.org
#sudo mv ${DATA}/cc1plus/cc1plus ${GCCPATH}/cc1plus

echo "Now move the binarys to the gcc path"
echo "now do some instrument compiles for example compiling a kernel or GCC"
