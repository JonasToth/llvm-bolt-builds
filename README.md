# How does it work

This set of scripts creates a 60% faster LLVM toolchain that can be customly
trained to any project.

For them to function it expects the following directory structure:

-   SomeBaseDir/
    -   multistage-build/README.md (this file and all scripts must live here!)
    -   llvm-project (created by `setup_llvm_repo.bash`), LLVM Monorepo

## How to build

```bash
$ cd SomeBaseDir/
$ # get these files here somehow, git clone or whatever distribution method

$ # This will setup the mono-repo, built llvm-bolt separatly and then
$ # start a multi-stage LLVM build with the latest stable release.
$ ./full_workflow.bash
$ # Note: For the last build-stage you need `perf` to function properly.
$ #       Try out `perf record -e cycles:u -j any,u -- sleep 1`
$ #       to check that you CPU and Linux does expose the necessary performance
$ #       counters.
$ #       If that is not the case, you don't need the final BOLT stage. Your
$ #       Toolchain will still be faster.
```

This sequence will give you (hopefully) a faster LLVM toolchain.
Technologies used:

-   LLVM Link Time Optimization (LTO)
-   Binary Instrumentation and Profile-Guided-Optimization (PGO)
-   perf-measurement and branch-sampling and final binary reordering (BOLT)

The goal of the techniques is to utilize the CPU black magic better and layout
the code in a way, that allows faster execution.

Measure performance gains and evaluate if its worth the hazzle :)
You can experiment with technologies, maybe `ThinLTO` is better then `FullLTO`,
....
There are more `stage2-*` scripts available that can be modified to your needs.
For the last bit of performance, train the `stage2-pgo` for your own project
and nothing else! The same goes for `BOLT`.
