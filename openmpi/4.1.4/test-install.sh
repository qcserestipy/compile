#!/bin/bash

module load openmpi/4.1.4
mpicc hello_mpi.c -o hello_mpi
mpirun -n 4 ./hello_mpi
