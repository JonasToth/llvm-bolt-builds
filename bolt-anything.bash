#!/bin/bash

## PATH where llvm-bolt is
BOLTPATH=~/toolchain/llvm/stage1/install/bin
# BASEPATH
TOPLEV=~/toolchain/bolt
## PATH FOR INTRUMENTED DATA
FDATA=${TOPLEV}/fdata
## file/binary you want to bolt
BINARY=zstd
## PATH OF the binary/file
BINARYPATH=/usr/bin
## PATH where the bolted binary/file can be found
BOLTBIN=${TOPLEV}/bin

# Set here the number for the script you want to use
STAGE=

mkdir -p ${FDATA}
mkdir -p ${BOLTBIN}

check_requirements() {
    readelf -p .rela.text ${BINARYPATH}/${BINARY}
}

check_reloc=$(readelf -p .rela.text ${BINARYPATH}/${BINARY} | grep ".rela.text")

instrument() {
    echo "Instrument binary with llvm-bolt"

    ${BOLTPATH}/llvm-bolt \
        --instrument \
        --instrumentation-file-append-pid \
        --instrumentation-file=${FDATA}/${BINARY}.fdata \
        ${BINARYPATH}/${BINARY} \
        -o ${BOLTBIN}/${BINARY}

    sudo mv ${BINARYPATH}/${BINARY} ${BINARYPATH}/${BINARY}.org
    sudo cp ${BOLTBIN}/${BINARY} ${BINARYPATH}/${BINARY}
}

optimize() {
    echo "Merging generated profiles"
    ${BOLTPATH}/merge-fdata ${FDATA}/${BINARY}*.fdata > ${BOLTBIN}/${BINARY}-combined.fdata

    echo "Optimizing binary with generated profile"
    ${BOLTPATH}/llvm-bolt ${BINARYPATH}/${BINARY}.org \
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
    sudo rm -rf ${FDATA}/${BINARY}.fdata*
    sudo cp ${BOLTBIN}/${BINARY}.bolt ${BINARYPATH}/${BINARY}
}



if [ "$(echo "${check_requirements}" | grep -i rela.text)" = "rela.text" ]; then

    echo "Your binary/file needs relocations, recompile it with --emit-relocs"

else

    if [ ${STAGE} = 1 ]; then
        instrument
    fi

fi

if [ ${STAGE} = 2 ]; then
    optimize
fi
