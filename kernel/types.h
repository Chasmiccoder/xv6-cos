typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int  uint32;
typedef unsigned long uint64;

typedef uint64 pde_t;

// (xv6-cos)
// struct to store information about syscalls
struct syscall_info
{
  int syscall_num, num_args;
  char* name;
};
