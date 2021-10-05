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

- the build is always done once to ensure everything is fine and there is no
  interference with configuration times, ...
- build was setup using:
```
$ BUILD_DIR=optimized \
  ./Project/Linux/build.sh build_release_clang7_cxx17 \
        -DWITH_NODEJS=OFF \
        -DWITH_MODULE_RTCVS=OFF
```
- after that ``cd $build_dir; ninja clean; time ninja``

### clang-7-cxx17 on AWS 36 core machine

- compiler package from apt.llvm.org, living in `/usr/lib/llvm-7/`
```
$ time ninja #std1
> real    10m46.662s   == 646,662s
> user    333m25.929s  == 20005,929s
> sys     13m17.211s   == 797,211

$ ninja clean; time ninja # std2
> real    10m52.052s   == 652,052s
> user    331m46.688s  == 19906,688s
> sys     13m9.674s    == 789,674s
```

### generic-optimized-clang-7-cxx17 on AWS 36 core machine

- compiler trained on the compiler itself
```
$ time ninja # opt1
> real    8m33.118s    == 511,118s
> user    258m39.663s  == 15519,663s
> sys     11m38.800s   == 698,8s

$ ninja clean; time ninja # opt2
> real    8m31.632s    == 511,632s
> user    258m40.521s  == 15520,521s
> sys     11m36.805s   == 696,805s
```
- compiler was used with manual patching of `./Project/Linux/buildsteps.sh`
  to use the custom build compiler, which was uploaded as a tar.gz

#### Speedup to normal builds

Using the fastest builds

```
$ {real,user,sys}_std2 / {real,user,sys}_opt2
> real  = 1,275736718
> user  = 1,282675275
> sys   = 1,130042931
```

### rtc-platform-optimized-clang-7-cxx17
