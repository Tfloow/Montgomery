/*
 * montgomery.c
 *
 */

#include "montgomery.h"
#include <stdio.h>
#define DBG 1

void mult32(uint32_t operandA,uint32_t operandB, uint32_t* S,uint32_t* C){
    uint16_t a_lo = operandA & 0xFFFF;        // Lower 16 bits of a
    uint16_t a_hi = (operandA >> 16) & 0xFFFF; // Upper 16 bits of a
    uint16_t b_lo = operandB & 0xFFFF;        // Lower 16 bits of b
    uint16_t b_hi = (operandB >> 16) & 0xFFFF; // Upper 16 bits of b

    uint32_t lo_lo = (uint32_t)a_lo * (uint32_t)b_lo; // a_lo * b_lo
	uint32_t lo_hi = (uint32_t)a_lo * (uint32_t)b_hi; // a_lo * b_hi
	uint32_t hi_lo = (uint32_t)a_hi * (uint32_t)b_lo; // a_hi * b_lo
	uint32_t hi_hi = (uint32_t)a_hi * (uint32_t)b_hi; // a_hi * b_hi

    *S = lo_lo + ((lo_hi & 0xFFFF) << 16) + ((hi_lo & 0xFFFF) << 16);
    *C = hi_hi + (lo_hi >> 16) + (hi_lo >> 16);
}
// to be REMOVED
// #include <stdio.h>

// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements

void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size){
	uint32_t C;
	uint64_t sum;
	uint32_t S;
	uint32_t m;

	uint32_t resSize = 0;
	uint32_t resSizePlusOne = 0;

    // Initialize the result to 0
    for (int i = 0; i < size; i++) {
        res[i] = 0;
    }

	for(int i = 0; i < size; i++){
		C = 0;
		for(int j = 0; j < size; j++){
			sum = (uint64_t) res[j] + (uint64_t)a[j]*(uint64_t)b[i] + (uint64_t)C;
			C = (uint32_t)(sum >> 32);
			S = (uint32_t)(sum & 0xFFFFFFFF);

			res[j] = S;
		}

		sum = (uint64_t)resSize + (uint64_t)C;
		C = (uint32_t)(sum >> 32);
		S = (uint32_t)(sum & 0xFFFFFFFF);

		resSize = S;
		resSizePlusOne = C;

		C = 0;
		m = (uint32_t)(((uint64_t)res[0] * (uint64_t)n_prime[0]) & 0xFFFFFFFF);

		for(int j = 0; j < size; j++){
			sum = (uint64_t) res[j] + (uint64_t)m*(uint64_t)n[j] + (uint64_t)C;
			C = (uint32_t)(sum >> 32);
			S = (uint32_t)(sum & 0xFFFFFFFF);

			res[j] = S;
		}

		//loop_sum(res, n, m, size, C);

		sum = (uint64_t)resSize + (uint64_t)C;
		C = (uint32_t)(sum >> 32);
		S = (uint32_t)(sum & 0xFFFFFFFF);

		resSize = S;
		resSizePlusOne = (uint64_t)resSizePlusOne + (uint64_t)C;

		m = (uint32_t)((res[0] * n_prime[0]) & 0xFFFFFFFF);
		sum = (uint64_t)res[0] + (uint64_t)m * (uint64_t)n[0];

		C = (uint32_t)(sum >> 32);
		S = (uint32_t)(sum & 0xFFFFFFFF);

		for(int j = 1; j < size; j++){
			sum = (uint64_t) res[j] + (uint64_t)m*(uint64_t)n[j] + (uint64_t)C;
			C = (uint32_t)(sum >> 32);
			S = (uint32_t)(sum & 0xFFFFFFFF);

			res[j-1] = S;
		}

		sum = (uint64_t)resSize + (uint64_t)C;
		C = (uint32_t)(sum >> 32);
		S = (uint32_t)(sum & 0xFFFFFFFF);

		res[size-1] = S;
		resSize = (uint64_t)resSizePlusOne + (uint64_t)C;
	}

	// subtraction conditional
    uint8_t bigger;
    uint64_t c;
    uint32_t i;

    // check if bigger
    check_bigger:
    bigger = 0; c = 0; i = 0;
    for(int j = 1; j <= size; j++){
        if(res[size-j]>n[size-j]){
            // is bigger
            bigger = 1; 
            break;
        }else if(res[size-j]!=n[size-j]){
            // is not equal
            break;
        }
        // if equal last option it will loop

        if(j == size){
            // all the numbers are equal so it is like res = 10 and n = 10
            bigger = 1;
        }
    }

    // run the subtraction if needed
    if(bigger){
        for(; i < size; i++){
            if(res[i] < n[i]){
                // be more careful
                res[i] = (uint32_t)(UINT32_MAX + 1 + ((uint64_t) res[i]) - (((uint64_t)n[i]) + c));
                c = 1;
            }else{
                res[i] = res[i] - (n[i] + c);
                c = 0;
            }
        }

        goto check_bigger;
    }

}