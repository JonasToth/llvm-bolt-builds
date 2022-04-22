# Benchmarking with script ./measure_build.bash

### LLVM 13 STOCK ARCH

```
== Start Build
[2529/2529] Creating executable symlink bin/clang

real    7m9,064s
user    154m7,218s
sys     4m20,882s

```

### Stage1 LLVM 15 PGO+THINLTO+BOLT without branch sampling (perf):

```
[2529/2529] Creating executable symlink bin/clang

real    4m26,656s
user    96m17,866s
sys     3m41,900s
```

### LLVM 15 PGO+THINLTO+BOLT with perf

```
[2529/2529] Creating executable symlink bin/clang

real    4m12,346s
user    88m10,566s
sys     3m28,353s
```
