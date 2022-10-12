// (xv6-cos)
// Program to test scheduling
// TODO explanation

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define NFORK 10
#define IO 5

int main() {
if(SCHEDULING_ALGO == 1) {
#define FCFS
}
if(SCHEDULING_ALGO == 2) {
#define PBS
}

  int n, pid;
  int wtime, rtime;
  int twtime=0, trtime=0;

#ifdef PBS
  set_priority(5, getpid());
#endif

  for(n=0; n < NFORK;n++) {
      pid = fork();

      if (pid < 0)
          break;
      if (pid == 0) {
#ifndef FCFS
          if (n < IO) {
            sleep(200); // IO bound processes
          } else {
#endif
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process
#ifndef FCFS
          }
#endif
          printf("\nProcess %d finished", n);
          exit(0);
      } else {
#ifdef PBS
        // set_priority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes
        set_priority(100 - n * 5, pid); // TODO. This 100 - n * 5 is a good test for PBS
        fprintf(2, "process number: %d    pid: %d\n", n, pid);
#endif
      }
  }

  for(;n > 0; n--) {
      if(waitx(0,&rtime,&wtime) >= 0) {
          trtime += rtime;
          twtime += wtime;
      }
  }

  printf("\nAverage rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  exit(0);
}
