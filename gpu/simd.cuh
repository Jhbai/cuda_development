#ifndef SIMD_CUH
#define SIMD_CUH

/* 
To let C code can call the function that compiled by c++ compiler(nvcc)
Here, we need to use "extern C" to disable C++'s Name Mangling mechanism.
*/

#ifdef __cplusplus
extern "C" {
#endif

    int run_cuda_matrix_mul(float *h_A, float *h_B, float *h_C, int N);

    
#ifdef __cplusplus
}
#endif

#endif // SIMD_CUH
