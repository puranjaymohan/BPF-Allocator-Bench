#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

char LICENSE[] SEC("license") = "Dual BSD/GPL";

SEC("tp/syscalls/sys_enter_getpgid")
int handle_tp1(void *ctx)
{
	int pid = bpf_get_current_pid_tgid() >> 32;

	bpf_printk("sys_enter_getpgid triggered from PID %d.\n", pid);

	return 0;
}

SEC("tp/syscalls/sys_enter_getgid")
int handle_tp2(void *ctx)
{
	int pid = bpf_get_current_pid_tgid() >> 32;

	bpf_printk("sys_enter_getgid triggered from PID %d.\n", pid);

	return 0;
}

SEC("tp/syscalls/sys_enter_getuid")
int handle_tp3(void *ctx)
{
	int pid = bpf_get_current_pid_tgid() >> 32;

	bpf_printk("sys_enter_getuid triggered from PID %d.\n", pid);

	return 0;
}

SEC("tp/syscalls/sys_enter_getpriority")
int handle_tp4(void *ctx)
{
	int pid = bpf_get_current_pid_tgid() >> 32;

	bpf_printk("sys_enter_getpriority triggered from PID %d.\n", pid);

	return 0;
}

SEC("tp/syscalls/sys_enter_geteuid")
int handle_tp5(void *ctx)
{
	int pid = bpf_get_current_pid_tgid() >> 32;

	bpf_printk("sys_enter_geteuid triggered from PID %d.\n", pid);

	return 0;
}

SEC("tp/syscalls/sys_enter_openat")
int handle_tp6(void *ctx)
{
	int pid = bpf_get_current_pid_tgid() >> 32;

	bpf_printk("sys_enter_getpgid triggered from PID %d.\n", pid);

	return 0;
}

SEC("kprobe/do_unlinkat")
int BPF_KPROBE(do_unlinkat, int dfd, struct filename *name)
{
        pid_t pid;
        const char *filename;

        pid = bpf_get_current_pid_tgid() >> 32;
        filename = BPF_CORE_READ(name, name);
        bpf_printk("KPROBE ENTRY pid = %d, filename = %s\n", pid, filename);
        return 0;
}

SEC("kretprobe/do_unlinkat")
int BPF_KRETPROBE(do_unlinkat_exit, long ret)
{
        pid_t pid;

        pid = bpf_get_current_pid_tgid() >> 32;
        bpf_printk("KPROBE EXIT: pid = %d, ret = %ld\n", pid, ret);
        return 0;
}
