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
make qemu CUSTOM_SCHEDULING_ALGO=LBS
```


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

Make with custom scheduling algo -


    make CUSTOM_SCHEDULING_ALGO=FCFS

-->