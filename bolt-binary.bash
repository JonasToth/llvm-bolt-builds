#!/bin/bash

BOLTPATH=~/toolchain/llvm/stage1/bin
TOPLEV=~/toolchain/bolt
FDATA=${TOPLEV}/fdata
BINARY=zstd
BINARYPATH=/usr/bin/${BINARY}
BOLTBIN=${TOPLEV}/bin
mkdir -p ${FDATA}
mkdir -p ${BOLTBIN}


# Set here the number for the script you want to use
BOLT=


if [ ${BOLT} = 1 ]; then

echo "Instrument binary with llvm-bolt"

${BOLTPATH}/llvm-bolt \
    --instrument \
    --instrumentation-file-append-pid \
    --instrumentation-file=${FDATA}/${BINARY}.fdata \
    ${BINARYPATH} \
    -o ${BOLTBIN}/${BINARY}
echo "Now run a workload with the instrumented binary"

fi

if [ ${BOLT} = 2 ]; then
echo "Merging generated profiles"
${BOLTPATH}/merge-fdata ${FDATA}/${BINARY}*.fdata > ${BOLTBIN}/${BINARY}-combined.fdata

echo "Optimizing binary with generated profile"
${BOLTPATH}/llvm-bolt ${BINARYPATH} \
    --data ${BOLTBIN}/${BINARY}-combined.fdata \
    -o ${BOLTBIN}/${BINARY}.bolt \
    -relocs \
    -split-functions=3 \
    -split-all-cold \
    -icf=1 \
    -lite=1 \
    -split-eh \
    -use-gnu-stack \
    -jump-tables=move \
    -dyno-stats \
    -reorder-functions=hfsort \
    -reorder-blocks=ext-tsp \
    -tail-duplication=cache || (echo "Could not optimize the binary"; exit 1)

echo "You can find now your optimzed binary at ${BOLTBIN}"

fi
