# xv6 classical operating system 💿
xv6-cos is an enhanced version of the xv6-riscv operating system

All changes made are marked with a string `(xv6-cos)` in comments, to track what all changes were made to the original xv6

## Installation using Docker 🐳

Clone this repository using

    git clone git@github.com:Chasmiccoder/xv6-cos.git

Then navigate to the codebase

    cd xv6-cos

Start the docker engine

    sudo service docker start

Run the docker image (created by [wtakuo](https://hub.docker.com/r/wtakuo/xv6-env))

    docker run -it --rm -v $(pwd):/home/xv6/xv6-riscv wtakuo/xv6-env

To build and boot into xv6-cos

    make qemu

Any time you want to change the scheduling algorithm, you need to run `make clean`, then `make qemu` to see the changes.
Use `ctrl+a` followed by `x` to exit xv6-cos

## Usage

Scheduling - By default, `make qemu` builds the os according to Round Robin Scheduling

To build and run according to Round Robin Scheduling

```
make qemu CUSTOM_SCHEDULING_ALGO=RR
```

To build and run according to First Come First Serve Scheduling

```
make qemu CUSTOM_SCHEDULING_ALGO=FCFS CPUS=2
```

To build and run according to Priority Based Scheduling

```
make qemu CUSTOM_SCHEDULING_ALGO=PBS CPUS=2
```

To build and run according to Lottery Based Scheduling

```
make qemu CUSTOM_SCHEDULING_ALGO=LBS CPUS=1
```

To build and run according to Multilevel Feedback Queue Scheduling

```
make qemu CUSTOM_SCHEDULING_ALGO=MLFQ CPUS=1
```

To test whether the scheduling algorithms work in the xv6-cos, run,

```
$ schedulertest
```

To test strace

```
strace 32 grep hello README
strace 2147483647 grep hello README
```

To test sigalarm and sigreturn
```
alarmtest
```

## Implementation of Strace
Implements the system call trace and an accompanying user program strace.
<ul>Usage:

    in terminal $ strace mask command [args] 
</ul>
<li>`strace` runs the specified command until it exits.
It intercepts and records the system calls which are called by a process during its execution.
<li>We declare a generalised functiom, `print_trace()` which fetches and prints the required info for strace.
<li>Add `trace` syscall and include on all lists relating to syscalls (`(*syscalls[])(void), syscall_structs[], usys.pl`, etc).
<li>Add a field, `trace_mask` to struct `proc` to store the values corresponding to the syscalls being traced for a process.
<li>Add `strace` to uprogs in `Makefile` to make it usable as a user program.
<li>Whenever `syscall()` is called during execution, check if mask matches the syscall number and if yes, call `print_trace()`.
<li>Also implemented `struct syscall_info` to store information about syscalls, used in `print_trace()`.
<br><br>

## Implementation of Sigalarm and Sigreturn
Adds a new `sigalarm(interval, handler)` system call. If an application calls `sigalarm(n, fn)`, then after every n "ticks" of CPU time that the program consumes, the kernel will cause application function fn to be called. When fn returns, the application will resume where it left off.
Another syscall, `sigreturn()` is implemented to help with resuming by restoring state to that prior to alarm.
<ul>Usage:

    inside program | sigalarm(n,fn)
</ul>
<li>Added <ul><li>alarm_flag (to mark if alarm handler is currently being executred)</li><li> alarm_handler (handler called when n ticks are up)</li><li> alarm_ticks (number of ticks after which alarm is set off)</li><li>alarm_ticks_left (number of ticks left till alarm goes off
)</li><li> alarm_saved_tf (saved trapframe for restoring after alarm)
</li>
to struct proc.</li>
</ul>

<li>Add `sigalarm` and `sigreturn` syscalls and include on all lists relating to syscalls (`(*syscalls[])(void), syscall_structs[], usys.pl`, etc).
<li>`sigalarm` is called to set up alarms. This function takes number of ticks and handler as arguments, assigns them to the required feilds in `proc`. 
<li>When timer interrupt is received (which_dev = 2 in usertrap()), decrement number of ticks left. If number of ticks reaches 0, alarm goes off. Reset it to total number of ticks, store current trapframe, set alarm_flag to 1 to prevent reentrant calls to handler, and set `p->trapframe->epc` as address of `p->alarm_handler`. 
<li>Handlers are required to call `sigreturn` at the end of their execution. This function restores the original trapframe (saved in usertrap()), frees space allocated for `alarm_saved_tf`.
<br><br>


## Understanding of Preemption
How preemption and nonpreemption work -  

RR is preemptive - since swtch is inside for(p = proc ...), context switch happens (after every 100 ms, by default)

In non-preemptive algos like FCFS and PBS, the swtch happens outside the for(p = proc ...) loop, which selects a process first, and then does swtch.  

It runs the process throughout the time quantum (100ms), and then we reach the next iteration of for(;;)  

The scheduler picks the same process over and over again (through its protocol [FCFS/PBS]), until the process gets completed (after which the next process is chosen)  


## Implementation of First Come First Serve Scheduling
Once we've identified that FCFS is to be used, the function runs the infinite for loop for(;;)  

Then, we loop over all processes to find a process with the least creation time  

In the first iteration of for(p = proc ...), the process seen is set as the process that has come first (first_come_process)

Then, the rest of the process creation times are checked. Any time we find a process with a lower creation time, first_come_process gets updated, and at the end of for(p = proc ...) we would have found the process with the least creation time.

Then, this process' state is changed to RUNNING, and it is assigned the CPU.

first_come_process = process that came first (and that is runnable). Set to null initially

min_creation_time  = the creation time of the process that came first

We assume that the first process that shows up in the process table is the one that came first

Later if a process with a lower creation time is found, then first_come_process is updated, and the previously
thought process is released.

Note how the each time we update first_come_process, we don't release its lock, so that its parameters do not change.  
This means that we should also release the previously thought first process' lock before updating first_come_process


Inside `if(first_come_process != 0){}` -  
At the end check if we found the process which has the least creation time, then set its state to running. 

Change the cpu's process to the one found and, allocate the cpu's resources for 1 time quantum

We will have to release the lock (which got acquired right before first_come_process was last updated), 
// but which did not get released


## Implementation of Priority Based Scheduling
The process with the most priority (and therefore lesser numeric value) is found by looping over the proc table
min_dynamic_priority =  process with the most priority
We find the niceness and dynamic priority of each runnable process, and choose the one with the least numeric value for priority.
dp is defined as `max(0, min(SP - niceness + 5, 100))`

Context switching here is the same as in FCFS. It happens outside the `for(p = proc; ...)` loop because we want to choose a process first
and then allocate it 1 time quantum (this way the algorithm is non-preemptive)

## Implementation of Lottery Based Scheduling
LBS is preemptive, so it uses a logic similar to that of Round Robin.
First we loop over the proc table to find a process that 'gets lucky'.  

How a process can get lucky -
Each process holds some number of tickets. We calculate that processes' success probability using the following formula -
`float success_probability = (float) p->tickets / total_tickets;`

Then we use an RNG to generate a number (let this be r). In our implementation, the RNG used generates a number between 0 and LONG_MAX-2,  
so we need to scale the success_probability to match this (let this value be x).  

If r < x, then the process is considered lucky.
Why this metric makes sense.   

Say the success probability is 0.3
There is a 30% chance that the RNG produces a number < 0.3 (range is [0,1]), which means that there is a 30% chance
that the process gets lucky.  

When the process gets lucky, it gets allocated 1 time quantum.

## Progress on Multilevel Feedback Queue Scheduling
A global variable mlf_queue is maintained, which contains metadata, along with the 5 priority queues.  

Then we load the queues depending on their cpu times.
In a later for loop, we deque the queues starting with the one with the highest priority.  

If queue 0 is empty, then queue 1 is implemented fully (and if 1 is not empty). [and so on]  

By recording how the switches happen, we can plot the MLFQ graph and view its progress.


## Progress on Copy on Write
By default, xv6 follows copy-on-fork, where pages are copied whenever a fork occurs and both parent and child processes are alloted different copies. This can be inefficient as copying has a high overhead. <br>
This specification involves preventing copying of pages until one of the parent or child processes needs to write to it.
<ul>
<li>Maintain an array where each element represents the number of references to the i-th page. 
<li>Initialise these to 0, then assign 1 when page is alloted to a process and increment when process is forked. 
<li> When one of the processes refering to the page attempts to write to it, copy it to a new page, assign count of new page as 1, decrement count of old page by 1. Free page if 0 references.
</ul>

## Scheduling Outputs

FCFS-

```
$ schedulertest
process number: 0    pid: 4
process number: 1    pid: 5
process number: 2    pid: 6
process number: 3    pid: 7
process number: 4    pid: 8
process number: 5    pid: 9
process number: 6    pid: 10
process number: 7    pid: 11
process number: 8    pid: 12
process number: 9    pid: 13

1 sleep  init
2 sleep  sh
3 sleep  schedulertest
4 run    schedulertest
5 run    schedulertest
6 run    schedulertest
7 runble schedulertest
8 runble schedulertest
9 runble schedulertest
10 runble schedulertest
11 runble schedulertest
12 runble schedulertest
13 runble schedulertest

1 sleep  init
2 sleep  sh
3 sleep  schedulertest
4 run    schedulertest
5 run    schedulertest
6 run    schedulertest
7 runble schedulertest
8 runble schedulertest
9 runble schedulertest
10 runble schedulertest
11 runble schedulertest
12 runble schedulertest
13 runble schedulertest

Process 0 finished
Process 1 finished
Process 2 finished
Process 3
 Pfrionceisssh ed4 finished
Process 5 finished
Process 7 finished
Process 6 finished
Process 8 finished
Process 9 finished
Average rtime 32,  wtime 70
$
```

PBS -  
Priorities have been allotted in the following way: A process with a higher index is given more priority
Look at the `set_priority(100 - n * 5, pid);` line in `schedulertest.c`
Priorities are enclosed in `()`
```
Using Priority Based Scheduling
hart 1 starting
init: starting sh
$ schedulertest
process number: 0    pid: 4
process number: 1    pid: 5
process number: 2    pid: 6
process number: 3    pid: 7
process number: 4    pid: 8
process number: 5    pid: 9
process number: 6    pid: 10
process number: 7    pid: 11
process number: 8    pid: 12
process number: 9    pid: 13

1 sleep  init
2 sleep  sh
3 sleep  schedulertest
4 runble schedulertest
5 runble schedulertest
6 runble schedulertest
7 runble schedulertest
8 runble schedulertest
9 runble schedulertest
10 runble schedulertest
11 runble schedulertest
12 run    schedulertest
13 run    schedulertest

1 sleep  init
2 sleep  sh
3 sleep  schedulertest
4 runble schedulertest
5 runble schedulertest
6 runble schedulertest
7 runble schedulertest
8 runble schedulertest
9 runble schedulertest
10 runble schedulertest
11 runble schedulertest
12 run    schedulertest
13 run    schedulertest
Proc 9 finished (55)
Proc 8 finished (60)
Proc 4 finished (80)
Proc 3 finished (85)
Proc 7 finished (65)
Proc 2 finished (90)
Proc 5 finished (75)
Proc 1 finished (95)
Proc 0 finished (100)
Proc 6 finished (70)

Average rtime 20,  wtime 78
$
```

LBS
Tickets set are enclosed in `()`
```
Using Lottery Based Scheduling
hart 2 starting
hart 1 starting
init: starting sh
$ schedulertest
process number: 0    pid: 4
process number: 1    pid: 5
process number: 2    pid: 6
process number: 3    pid: 7
process number: 4    pid: 8
process number: 5    pid: 9
process number: 6    pid: 10
process number: 7    pid: 11
process number: 8    pid: 12
process number: 9    pid: 13
Proc 5 finished (10)
Proc 6 finished (200)
Proc 7 finished (200)
Proc 9 finished (200)
Proc 8 finished (200)
PPrroocc  01  ffiinnisishheedd  ((101)0
)
PPPrroocc ro2  3cf in4  fiisnhfiiendi s(h1e0d) 
(s10h)
ed (10)

Average rtime 24,  wtime 72
$ 
```
Note: Some outputs of the processes appear merged due to race condition



## xv6-riscv 💽
The original project can be found here -  
https://github.com/mit-pdos/xv6-riscv

Docker Image -  
https://hub.docker.com/r/wtakuo/xv6-env

<!-- 

Potential bugs:
sys_waitx not accounted for in trace (in syscall.h)
Update struct syscall_info syscall_structs[]

xv6 password is "xv6" 
-->