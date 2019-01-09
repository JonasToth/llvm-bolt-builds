# Experimental results

measure on login01, on multiple days, not too scientific but reproduced twice

## clang target

### Created Stage1 Compiler

- after `sync`: clang 643.48 seconds

### Created Stage2 PGO+FullLTO Compiler

- after `sync`: clang 479.43 seconds (+34%)

### Created Stage2 PGO+FullLTO+Bolt clang and lld

- after `sync`: clang 404.17 seconds (+59% stage1, +18% stage2 PGO+FullLTO)

## rtc-platform target

### Building with clang-4.0

ca. 1h
