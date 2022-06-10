#!/bin/bash

GCCVER=12.1.1
TOPLEV=~/toolchain/gcc
DATA=${TOPLEV}/instrument
mkdir ${TOPLEV}
cd ${TOPLEV}
GCCPATH=/usr/lib/gcc/x86_64-pc-linux-gnu/${GCCVER}
BOLTPATH=~/toolchain/llvm/stage1/bin


echo "Merging generated profiles"
cd ${DATA}/cc1
${BOLTPATH}/merge-fdata *.fdata > cc1-combined.fdata
cd ${DATA}/cc1plus
${BOLTPATH}/merge-fdata *.fdata > cc1plus-combined.fdata

echo "Optimizing cc1 with the generated profile"

cd ${TOPLEV}
${BOLTPATH}/llvm-bolt ${GCCPATH}/cc1.org \
    --data ${DATA}/cc1/cc1-combined.fdata \
    -o ${TOPLEV}/cc1 \
    -relocs \
    -split-functions=3 \
    -split-all-cold \
    -icf=1 \
    -lite=1 \
    -split-eh -use-gnu-stack \
    -jump-tables=move \
    -dyno-stats \
    -reorder-functions=hfsort
-reorder-blocks=ext-tsp
-tail-duplication=cache || (echo "Could not optimize binary for cc1"; exit 1)

cd ${TOPLEV}
${BOLTPATH}/llvm-bolt ${GCCPATH}/cc1plus.org \
    --data ${DATA}/cc1plus/cc1plus-combined.fdata \
    -o ${TOPLEV}/cc1plus \
    -relocs \
    -split-functions=3 \
    -split-all-cold \
    -icf=1 \
    -lite=1 \
    -split-eh -use-gnu-stack \
    -jump-tables=move \
    -dyno-stats \
    -reorder-functions=hfsort
-reorder-blocks=ext-tsp
-tail-duplication=cache || (echo "Could not optimize binary for cc1"; exit 1)


#echo "mooving bolted binary"
#sudo mv ${TOPLEV}/cc1 ${GCCPATH}/cc1
#sudo mv ${TOPLEV}/cc1plus ${GCCPATH}/cc1plus

echo "Now you can move the bolted binarys to your ${GCCPATH}"
