/*
 * montgomery.c
 *
 */

#include "montgomery.h"
#include <stdio.h>
#define DBG 1

// Calculates res = a * b * r^(-1) mod n.
// a, b, n, n_prime represent operands of size elements
// res has (size+1) elements

void SUB_COND(uint32_t* u,uint32_t* n,uint32_t size, uint32_t ressize){
	// I assume that u and n are of size size and so n[size+1] = 0
    uint32_t B = 0;
    uint32_t t[33] = {0}; // Set at 33 manually to avoid compiler issue
	uint32_t sub = 0;
    
    for(uint32_t i = 0; i < size; i++){
        sub = u[i] - n[i] - B;
        if( u[i] >= n[i] + B){
            B = 0 ;
		}else{
            B = 1;
		}  
        t[i] = sub;
    }

	// last operation to the size + 1 bits
	sub = ressize - B;
	if( ressize >= B){
		B = 0 ;
	}else{
		B = 1;
	}  
	t[size] = sub;

	// copy the new array in u
    if (B == 0){
        for(uint32_t i = 0; i < size; i++){
			u[i] = t[i];
		}
    }
	
}

void montMul(uint32_t *a, uint32_t *b, uint32_t *n, uint32_t *n_prime, uint32_t *res, uint32_t size){
	uint32_t C;
	uint64_t volatile sum;
	uint32_t S;
	uint32_t volatile m;

	uint32_t resSize = 0;
	uint32_t resSizePlusOne = 0;

    // Initialize the result to 0
    for (uint32_t i = 0; i < size; i++) {
        res[i] = 0;
    }

	for(uint32_t i = 0; i < size; i++){
		C = 0;
		for(uint32_t j = 0; j < size; j++){
			sum = (uint64_t) res[j] + (uint64_t)(((uint64_t)a[j])*((uint64_t)b[i])) + (uint64_t)C;
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
		m = (uint32_t)(((uint64_t)((uint64_t)res[0] * (uint64_t)n_prime[0])) & 0xFFFFFFFF);

		for(uint32_t j = 0; j < size; j++){
			sum = (uint64_t) res[j] + (uint64_t)((uint64_t)m*(uint64_t)n[j]) + (uint64_t)C;
			C = (uint32_t)(sum >> 32);
			S = (uint32_t)(sum & 0xFFFFFFFF);

			res[j] = S;
		}

		sum = (uint64_t)resSize + (uint64_t)C;
		C = (uint32_t)(sum >> 32);
		S = (uint32_t)(sum & 0xFFFFFFFF);

		resSize = S;
		resSizePlusOne = resSizePlusOne + C;

		m = (uint32_t)((res[0] * n_prime[0]) & 0xFFFFFFFF);
		sum = (uint64_t)res[0] + (uint64_t)m * (uint64_t)n[0];

		C = (uint32_t)(sum >> 32);
		S = (uint32_t)(sum & 0xFFFFFFFF);

		for(uint32_t j = 1; j < size; j++){
			sum = (uint64_t) res[j] + (uint64_t)((uint64_t)m*(uint64_t)n[j]) + (uint64_t)C;
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

	SUB_COND(res, n, size, resSize);

	return;

}