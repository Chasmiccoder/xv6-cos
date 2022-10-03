# xv6 classical operating system 
xv6-cos is an enhanced version of the xv6-riscv operating system


## Installation using Docker

Clone this repository using

    git clone git@github.com:Chasmiccoder/xv6-cos.git

Then navigate to the codebase

    cd xv6-cos

Run the docker image (created by [wtakuo](https://hub.docker.com/r/wtakuo/xv6-env))

    docker run -it --rm -v $(pwd):/home/xv6/xv6-riscv wtakuo/xv6-env

Run the Makefile for xv6-cos

    make

To boot into xv6-cos

    make qemu

Any time you modify xv6-cos, you need to run the above `make` and `make qemu` commands to see the changes
Use `ctrl+a` followed by `x` to exit xv6-cos

## xv6-riscv
The original project can be found here -  
https://github.com/mit-pdos/xv6-riscv
