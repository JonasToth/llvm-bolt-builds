#!/bin/bash

BASE_DIR=$(pwd)
STAGE_ONE="$(pwd)/stage1/install/bin"
CPATH="$(pwd)/stage2-prof-use-lto-reloc/install/bin"

# Do the bolt-processing of the binary.
export PATH="${STAGE_ONE}:$PATH"

echo "Bolting Clang"

llvm-bolt ${CPATH}/clang-14 \
	-o ${CPATH}/clang-14.bolt \
	--jt-footprint-optimize-for-icache \
	--jt-footprint-reduction \
	--mcf-use-rarcs \
	--reorder-functions=pettis-hansen \
	--peepholes=double-jumps \
	--peepholes=useless-branches \
	--reorder-blocks=cache+ \
	--split-all-cold \
	--icf \
	--dyno-stats

echo "Bolting LLD"

llvm-bolt ${CPATH}/lld \
	-o ${CPATH}/lld.bolt \
	--jt-footprint-optimize-for-icache \
	--jt-footprint-reduction \
	--mcf-use-rarcs \
	--reorder-functions=pettis-hansen \
	--peepholes=double-jumps \
	--peepholes=useless-branches \
	--reorder-blocks=cache+ \
	--split-all-cold \
	--icf \
	--dyno-stats
