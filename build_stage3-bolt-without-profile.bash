#!/bin/bash
CPATH="$(pwd)/stage2-prof-use-lto-reloc/install/bin"
export TOPLEV=~/toolchain/llvm
CPATH=${TOPLEV}/stage2-prof-use-lto/install/bin/

export ${TOPLEV}/stage1/install/bin/:${PATH}

echo "Bolting Clang"

llvm-bolt ${CPATH}/clang-14 \
	-o ${CPATH}/clang-14.bolt \
	--mcf-use-rarcs \
	--reorder-functions=pettis-hansen \
	--peepholes=double-jumps \
	--peepholes=useless-branches \
	--reorder-blocks=cache+ \
	--split-all-cold \
	--icf \
	--dyno-stats
