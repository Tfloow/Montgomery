def printArray(res, size):
    for i in res[::-1]:
        print(hex(i)[2:], end=" ")
    print()
    

def montMul(a,b,n,n_prime,size):
    C =0
    sums = 0 
    S = 0
    m = 0

    resSize = 0 
    resSizePlusOne = 0 

    res = [0 for _ in range(size)]

    for i in range(size):
        C = 0 
        for j in range(size):
            sums =   res[j] +  (( a[j])*( b[i])) +  C 
            C =  (sums >> 32) 
            S =  (sums & 0xFFFFFFFF) 

            res[j] = S
            
        

        sums =  resSize +  C 
        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        resSize = S 
        resSizePlusOne = C 

        C = 0 
        m =  (( ( res[0] *  n_prime[0])) & 0xFFFFFFFF) 

        for j in range(size):
            sums =   res[j] +  ( m* n[j]) +  C 
            C =  (sums >> 32) 
            S =  (sums & 0xFFFFFFFF) 

            res[j] = S 

        sums =  resSize +  C 
        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        resSize = S 
        resSizePlusOne = resSizePlusOne + C 

        m =  ((res[0] * n_prime[0]) & 0xFFFFFFFF) 
        sums =  res[0] +  m *  n[0] 

        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        for j in range(1,size):
            sums =   res[j] +  ( m* n[j]) +  C 
            C =  (sums >> 32) 
            S =  (sums & 0xFFFFFFFF) 

            res[j-1] = S 
        

        sums =  resSize +  C 
        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        res[size-1] = S 
        resSize =  resSizePlusOne +  C 
        
    bigger = 0; c = 0; i = 0
    for j in range(1, size+1):
        if(res[size-j]>n[size-j]):
            bigger = 1; 
            break
        elif(res[size-j]!=n[size-j]):
            break

        if(j == size):
            bigger = 1

    if(bigger):
        print("COND SUB\n")
        for i in range(size):
            if(res[i] < n[i]):
                res[i] = (0xFFFFFFFF + 1 + res[i]) - ((n[i]) + c)
                c = 1
            else:
                res[i] = res[i] - (n[i] + c)
                c = 0
            


    return res

a         = [ 0x05338326, 0x83609740, 0x071d25cb, 0x96a42700, 0x4b2d44e2, 0x9ee78b55, 0x54f47628, 0x4d788d80, 0xa61ae06e, 0x32b898f9, 0x434fb849, 0xfe32f0c6, 0xcefb06a1, 0xf22e9ea8, 0xacf3d47c, 0x60f90cc0, 0xf99c84f3, 0x0e90cca7, 0x995dbbb1, 0x888b1757, 0x2e6f1ccf, 0x6412c3fc, 0x2a328a99, 0x06242367, 0x22238dbf, 0x55188ca8, 0x411adea3, 0xe907537c, 0xdb0538fa, 0x269ec875, 0x53463880, 0xa495cd8c ]
b        = [  0x36c325aa, 0x128fbd6f, 0x330991e7, 0x8fdff84d, 0x2fb72357, 0x563685a9, 0x6ca9ab07, 0xbc2f8fe6, 0xa666437c, 0x62437d6e, 0x4015bcc6, 0x45dd372b, 0xdf47fdb2, 0x215acb1c, 0xbcdce828, 0x1564ee05, 0x29299a93, 0x1e7d2e4e, 0x1f8c29af, 0xc95e4bed, 0xd0b1cf50, 0x96ae326d, 0x8dec4669, 0xadce74d8, 0x538599b6, 0xc48c420d, 0xfb208fb3, 0x84ba7e73, 0x4b00c815, 0xc024dd31, 0x490eb3a0, 0xa19b523f ]
n         = [ 0x49479489, 0x21b7f1cd, 0x439e0d30, 0x8f2f1565, 0x8d7fc2a3, 0x4ab0bd0b, 0x4a768857, 0xcb88ecc7, 0x879fdf28, 0x93c74382, 0x2909f648, 0xb62abde4, 0x53f65c2f, 0x81681913, 0x7475cd6b, 0xd30edd74, 0xb0d9dc3a, 0x0a569a5b, 0xdc868dc7, 0x5f58ab44, 0xefc8034c, 0x54d46ebe, 0x7462374e, 0x64217e81, 0x8900cdab, 0x3c596fe4, 0x0b4e6b9a, 0x71f4514d, 0xc4be0994, 0x9e14e9bc, 0x79d8fea6, 0xc3492147 ]
n_prime   = [ 0xbfdfde47, 0xc7419c98, 0x06029f1f, 0x2cab2b9e, 0x7980859e, 0x3e9fd7b2, 0x1c441fe9, 0x8730b0ad, 0xa2bcf1b6, 0x41a4c8f1, 0xb5fb032b, 0x495c26e7, 0x450b601b, 0x41a63266, 0x4ad3f215, 0x602f9147, 0xec598ebc, 0xdd79128b, 0x4da5bc67, 0xae60097a, 0x190e4415, 0x26bffc00, 0xf2c2168e, 0xaf7a0a99, 0x75a4eee5, 0x091e810e, 0xf8d9e224, 0x3cd0bd65, 0xd4088ca0, 0x058d748b, 0xe6007ce7, 0x2ba4f013 ]
res       = [ 0x11c981aa, 0x25541b1b, 0xab6324e3, 0xebae4fba, 0x32306426, 0x38844cf0, 0xb1592042, 0xcd36dfea, 0x21c4fd81, 0x31acde61, 0xb81a2435, 0xd65dedaa, 0x1feb579f, 0xa3e7c2ab, 0x4ca5e5f6, 0x431bf2f3, 0x649c07bd, 0x0dc4a3b0, 0x7b387f7d, 0x4ed9ebe0, 0xba78a891, 0x2f65312c, 0x346058ed, 0x4b633fbe, 0xd67688ff, 0xada40234, 0x921a6814, 0x3d3d503f, 0x517d0e3f, 0x661abb40, 0x2caed472, 0x51f73b2b ]

obtained_res = montMul(a,b,n,n_prime,32)

print("Expected : ", end="")
printArray(res, 32)
print("got :      ", end="")
printArray(obtained_res, 32)

