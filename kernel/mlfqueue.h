#include "param.h"

struct mlf_queue {
    struct proc *queue[NMLFQ][NPROC];  // feedback queues with priorities 0 > 1 > 2 > 3 > 4
    int tick_limit[NMLFQ];             // number of ticks for time slice allocated for each queue
    int size[NMLFQ];                   // number of elements in each queue
    int rear[NMLFQ];                   // rear pointer of each queue
};

extern struct mlf_queue mlf_queue;
extern struct proc *queue[NMLFQ][NPROC];
