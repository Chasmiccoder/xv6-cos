#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"

// Fetch the uint64 at addr from the current process.
int
fetchaddr(uint64 addr, uint64 *ip)
{
  struct proc *p = myproc();
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    return -1;
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    return -1;
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Returns length of string, not including nul, or -1 for error.
int
fetchstr(uint64 addr, char *buf, int max)
{
  struct proc *p = myproc();
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    return -1;
  return strlen(buf);
}

static uint64
argraw(int n)
{
  struct proc *p = myproc();
  switch (n) {
  case 0:
    return p->trapframe->a0;
  case 1:
    return p->trapframe->a1;
  case 2:
    return p->trapframe->a2;
  case 3:
    return p->trapframe->a3;
  case 4:
    return p->trapframe->a4;
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
  *ip = argraw(n);
}

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
}

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
}

// Prototypes for the functions that handle system calls.
extern uint64 sys_fork(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_waitx(void); // TODO
extern uint64 sys_pipe(void);
extern uint64 sys_read(void);
extern uint64 sys_kill(void);
extern uint64 sys_exec(void);
extern uint64 sys_fstat(void);
extern uint64 sys_chdir(void);
extern uint64 sys_dup(void);
extern uint64 sys_getpid(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_sleep(void);
extern uint64 sys_uptime(void);
extern uint64 sys_open(void);
extern uint64 sys_write(void);
extern uint64 sys_mknod(void);
extern uint64 sys_unlink(void);
extern uint64 sys_link(void);
extern uint64 sys_mkdir(void);
extern uint64 sys_close(void);
extern uint64 sys_trace(void);  // added for implementing trace


// An array mapping syscall numbers from syscall.h
// to the function that handles the system call.
static uint64 (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_sleep]   sys_sleep,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
[SYS_waitx]   sys_waitx,  // TODO
[SYS_trace]   sys_trace,  // added for implementing trace
};

/ array to store information about each syscall 
struct syscall_info syscall_structs[] = 
{
[SYS_fork]    (struct syscall_info) {SYS_fork, 0,"fork"},
[SYS_exit]    (struct syscall_info) {SYS_exit, 1,"exit"},
[SYS_wait]    (struct syscall_info) {SYS_wait, 1,"wait"},
[SYS_pipe]    (struct syscall_info) {SYS_pipe, 1,"pipe"},
[SYS_read]    (struct syscall_info) {SYS_read, 3,"read"},
[SYS_kill]    (struct syscall_info) {SYS_kill, 1,"kill"},
[SYS_exec]    (struct syscall_info) {SYS_exec, 2,"exec"},
[SYS_fstat]   (struct syscall_info) {SYS_fstat, 2,"fstat"},
[SYS_chdir]   (struct syscall_info) {SYS_chdir, 1,"chdir"},
[SYS_dup]     (struct syscall_info) {SYS_dup, 1,"dup"},
[SYS_getpid]  (struct syscall_info) {SYS_getpid, 0,"getpid"},
[SYS_sbrk]    (struct syscall_info) {SYS_sbrk, 1,"sbrk"},
[SYS_sleep]   (struct syscall_info) {SYS_sleep, 1,"sleep"},
[SYS_uptime]  (struct syscall_info) {SYS_uptime, 0,"uptime"},
[SYS_open]    (struct syscall_info) {SYS_open, 2,"open"},
[SYS_write]   (struct syscall_info) {SYS_write, 3,"write"},
[SYS_mknod]   (struct syscall_info) {SYS_mknod, 3,"mknod"},
[SYS_unlink]  (struct syscall_info) {SYS_unlink, 1,"unlink"},
[SYS_link]    (struct syscall_info) {SYS_link, 2,"link"},
[SYS_mkdir]   (struct syscall_info) {SYS_mkdir, 1,"mkdir"},
[SYS_close]   (struct syscall_info) {SYS_close, 1,"close"},
[SYS_trace]   (struct syscall_info) {SYS_trace, 1,"trace"},
};

// Function called to print trace info
void 
print_trace(struct proc* p, int syscall_num)
{
  printf("%d: syscall %s (", p->pid, syscall_structs[syscall_num].name);

  int curr_arg;
  // Print arguments
  for(int i=0; i<syscall_structs[syscall_num].num_args; i++)
  {
    argint(i, &curr_arg);
    printf("%d", curr_arg);
    if (i != syscall_structs[syscall_num].num_args - 1) {
      printf(" ");
    }
    else
    {
      printf(")");
    }
  }
  printf(" -> %d\n", p->trapframe->a0);
}

////////////////////////////////////////////////////////////////////////

void
syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();

    // (xv6-cos)
    if ((p->trace_mask & (1<<num)) !=0)
    {
      print_trace(p, num);
    }

  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
