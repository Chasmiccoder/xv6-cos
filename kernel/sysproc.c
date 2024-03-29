#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

// (xv6-cos)
uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc* p = myproc();
  if(copyout(p->pagetable, addr1, (char*)&wtime, sizeof(int)) < 0)
    return -1;
  if(copyout(p->pagetable, addr2, (char*)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// (xv6-cos)
// adding trace syscall
uint64
sys_trace(void)
{
  // set trace mask as the 0th argument
  int mask; 
  argint(0, &mask);
  myproc()->trace_mask = mask;
  return 0;
}

// (xv6-cos)
uint64
sys_set_priority(void)
{
  int priority, pid;
  argint(0, &priority);
  argint(1, &pid);

  int old_static_priority = set_priority(priority, pid);
  return old_static_priority;
}

// (xv6-cos)
uint64
sys_settickets(void)
{
  int tickets, pid;

  argint(0, &tickets);
  argint(1, &pid);
  pid = settickets(pid, tickets);
  return pid;
}

// (xv6-cos)
int
sys_sigalarm(void)
{
  int ticks;
  void (*handler)();

  argint(0, &ticks);
  argaddr(1, (uint64*)&handler);

  myproc()->alarm_handler = handler;
  myproc()->alarm_ticks = ticks;
  myproc()->alarm_ticks_left = ticks;
  myproc()->alarm_flag = 0;

  return 0;
}

// (xv6-cos)
int
sys_sigreturn(void)
{
  // get current process and restore trapframe
  struct proc *p = myproc();
  memmove(p->trapframe, p->alarm_saved_tf, sizeof(struct trapframe));

  // (*p->trapframe) = p->alarm_saved_tf;

  // free alarm trapframe
  kfree(p->alarm_saved_tf);

  // reset alarm-related fields
  // p->alarm_saved_tf = 0;
  p->alarm_flag = 0;

  return p->trapframe->a0;
}