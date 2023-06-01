# BPF-Allocator-Bench
This is a makeshift program that stresses the BPF JIT memory allocator and
measures TLB performance.
It uses biolerplate from
[libbpf-bootstrap](https://github.com/libbpf/libbpf-bootstrap) for building BPF
programs.

It has a stress.bpf.c file that includes 8 BPF programs (6 tp and 2 kprobe).
The userspace stress.c program loads the BPF programs and then triggeres 5 of
them continously in a infinite loop by doing system calls.

The run.sh wrapper program starts 20 instances of the above stress program which
technically loads 8 * 20 = 160 BPF programs on the system out of which 5 * 20 =
100 are continously triggered.

The run.sh program takes a command as an argument that it runs after doing the
above setup.
For example to measure the TLB metrics we can run the program like:

```
./run.sh "perf stat -e ITLB_WALK,L1I_TLB,INST_RETIRED,iTLB-load-misses -a --timeout 60000"
```

Running the above with different BPF memory allocators will show the differences
in their performance.
