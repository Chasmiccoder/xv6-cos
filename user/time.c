// File given to explain how waitx can be used
// TODO explain
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int argc, char **argv) {
    int pid = fork();
    if(pid < 0) {
        printf("fork(): failed\n");
        exit(1);
    } else if(pid == 0) {
        if(argc == 1) {
            sleep(10);
            exit(0);
        } else {
            exec(argv[1], argv+1);
            printf("exec(): failed\n");
            exit(1);
        }
    } else {
        int rtime, wtime;
        waitx(0, &wtime, &rtime); // similar to wait, but returns the wait time and running time of the child process
        printf("\nWaiting: %d\nrunning: %d\n", wtime, rtime);
    }
    exit(0);
}