## Round Robin Scheduling

```
$ schedulertest
process number: 0    pid: 6
process number: 1    pid: 7
process number: 2    pid: 8
process number: 3    pid: 9
process number: 4    pid: 10
process number: 5    pid: 11
process number: 6    pid: 12
process number: 7    pid: 13
process number: 8    pid: 14
process number: 9    pid: 15

1 sleep  init
2 sleep  sh
5 sleep  schedulertest
6 runble schedulertest
7 run    schedulertest
8 run    schedulertest
9 runble schedulertest
10 runble schedulertest
11 runble schedulertest
12 runble schedulertest
13 run    schedulertest
14 runble schedulertest
15 runble schedulertest

1 sleep  init
2 sleep  sh
5 sleep  schedulertest
6 runble schedulertest
7 run    schedulertest
8 run    schedulertest
9 runble schedulertest
10 runble schedulertest
11 runble schedulertest
12 runble schedulertest
13 run    schedulertest
14 runble schedulertest
15 runble schedulertest

Process 2 finished
Pr
Process 3 finished
Process 5 finishedocess 0 finished
Process 1 finished
Process 4 finished
Process 8 finished
Process 7 finished
Process 9 finished
Process 6 finished
Average rtime 129,  wtime 51
$ 
```

## First Come First Serve Scheduling

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
Average rtime 70,  wtime 32
$
```

## Priority Based Scheduling
Priorities have been allotted in the following way: A process with a higher index is given more priority
Look at the `set_priority(100 - n * 5, pid);` line in `schedulertest.c`

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
4 runble schedulertest
5 runble schedulertest
6 runble schedulertest
7 runble schedulertest
8 runble schedulertest
9 runble schedulertest
10 runble schedulertest
11 run    schedulertest
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
11 run    schedulertest
12 run    schedulertest
13 run    schedulertest

Process 7 finished
Process 9 finished
Process 8 finished
Process 6 finished
Process 5 finished
Process 4 finished
Process 0 finished
Process 1 finished
Process 2 finished
Process 3 finished
Average rtime 76,  wtime 32
$
```

Note: Some outputs of the processes appear merged due to race condition

## Lottery Based Scheduling

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
Proc 6 finished (90)
Proc 7 finished (90)
Proc 9 finished (90)
Proc 5 finished (10)
Proc 8 finished (90)
PPPrroorco cc2   f01  ifniinsihsehde d(f i(1n0i)1
0s)h
PerodPc  (31r of0icn)i
sh ed4  (f1i0)n
ished (10)

Average rtime 67,  wtime 19
$
```

This output makes sense since processes with more tickets are getting completed before (greater probability of getting cpu time)
The random output towards the end is because of race condition
