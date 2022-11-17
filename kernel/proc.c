#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

// (xv6-cos)
struct proc *mlfq[NMLFQ][NPROC];
int mlfq_lengths[NMLFQ]; // number of elements in each queue
int mlfq_rears[NMLFQ]; // rear pointers of all queues

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
  }

  // initialize the MLFQ on boot
  for(int i = 0; i < NMLFQ; i++) {
    mlfq_lengths[i] = 0;
    mlfq_rears[i] = 0;
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  // (xv6-cos)
  // initialize the process' parameters
  p->rtime = 0;
  p->etime = 0;
  p->ctime = ticks;
  
  // for priority based scheduling
  p->static_priority = 60; // by default 
  p->when_started_sleeping = 0;
  p->sleep_time = 0;

  // for lottery based scheduling
  p->tickets = 1; // by default

  // for multilevel feedback scheduling
  p->queue_id = 0; // the process is in the queue with most priority by default
  // p->last_wait_time = 0;
  p->inqueue = 0; // the process is not in the queue initially
  // p->
  
  p->state = USED;

  p->alarm_flag = 0;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;

  // (xv6-cos)
  p->trace_mask = 0;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // (xv6-cos) for Lottery Based Scheduling
  np->tickets = 1; // by default

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  // (xv6-cos)
  // child process inherits trace mask from parent.
  np->trace_mask = p->trace_mask;

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  p->etime = ticks; // update the exit time of the process

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// (xv6-cos)
// similar to wait, but returns the wait time and running time of the child process
int
waitx(uint64 addr, uint* wtime, uint* rtime)
{
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(pp = proc; pp < &proc[NPROC]; pp++){
      if(pp->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);

        havekids = 1;
        if(pp->state == ZOMBIE){
          // Found one.
          pid = pp->pid;

          *rtime = pp->rtime;
          *wtime = pp->etime - pp->ctime - pp->rtime;          

          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(pp);
          release(&pp->lock);
          release(&wait_lock);
          return pid;
        }
        release(&pp->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// (xv6-cos)
void
update_time()
{
  /*
  Updates a process' running time and the last time it waited
  The last time aspect is used to assist aging during MLFQ scheduling
  */

  struct proc* p;
  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == RUNNING) {
      p->rtime++;
    } else if(p->state == SLEEPING) {
      if(SCHEDULING_ALGO == 4) {
        p->last_wait_time++;
      }
    } else if(p->state == RUNNABLE) {
      if(SCHEDULING_ALGO == 4) {
        p->last_wait_time++;
      }
    }
    release(&p->lock);
  }
}

// (xv6-cos)
int
set_priority(int priority, int pid)
{
  /*
  Used for PBS Scheduling
  Iterates through all the processes and finds a process p with the matching pid
  Then it updates its priority
  */

  struct proc *p;
  int old_static_priority = 0;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->pid == pid) {
      old_static_priority = p->static_priority;
      p->static_priority = priority;
    }
    release(&p->lock);
  }

  return old_static_priority;
}

// (xv6-cos)
int 
settickets(int number, int pid)
{
  /*
  Used in LBS Scheduling
  Overwrites the tickets held by a process
  */
  struct proc *p = myproc();
  p->tickets = number;
  return pid;
}

int custom_random(unsigned long *ctx) {
    /*
    * Taken from the do_rand() function in user/grind.c
    * 
    * Compute x = (7^5 * x) mod (2^31 - 1)
    * without overflowing 31 bits:
    *      (2^31 - 1) = 127773 * (7^5) + 2836
    * From "Random number generators: good ones are hard to find",
    * Park and Miller, Communications of the ACM, vol. 31, no. 10,
    * October 1988, p. 1195.
    */

    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
    hi = x / 127773;
    lo = x % 127773;
    x = 16807 * lo - 2836 * hi;
    if (x < 0)
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
    *ctx = x;
    return (x);
}

int is_the_process_lucky(float probability) {
    /*

    This function first generates a random number from [0, LONG_MAX - 2], which is good enough
    Using the number of ticks as a seed

    The lottery based probability is passed as an argument to this function
    This probability is scaled to match the range [0, LONG_MAX - 2] from probability to scaled_prob
    If the random number generated is lesser than or equal to the scaled probability, 
    then the process is given the cpu
    */

    long unsigned seed = ticks % (2147483647 - 2);
    int r = custom_random(&seed);

    float scaled_prob = (float) probability * (2147483647 - 2);

    if(r < scaled_prob) {
        return 1;
    } else {
        return 0;
    }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.xl
void
scheduler(void)
{
  /*
  How preemption and nonpreemption work -
  RR is preemptive - since swtch is inside for(p = proc ...), context switch happens 
  (after every 100 ms, by default)
  
  In non-preemptive algos like FCFS and PBS, the swtch happens outside the for(p = proc ...) loop, 
  which selects a process first, and then does swtch. It runs the process throughout the time 
  quantum (100ms), and then we reach the next iteration of for(;;)
  The scheduler picks the same process over and over again (through its protocol [FCFS/PBS]),
  until the process gets completed (after which the next process is chosen)
  */

  // (xv6-cos)
  struct proc *p;                                                   // used to iterate over all processes in the process table proc
  struct cpu *c = mycpu();                                          // pick the cpu for which the process will run on
  c->proc = 0;                                                      // setting the cpu's process to null initially

  if(SCHEDULING_ALGO == 0) {                                        // Round Robin Scheduling (default)
  
    for(;;){
      intr_on();                                                    // avoid deadlock by ensuring that devices can interrupt

      for(p = proc; p < &proc[NPROC]; p++) {                        // iterate through the process table and for each process,
        acquire(&p->lock);                                          // acquire a lock and run it for 1 time quantum (handled by swtch)
        
        if(p->state == RUNNABLE) {
          p->state = RUNNING;                                       // Switch to chosen process. It is the process's job to release 
          c->proc = p;                                              // its lock and then reacquire it before jumping back to us.
          swtch(&c->context, &p->context);
          
          // Process is done running for now.
          // It should have changed its p->state before coming back.
          c->proc = 0;
        }
        
        release(&p->lock);
      }
    }
  } else if(SCHEDULING_ALGO == 1) {                                 // First Come First Serve    
    /*
    How this works -
    Once we've identified that FCFS is to be used, the function runs the infinite for loop for(;;)
    
    Then, we loop over all processes to find a process with the least creation time
    
    In the first iteration of for(p = proc ...), the process seen is set as the process that has come first (first_come_process)
    Then, the rest of the process creation times are checked
    Any time we find a process with a lower creation time, first_come_process gets updated,
    and at the end of for(p = proc ...) we would have found the process with the least creation time

    Then, this process' state is changed to RUNNING, and it is assigned the CPU 
    */

    struct proc *first_come_process = 0;                      // process that came first (and that is runnable). Set to null initially

    for(;;) {
      intr_on();

      int min_creation_time = 0;                              // the creation time of the process that came first
      first_come_process = 0;

      for(p = proc; p < &proc[NPROC]; p++) {
        acquire(&p->lock);

        if(p->state == RUNNABLE) {
          if(first_come_process == 0) {                       // assume that the first process that shows up in the
            min_creation_time = p->ctime;                     // process table is the one that came first
            first_come_process = p;
            continue;
          } else if(min_creation_time > p->ctime) {           // the encountered process came before what we thought
            min_creation_time = p->ctime;                     // was the first process
            release(&first_come_process->lock);               // release the lock on the first 
            first_come_process = p;
            continue;
          }
        }
        release(&p->lock);
      }

      // note how the each time we update first_come_process, we don't release its lock, so that its parameters
      // do not change. This means that we should also release the previously thought first process' lock before 
      // updating first_come_process

      if(first_come_process != 0) {                           // if we found the process which has the least creation time,
        first_come_process->state = RUNNING;                  // then set its state to running,
        c->proc = first_come_process;                         // change the cpu's process to the one found and,
        swtch(&c->context, &first_come_process->context);     // allocate the cpu's resources for 1 time quantum
        c->proc = 0;
        release(&first_come_process->lock);

        // we will have to release the lock (which got acquired right before first_come_process was last updated), 
        // but which did not get released
      }
    }
  } else if(SCHEDULING_ALGO == 2) {                           // Priority Based Scheduling
    struct proc *most_priority_process = 0;                   // the process with the most priority (and therefore lesser numeric value)

    for(;;) {
      intr_on();

      int min_dynamic_priority = 500;                         // lesser this value, greater the priority. Set to a large value in the beginning so that it can change correctly

      int niceness;
      int dynamic_priority;
      most_priority_process = 0;                              // process with the most priority

      for(p = proc; p < &proc[NPROC]; p++) {
        acquire(&p->lock);

        if(p->state == RUNNABLE) {                            // calculate the niceness of each runnable process
          
          niceness = (int) ((float) p->sleep_time / (p->sleep_time + p->rtime)) * 10;

          dynamic_priority = p->static_priority - niceness + 5;

          if(dynamic_priority < 0) {                          // dp is defined as max(0, min(SP - niceness + 5, 100))
            dynamic_priority = 0;
          } else if(dynamic_priority  > 100) {
            dynamic_priority = 100;
          }

          if(min_dynamic_priority > dynamic_priority) {       // if the DP of the current process is lesser than what has been seen,
            min_dynamic_priority = dynamic_priority;          // update most_priority_process
            
            if(most_priority_process != 0) {
              release(&most_priority_process->lock);          // if this is not the first time most_priority_process has been updated, release the previously found proc's lock
            }

            most_priority_process = p;
            continue;
          }
        }

        release(&p->lock);
      }

      // if we have a process with the most priority, then swtch to it
      if(most_priority_process != 0) {
        most_priority_process->state = RUNNING;
        c->proc = most_priority_process;
        swtch(&c->context, &most_priority_process->context);

        c->proc = 0;
        release(&most_priority_process->lock);
      }
    }

    // since PBS is also non-preemptive, the releasing logic is the same as FCFS

  } else if(SCHEDULING_ALGO == 3) {                            // Lottery Based Scheduling

    for(;;){
        intr_on();

        for(p = proc; p < &proc[NPROC]; p++) {                 // find a runnable process that gets lucky, and run it for 1 time quantum
          acquire(&p->lock);
          if(p->state == RUNNABLE) {
            
            // find the total number of tickets held by all processes
            int total_tickets = 0;

            // lock not needed since CPUS = 1 for LBS
            struct proc *t;
            for(t = proc; t < &proc[NPROC]; t++) {
              if(t->state == RUNNABLE) {
                total_tickets += t->tickets;
              }
            }
            
            // this is a rea number between 0 and 1
            float success_probability = (float) p->tickets / total_tickets;

            if(success_probability < 0 || success_probability > 1) {
              panic("LBS: success probability out of bounds");
            }

            // if a randomly generated number is lesser than the success_probability, then the process has gotten lucky
            // this metric makes sense since a smaller success_probability will be harder to trigger
            // context switching happens here because LBS is preemptive
            if(is_the_process_lucky(success_probability)) {
              p->state = RUNNING;
              c->proc = p;
              swtch(&c->context, &p->context); 
              c->proc = 0;
            }
          }
          release(&p->lock);
        }
      }
  } else if(SCHEDULING_ALGO == 4) {                              // Multilevel Feedback Scheduling

    /*
    for(;;) {

      for(p = proc; p < &proc[NPROC]; p++) {
        
        if(p->state == RUNNABLE) {                               
          int queue_id;
          // If the process is in the queue with the least priority, let it be there
          // otherwise, demote it
          if(p->queue_id == 4) {
            queue_id = 4;
          } else {
            queue_id = p->queue_id + 1;
          }
          mlf_enqueue(p, queue_id);
        }
      }

      // we found the processes to be run in MLFQ
      // now loop over the queue with the most priority (as long as its not empty),
      // and execute only the processes in that queue
      int allocated_queue = -1;
      for(int i = 0; i < NMLFQ; i++) {

        // if a queue has already been chosen and fully executed,
        // then do not execute further queues
        if(allocated_queue != -1) {
          break;
        }

        while(mlf_queue.size[i] > 0) {
          allocated_queue = i;
          p = mlf_dequeue(i);
          p->last_wait_time = 0;
          p->state = RUNNING;
          acquire(&p->lock);

          c->proc = p;
          swtch(&c->context, &p->context);
          
          c->proc = 0;

          release(&p->lock);
        }
      }
    }

    */
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  // (xv6-cos)
  p->when_started_sleeping = ticks; // update the time at which the process slept

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        
        // (xv6-cos)
        p->sleep_time += ticks - p->when_started_sleeping;

        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
setkilled(struct proc *p)
{
  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

int
killed(struct proc *p)
{
  int k;
  
  acquire(&p->lock);
  k = p->killed;
  release(&p->lock);
  return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [USED]      "used",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}
