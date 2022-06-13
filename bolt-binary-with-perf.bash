#!/bin/bash

BOLTPATH=~/toolchain/llvm/stage1/bin
TOPLEV=~/toolchain/bolt
FDATA=${TOPLEV}/fdata
BINARY=zstd
BINARYPATH=/usr/bin/${BINARY}
BOLTBIN=${TOPLEV}/bin
mkdir -p ${FDATA}
mkdir -p ${BOLTBIN}

COMMAND="makepkg -s --skipinteg"

# Set here the number for the script you want to use
BOLT=

## The first task is just a example how you could record your profile with perf, actually you can also run at the end makepkg
##
if [ ${BOLT} = 1 ]; then

    perf record -o ${BOLTBIN}/${BINARY}-perf.data --max-size=2G -F 1500 -e cycles:u -j any,u -- ${COMMAND}

fi


if [ ${BOLT} = 2 ]; then

    echo "use perf2bolt to make the profile for llvm-bolt readable"
    ${BOLTPATH}/perf2bolt ${BINARY} \
        -p ${BOLTBIN}/${BINARY}-perf.data \
        -o ${BOLTBIN}/${BINARY}.fdata

    echo "Optimizing binary with generated profile"
    ${BOLTPATH}/llvm-bolt ${BINARYPATH} \
        --data ${BOLTBIN}/${BINARY}.fdata \
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
