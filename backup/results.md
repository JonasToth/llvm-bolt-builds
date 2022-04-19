# Benchmarking with script ./measure_build.bash

## Linux CachyOS 5.17.0-rc1-0.2-cachyos-rc-lto #1 SMP PREEMPT Sun, 30 Jan 2022 03:38:16 +0000 x86_64 GNU/Linux All Core OC 4650 MHz 1.3 V

### Stock LLVM 13.0.0 arch built with THINLTO + Clang:

```
== Start Build
[2477/2477] Creating executable symlink bin/clang

real    6m46.736s
user    152m19.362s
sys     4m58.632s

406 Seconds
```

### Stage1 LLVM14 Compiler:

```
== Start Build
[2477/2477] Creating executable symlink bin/clang

real    6m54.555s
user    152m38.307s
sys     4m34.412s

414 Seconds

Differnce to Stock:
-1.932367149758454 %
```

### LLVM THINLTO + PGO (stage2-lto-prof-use-reloc)

```
== Start Build
[2477/2477] Creating executable symlink bin/clang

real 4m50.353s
user 107m10.248s
sys 4m30.552s
290 Seconds
Difference to Stock:
+28.57142857142857%
```

### LLVM THINLTO + PGO (stage2-lto-prof-use-reloc) + bolted without perf profile with command:

```
/home/ptr1337/repo/llvm-bolt/build-bolt/bin/llvm-bolt /home/ptr1337/repo/llvm-bolt/llvm-bolt-builds/stage2-prof-use-lto-reloc/install/bin/clang-14 -o /home/ptr1337/repo/llvm-bolt/llvm-bolt-builds/stage2-prof-use-lto-reloc/install/bin/clang-14.bolt --instrument-hot-only --jt-footprint-optimize-for-icache --jt-footprint-reduction --mcf-use-rarcs --reorder-functions=pettis-hansen --peepholes=double-jumps --peepholes=useless-branches --reorder-blocks=cache+ --split-all-cold --icf --dyno-stats
```

Result:

```
== Start Build
[2477/2477] Creating executable symlink bin/clang

real    4m46.036s
user    105m27.390s
sys     4m26.167s

286 Seconds

Difference to Stock:
+29.55665024630542%
Difference bolted binary without perf record profile to stage2-reloc:
+1.3793103448275863%
```
