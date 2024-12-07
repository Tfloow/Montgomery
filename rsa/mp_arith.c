/*
 * mp_arith.c
 *
 */

#include <stdint.h>
#include <stdio.h>

#define W 2^33

// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint32_t c = 0;
    uint32_t i = 0;

    for(; i < size; i++){
        res[i] = (a[i] + b[i] + c);
        // c already take care of this possible so it is annoying
        // i will split

        c = ((((uint16_t) (a[i] >> 16)) + ((uint16_t) (b[i] >> 16))) + ((((uint16_t) a[i] + (uint16_t) b[i] + c) >> 16)>>16));
    }
    res[i] = c;
}

// Calculates res = a - b.
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements
void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint32_t c = 0;
    uint32_t i = 0;

    uint32_t tmp = 0;

    for(; i < size; i++){
        tmp = (a[i] - c);
        res[i] = tmp - b[i];
        if (tmp >= b[i]){
            c = 0;
        }else{
            c = 1;
        }
    }
}

// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
    // add like before
    mp_add(a,b,res,size);

    // to the mod we simply need to substract once easy !
    if(res[size] >= N[size]){
        mp_sub(res,N,res,size);
    }

    // simple clean of the size+1 32 bits part since it may contain a garbage 1
    res[size] = 0;
}

// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
    // use modular arithmetic
    mp_sub(a,b,res,size);

    /*
    ISSUE REPORT:
        I think there is an issue when the number goes into the negative
        IMO C is for now doing a modulo of 32 bits base and then I perform a modulo of N
        BUT I should first do the sub and performing a modulo operation on the negative to find back
        where I am in the base N
        Proof : works flawlessly when it goes in the positive, works like shit otherwise
    */
   // IDEA just use the sub as before but then do a diff with max 1028 integer - temp
   // it will gives us a positive number than can be substracted from N hence the modulo

    // perform the modulo on this

    if(a[size-1] < b[size-1]){
        // perform the readjustment and modulo
        res[0] = (0xffffffff - res[0] + 1);
        for(int i = 1; i < size; i++){
            res[i] = (0xffffffff - res[i]);
        }
        //almost there just maybe should add 1 to res ?

        mp_sub(N,res,res,size);
    }


}
