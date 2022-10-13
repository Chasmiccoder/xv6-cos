// (xv6-cos)
// Program to test scheduling
// TODO explanation

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

#define NFORK 10
#define IO 5

void main() {
  if(SCHEDULING_ALGO == 0) {
    int n, pid;
    int wtime, rtime;
    int twtime=0, trtime=0;

    for(n=0; n < NFORK;n++) {
      pid = fork();

      if (pid < 0)
        break;
      if (pid == 0) {
        if (n < IO) {
          sleep(100); // IO bound processes      
        } else {
          for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process
        }
        printf("Proc %d finished\n", n); // print the process index
        exit(0);
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

  } else if(SCHEDULING_ALGO == 1) { // First Come First Serve Scheduling
    int n, pid;
    int wtime, rtime;
    int twtime=0, trtime=0;

    for(n=0; n < NFORK;n++) {
      pid = fork();

      if (pid < 0)
          break;
      if (pid == 0) {
          
          sleep(10);
          for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process

          printf("Proc %d finished\n", n); // print the process index
          exit(0);
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
  } else if(SCHEDULING_ALGO == 2) { // Priority Based Scheduling
     
    int n, pid;
    int wtime, rtime;
    int twtime=0, trtime=0;

    set_priority(5, getpid());

    for(n=0; n < NFORK;n++) {
      pid = fork();

      if (pid < 0)
          break;
      if (pid == 0) {
          if (n < IO) {
            sleep(100); // IO bound processes
          } else {
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process
          }

          printf("Proc %d finished (%d)\n", n, 100 - n * 5); // print the process index and priority
          exit(0);
      } else {  

        // set_priority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes
        set_priority(100 - n * 5, pid); // TODO. This 100 - n * 10 is a good test for PBS
        fprintf(2, "process number: %d    pid: %d\n", n, pid);
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
  } else if(SCHEDULING_ALGO == 3) { // Lottery Based Scheduling
    int n, pid;
    int wtime, rtime;
    int twtime=0, trtime=0;

    for(n=0; n < NFORK;n++) {
      pid = fork();

      if (pid < 0)
        break;
      if (pid == 0) {
        if (n < IO) {
          sleep(100); // IO bound processes      
        } else {
          for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process
        }
        
        printf("Proc %d finished ", n); // print the process index
        if(n < 6)
          printf("(10)\n");
        else
          printf("(90)\n");

        exit(0);
      } else {
        // set tickets here
        if(n < 6) {
          settickets(10, pid);
          fprintf(2, "process number: %d    pid: %d\n", n, pid);
        } else {
          settickets(90, pid);
          fprintf(2, "process number: %d    pid: %d\n", n, pid);
        }
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
  } else {
    printf("scheduler not chosen\n");
    exit(-1);
  }
}
