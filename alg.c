#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "alg.h"

void init_matrix(float *data, int N, float val) {
    for (int i = 0; i < N * N; i++) {
        data[i] = val;
    }
}

int verify_result(float *C, int N, float expected_val) {
    int correct = 1;
    float epsilon = 1e-5;

    for (int i = 0; i < N * N; i++) {
        if (fabs(C[i] - expected_val) > epsilon) {
            correct = 0;
            printf("Error at index %d: Actual=%.4f, Expected=%.4f\n", i, C[i], expected_val);
            break; 
        }
    }

    if (correct) {
        printf("SUCCESS: Matrix multiplication verified.\n");
        printf("Sample Result C[0]: %.4f\n", C[0]);
    } else {
        printf("FAILED: Matrix multiplication incorrect.\n");
    }

    return correct;
}
