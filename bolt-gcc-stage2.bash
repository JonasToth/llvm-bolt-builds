#!/bin/bash

export TOPLEV=~/toolchain/gcc
mkdir ${TOPLEV}
cd ${TOPLEV}

mkdir -p ${TOPLEV}/bolt-gcc/intrumentdata || (echo "Could not create stage3-bolt directory"; exit 1)
cd ${TOPLEV}/bolt-gcc
GCCPATH=/usr/lib/gcc/x86_64-pc-linux-gnu/12.1.1
GCCINSTPATH=${TOPLEV}/bolt-gcc
BOLTPATH=~/toolchain/llvm/stage1/bin


echo "Merging generated profiles"
cd ${TOPLEV}/bolt-gcc/intrumentdata/cc1
${BOLTPATH}/merge-fdata *.fdata > cc1-combined.fdata
cd ${TOPLEV}/bolt-gcc/intrumentdata/cc1plus
${BOLTPATH}/merge-fdata *.fdata > cc1plus-combined.fdata

echo "Optimizing cc1 with the generated profile"

cd ${TOPLEV}/bolt-gcc/intrumentdata/cc1/

${BOLTPATH}/llvm-bolt ${GCCPATH}/cc1.org \
    --data ${TOPLEV}/bolt-gcc/intrumentdata/cc1/cc1-combined.fdata \
    -o cc1 \
	-relocs -split-functions=3 -split-all-cold -icf=1 -lite=1 \
	-split-eh -use-gnu-stack -jump-tables=move -dyno-stats \
	-reorder-functions=hfsort -reorder-blocks=ext-tsp -tail-duplication=cache || (echo "Could not optimize binary for cc1"; exit 1)

echo "mooving bolted binary"
sudo mv cc1 ${GCCPATH}/cc1


${BOLTPATH}/llvm-bolt ${GCCPATH}/cc1plus.org \
    --data ${TOPLEV}/bolt-gcc/intrumentdata/cc1plus/cc1plus-combined.fdata \
    -o cc1plus \
	-relocs -split-functions=3 -split-all-cold -icf=1 -lite=1 \
	-split-eh -use-gnu-stack -jump-tables=move -dyno-stats \
	-reorder-functions=hfsort -reorder-blocks=ext-tsp -tail-duplication=cache || (echo "Could not optimize binary for cc1plus"; exit 1)

sudo mv cc1plus ${GCCPATH}/cc1plus
