#include <stdio.h>

#define N 32  // blocks
#define M 4   // threads per block

__global__ void mykernel(void) {
}

__global__ void add(int *a, int *b, int *c, int n) {
  int index = threadIdx.x + blockIdx.x * blockDim.x;
  if (index < n)
    c[index] = a[index] + b[index];
}


void random_ints(int* x, int size) {
	int i;
	for (i=0;i<size;i++) {
		x[i]=rand()%10;
	}
}

int main(void) {

  int *a, *b, *c;       // host copies of a, b, c
  int *d_a, *d_b, *d_c; // device copies of a, b, c

  int size =  N * sizeof(int);

  // Allocate space for device copies of a, b, c
  cudaMalloc((void **)&d_a, size);
  cudaMalloc((void **)&d_b, size);
  cudaMalloc((void **)&d_c, size);

  // Alloc space for host copies of a, b, c and setup input values
  a = (int *)malloc(size); random_ints(a, N);
  b = (int *)malloc(size); random_ints(b, N);
  c = (int *)malloc(size);

  // Copy inputs to device
  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

  // Launch add() kernel on GPU with N blocks and M threads per block
  add<<<N/M,M>>>(d_a, d_b, d_c, N);

  // Copy result back to host
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

  for (int i=0;i<N;i++) {
		printf("%d + %d = %d\n", a[i], b[i], c[i]);
	}

  // Cleanup
  free(a); free(b); free(c);
  cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);

  return 0;

}
