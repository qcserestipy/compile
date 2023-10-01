#include <stdio.h>
#include <mpi.h>

int main(int argc, char **argv) {
// Initialize MPI
  MPI_Init(&argc, &argv);
  // Get the number of processes
  int size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  // Get the rank of the process
  int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  // Print off a hello world message
  printf("Hello, world from rank %d out of %d processors\n", rank, size);
  // Finalize the MPI environment
  MPI_Finalize();
  return 0;
}
