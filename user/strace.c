// (xv6-cos)
// based on kill.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  // if not enough arguments, print usage and exit
  if(argc < 3){
    fprintf(2, "usage: strace mask command args...\n");
    exit(1);
  }

  trace(atoi(argv[1])); // trace system calls with mask
  exec(argv[2], &argv[2]);  // execute command

  exit(0);
}