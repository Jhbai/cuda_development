#ifndef ALG_H
#define ALG_H

#include <stddef.h> // for size_t
void init_matrix(float *data, int N, float val);
int verify_result(float *C, int N, float expected_val);

#endif // ALG_H
