#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "simd.cuh"

/* ----- Device Function Definition ----- */
__device__ float deviceMultiply(float a, float b) {
    return a * b;
}

/* ----- Kernel Function Definition, the main GPU computation entry function ----- */
// using __launch_bounds__ to restrict theRegister usage for optimizing Occupancy.
// max_threads_per_block = 256 (16x16)
// min_blocks_per_sm = 4 (Make sure each SM will compute at least 4 Blocks)
__global__ void __launch_bounds__(256, 4) matrixMulKernel(float *d_A, float *d_B, float *d_C, int width) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;

    // Boundary Check
    if (row < width && col < width) {
        float sum = 0.0f;
        for (int k = 0; k < width; k++) {
            // Flattened index: row * width + col
            float valA = d_A[row * width + k];
            float valB = d_B[k * width + col];
            sum += deviceMultiply(valA, valB);
        }
        d_C[row * width + col] = sum;
    }
}

/* ----- Host Function Definition ----- */
// Notice that this function is declared as extern "C" in simd.cuh, it will be the bridge between C and CUDA C++
// Host Wrapper function (extern "C")
extern "C" int run_cuda_matrix_mul(float *h_A, float *h_B, float *h_C, int N) {
    size_t bytes = N * N * sizeof(float);
    float *d_A, *d_B, *d_C;
    cudaError_t err;

    printf("[GPU] Start initializing device memory...\n");

    // Device Memory Allocation (cudaMalloc)
    err = cudaMalloc((void**)&d_A, bytes);
    if (err != cudaSuccess) { fprintf(stderr, "cudaMalloc d_A failed: %s\n", cudaGetErrorString(err)); return -1; }
    
    err = cudaMalloc((void**)&d_B, bytes);
    if (err != cudaSuccess) { fprintf(stderr, "cudaMalloc d_B failed: %s\n", cudaGetErrorString(err)); cudaFree(d_A); return -1; }
    
    err = cudaMalloc((void**)&d_C, bytes);
    if (err != cudaSuccess) { fprintf(stderr, "cudaMalloc d_C failed: %s\n", cudaGetErrorString(err)); cudaFree(d_A); cudaFree(d_B); return -1; }

    // --- Step 4: 資料傳輸 Host -> Device (cudaMemcpy) ---
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // Set Kernel Parameters (Grid & Block) ---
    // The golden rules: 16x16 Threads
    dim3 threadsPerBlock(16, 16);
    // (N + block_size - 1) / block_size
    dim3 blocksPerGrid((N + threadsPerBlock.x - 1) / threadsPerBlock.x,
                       (N + threadsPerBlock.y - 1) / threadsPerBlock.y);

    printf("[GPU] Kernel Launch Config: Grid(%d, %d), Block(%d, %d)\n", 
           blocksPerGrid.x, blocksPerGrid.y, threadsPerBlock.x, threadsPerBlock.y);

    // Start Kernel
    matrixMulKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);

    // Check Launch Error
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        fprintf(stderr, "Kernel Launch Error: %s\n", cudaGetErrorString(err));
        goto cleanup;
    }

    // Wait GPU Finish (for Debug or timeering purpose)
    cudaDeviceSynchronize();

    // data from Device to Host
    cudaMemcpy(h_C, d_C, bytes, cudaMemcpyDeviceToHost);

cleanup:
    // free
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return (err == cudaSuccess) ? 0 : -1;
}
