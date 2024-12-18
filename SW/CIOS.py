def printArray(res, size):
    for i in res[::-1]:
        print(hex(i)[2:], end=" ")
    print()
    
def check(res, obtained_res, size):
    for i in range(size):
        if res[i] != obtained_res[i]:
            print(i)
            print(hex(res[i]))
            print(hex(obtained_res[i]))
            return 0
    return 1
    
def overflowWarning(num, threshold):
    if(len(bin(num))-2 > threshold):
        print("WARNING")    
        
def SUB_COND(u,n,size):
    B = 0
    t = [0 for _ in range(size + 1)]
    
    print(len(u))
    print(len(n))
    
    for i in range(size+1):
        sub = u[i] - n[i] - B
        if u[i] >= n[i] + B:
            B = 0 
        else:
            B = 1
            
        t[i] = sub
    
    if B == 0:
        print('BIGGERRR')
        return t[0:size]
    else:
        return u

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
            overflowWarning(sums,64)
            C =  (sums >> 32) 
            S =  (sums & 0xFFFFFFFF) 

            res[j] = S
            
        

        sums =  resSize +  C 
        overflowWarning(sums,64)
        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        resSize = S 
        resSizePlusOne = C 

        C = 0 
        m =  (( ( res[0] *  n_prime[0])) & 0xFFFFFFFF) 

        for j in range(size):
            sums =   res[j] +  ( m* n[j]) +  C 
            overflowWarning(sums,64)
            C =  (sums >> 32) 
            S =  (sums & 0xFFFFFFFF) 

            res[j] = S 

        sums =  resSize +  C 
        overflowWarning(sums,64)
        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        resSize = S 
        resSizePlusOne = resSizePlusOne + C 
        overflowWarning(resSize,32)
        overflowWarning(resSizePlusOne,32)

        m =  ((res[0] * n_prime[0]) & 0xFFFFFFFF) 
        sums =  res[0] +  m *  n[0] 
        overflowWarning(sums,64)

        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        for j in range(1,size):
            sums =   res[j] +  ( m* n[j]) +  C 
            overflowWarning(sums,64)
            C =  (sums >> 32) 
            S =  (sums & 0xFFFFFFFF) 

            res[j-1] = S 
        

        sums =  resSize +  C 
        overflowWarning(sums,64)
        C =  (sums >> 32) 
        S =  (sums & 0xFFFFFFFF) 

        res[size-1] = S 
        resSize =  resSizePlusOne +  C 
        overflowWarning(resSize,32)
        
            
    print("Smaller than N ?", res[size-1] < n[size-1])
    
    print(resSize)
    print(resSizePlusOne)
    
    res_tmp = res
    res_tmp.append(resSize)
    n_tmp = n 
    n_tmp.append(0)
    
    printArray(res_tmp, 33)
    printArray(n_tmp, 33)

    return SUB_COND(res_tmp,n_tmp,size)

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

print(check(res,obtained_res,32))
print("__________")

for i in range(32):
    print(len(bin(obtained_res[i]))-2, end="\t")
    if(len(bin(obtained_res[i]))-2 > 32):
        print("WARNING", end=" ")
    print(len(bin(res[i]))-2)
    
a          =  [ 0xdbb7cf01, 0x893bb05a, 0x081cf6a9, 0xd662b3b8, 0x27f0a7ed, 0xfc802f42, 0xd48946a3, 0xe5c03b49, 0x7e6f2837, 0x6b69efb8, 0xf68b8db3, 0x7327b5e0, 0x26194661, 0x2ac08b73, 0xdb3aa464, 0x009d07c8, 0x0afc7d82, 0x2a30a776, 0x36b71b43, 0xc5da963d, 0x8513bbc9, 0xba37ed96, 0x276857c7, 0xda73e6d5, 0x50e85b3d, 0x87360fa9, 0x6b8d17e5, 0x22d8268e, 0x1d08210e, 0x14aa7141, 0x2b4446da, 0x9a81722d ] 
b          =  [ 0x16a76b1f, 0x1a7710cc, 0xf4a35c61, 0xd5c1d270, 0x7d96a773, 0x1b60c8a9, 0x38cfed5f, 0xb8a151cc, 0xf7b49b29, 0xe26f0760, 0x1e76d7c6, 0x6c402f0b, 0x40a530be, 0x3dff1b2f, 0xd76abde9, 0xf01fae7a, 0xb37ba136, 0x16ea845c, 0xd529c587, 0xa2a5bec3, 0x68e857ea, 0x76738dc5, 0x90fd6006, 0xa77a4869, 0x2cf403e5, 0xaf118a0c, 0xba4080e0, 0x54b859cd, 0x937bfe59, 0x837fb500, 0xda66bfd1, 0x8e3dbc92 ] 
n          =  [ 0x3e2f45f5, 0x452ad0e8, 0x677fde03, 0x3f8eb8d4, 0x3221ca48, 0xa2ec8644, 0xdcdf4eb5, 0x8684489a, 0x225dbf12, 0x064ab43b, 0x0b1f8357, 0x8d67e83c, 0xf4a4bc7f, 0xd0753167, 0x31b2aacf, 0xc6ee42ce, 0x5c2e04d1, 0xa945c284, 0xbf33a9e5, 0x64d22cd1, 0x8169d97f, 0xb6c4e5a3, 0x1a436c47, 0xc6e438e3, 0xfecea9e2, 0x23b8b961, 0xa4809d2f, 0x8a98bd7d, 0x4dac96c0, 0x7448a711, 0x344a1298, 0xacb9027a ] 
n_prime    =  [ 0x114e81a3, 0x55b76f06, 0x7f0c56d8, 0xb70c7e15, 0xaf05827b, 0x24234957, 0xe2954af3, 0x868f173f, 0x375eb157, 0x8c3fbbbc, 0x5b5a8d17, 0xfc286172, 0x58b1a0af, 0x7d158b51, 0x8dc6fa22, 0x77225374, 0x5fbe7944, 0x9aa6f55e, 0xa272ed91, 0xb717f577, 0xd22e08ed, 0x7ac4bbb1, 0x9195f30c, 0x5cc169b8, 0xbbb0cecd, 0x2070ec9c, 0x6aa80649, 0xdad010a1, 0x69a2b7dd, 0x6b42f344, 0x23faad97, 0xdd773fcc ] 
res        =  [ 0xae0dda17, 0xe56b7b63, 0xf08ceb34, 0xd357d5c3, 0x1a52b782, 0x2c41466b, 0x9b6adb27, 0xae25a35f, 0x3c751add, 0x084c78a1, 0xacacced5, 0x2cbe6ae4, 0x964da7cd, 0x8d63e860, 0xf6bb434c, 0x20daa53f, 0x96e10261, 0x80638756, 0x97692934, 0x78d9e8ce, 0x8584d534, 0x023007d2, 0xe25920bc, 0x22e4f5f6, 0xa98cc175, 0x7724ce10, 0x006899b0, 0xfcc32320, 0xe18ec375, 0x5fd0bdaf, 0x71369cef, 0x617b2737 ] 



obtained_res = montMul(a,b,n,n_prime,32)

print("Expected : ", end="")
printArray(res, 32)
print("got :      ", end="")
printArray(obtained_res, 32)

a       =  [ 0x40e9ca45, 0x3a1ce2a5, 0x10eac679, 0xabe06aa0, 0x40095a54, 0xe95bec2e, 0x695a82ab, 0x3def1e43, 0xcd6c5a5a, 0xc6fdf451, 0x3f0cab8a, 0xdbdc1b6f, 0x90401d45, 0xa6d223b7, 0x3b3ba07a, 0x43b84665, 0x7683fd78, 0x52031466, 0xda713c19, 0x6105982f, 0x2aa264d5, 0x92ce0b99, 0xc2a0a4df, 0xb33ead2b, 0x65a5f45f, 0x63e0966a, 0x71ba7223, 0x84185ed4, 0xa307a9ae, 0x5046745a, 0xf74b509a, 0x84f81ad0 ] 
b          =  [ 0xfdb53759, 0x6ffd8f86, 0x9e204867, 0x168ac4ff, 0x7d450de7, 0x072dec9d, 0x38e79ef5, 0x5ba2b304, 0x713589d8, 0x4f626d03, 0xf190351d, 0x6decf4cc, 0xe7a318d2, 0xeef16e3f, 0xd3c33675, 0x1a579730, 0xe7213b1b, 0x8883a7dc, 0x037e00f8, 0x7879e4b4, 0x9cd053b8, 0x0b6fa7c5, 0x2983db67, 0xfd01d31a, 0xb4305a2c, 0x45d9c082, 0x6d1d796d, 0xf8d4e074, 0x9d6a1d02, 0x62b5a6c7, 0xf656c69b, 0x855f082d ] 
n          =  [ 0x60d4ef29, 0x6c95cad1, 0xbe9cf091, 0xc202db66, 0x75479e0f, 0xf923981b, 0xeb126cf4, 0x50f976a4, 0xf217de7f, 0x7447d577, 0x50881ed6, 0xe96ea7e5, 0xd0a0bbf5, 0xc48fd381, 0x72e473d9, 0x2bf66ed6, 0x86c94f1a, 0x3613601b, 0x736e0746, 0xf5583885, 0xe6465a6b, 0xbdcfe656, 0xf432a41f, 0x6f1f0a42, 0xf84b461f, 0x1e32f4eb, 0x5677b300, 0x223744be, 0x694dddc9, 0x0ad4767c, 0x2062be75, 0x8991dd6d ] 
n_prime    =  [ 0x282ae2e7, 0xcc36e408, 0x6527c247, 0x44ee5706, 0xc33f8a46, 0x2bd65921, 0xdc757233, 0xe881337e, 0xe8b12d0f, 0x0f690e35, 0x88d4af13, 0x2778fe8f, 0x7b45a760, 0x962d25d9, 0x4c032771, 0x4d64f8a9, 0x769e5ac4, 0x17808701, 0x92b69920, 0x3b055307, 0x9f2a30af, 0x7d955eb2, 0x0aabcb27, 0x2df97fd6, 0xa6abc54e, 0x685828d5, 0xb430fd2d, 0xb708cead, 0x18cba3c0, 0x6d2f2b2d, 0xb3014d4c, 0xf232cd2c ] 
res      =  [ 0x7bf8a58a, 0x9c3446fe, 0xbabd7ce1, 0xac79191a, 0x05a66e2d, 0xdbc884f4, 0xd5330546, 0x97502031, 0x91c4b7f5, 0xfdfd65fa, 0xcd8c67f3, 0xf85d378e, 0xe9a6b118, 0xcaa3c1d4, 0x3ec2bcca, 0xbc558178, 0xbdcabb7c, 0x7900128c, 0x71619d1f, 0xf9a1805d, 0x3b65e898, 0x63509855, 0xc8076669, 0x822dcc65, 0x655d6f7f, 0xc14c1367, 0xd2524cad, 0xffa2b98e, 0x1f9f8bb6, 0x185b99ad, 0x0f59aed2, 0x50796529 ] 

obtained_res = montMul(a,b,n,n_prime,32)

print("Expected : ", end="")
printArray(res, 32)
print("got :      ", end="")
printArray(obtained_res, 32)