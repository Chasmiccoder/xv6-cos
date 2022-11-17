#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "buf.h"

#include "proc.h"
#include "mlfqueue.h"

struct mlf_queue mlf_queue;


void initialize_mlf_queue() {
    /*
    int tick_limits[] = {1, 2, 4, 8, 16};

    for(int i = 0; i < NMLFQ; i++)
        mlf_queue.tick_limit[i] = tick_limits[i];

    for(int i = 0; i < NMLFQ; i++) {
        mlf_queue.rear[i] = mlf_queue.size[i] = 0;
        for(int j = 0; j < NPROC; j++) {
            mlf_queue.queue[i][j] = 0;
        }
    }
    */
}

void mlf_enqueue(struct proc *p, int queue_id) {
    /*
    if(mlf_queue.rear[queue_id] >= NPROC) {
        panic("mlf_enqueue(): invalid params passed");
    }

    mlf_queue.queue[queue_id][mlf_queue.rear[queue_id]] = p;
    mlf_queue.rear[queue_id]++;

    p->queue_id = queue_id;
    */
}

struct proc* mlf_dequeue(int queue_id) {
    /*
    if(mlf_queue.rear[queue_id] <= 0) {
        panic("mlf_dequeue(): invalid params passed");
    }

    struct proc *p = mlf_queue.queue[queue_id][0];

    mlf_queue.queue[queue_id][0] = 0;

    for(int i = 0; i < NPROC-1; i++) {
        mlf_queue.queue[queue_id][i] = mlf_queue.queue[queue_id][i+1];
    }
    
    mlf_queue.rear[queue_id]--;
    return p;
    */
   struct proc *p = mlf_queue.queue[queue_id][0];

   return p;
}