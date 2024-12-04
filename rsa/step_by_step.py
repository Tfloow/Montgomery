import math

def MultiPrecisionAddSub_1026(A, B, addsub):
    # returns (A + B) mod 2^1026 if   addsub == "add"
    #         (A - B) mod 2^1026 else
    
    mask1026  = 2**1026 - 1
    mask1027  = 2**1027 - 1

    am     = A & mask1026
    bm     = B & mask1026

    if addsub == "add": 
        r = (am + bm) 
    else:
        r = (am - bm)
    
    return r & mask1027

def MontMul(A, B, M):
    # Returns (A*B*Modinv(R,M)) mod M
    
    regA  = A
    regB  = B
    regC  = 0
    regM  = M

    for i in range(0,1024):
        
        if (regA % 2) == 0  : regC = regC
        else                : regC = MultiPrecisionAddSub_1026(regC, regB, "add")
        
        if (regC % 2) == 0  : regC = regC >> 1
        else                : regC = MultiPrecisionAddSub_1026(regC, regM, "add") >> 1
    
        regA = regA >> 1

    while regC >= regM:
        regC = MultiPrecisionAddSub_1026(regC, regM, "sub")
    
    return regC

def MontMul(A, B, M, DBG):
    # Returns (A*B*Modinv(R,M)) mod M
    print(f"A : {A:02X}")
    print(f"B : {B:02X}")
    print(f"M : {M:02X}")
    
    regA  = A
    regB  = B
    regC  = 0
    regM  = M

    for i in range(0,1024):
        
        if (regA % 2) == 0  : regC = regC
        else                : regC = MultiPrecisionAddSub_1026(regC, regB, "add")
        
        if (regC % 2) == 0  : regC = regC >> 1
        else                : regC = MultiPrecisionAddSub_1026(regC, regM, "add") >> 1
    
        regA = regA >> 1

    while regC >= regM:
        regC = MultiPrecisionAddSub_1026(regC, regM, "sub")
    
    return regC

def bitlen(n):
    return int(math.log(n, 2)) + 1

def bit(y,index):
  bits   = [(y >> i) & 1 for i in range(1024)]
  bitstr = ''.join([chr(sum([bits[i * 8 + j] << j for j in range(8)])) for i in range(1024 >> 3)])
  return (ord(bitstr[index >> 3]) >> (index%8)) & 1

def MontExp_MontPowerLadder(X, E, N):
    # Returns (X^E) mod N
    
    R  = 2**1024
    RN = R % N
    R2N = (R*R) % N
    A  = RN
    X_tilde = MontMul(X,R2N,N)
    t = bitlen(E)
    for i in range(0,t):
        if bit(E,t-i-1) == 1:
            A       = MontMul(A,X_tilde,N)
            X_tilde = MontMul(X_tilde,X_tilde,N)
        else:
            X_tilde = MontMul(A,X_tilde,N)
            A       = MontMul(A,A,N)
    A = MontMul(A,1,N)
    return A

def MontExp_MontPowerLadder(X, E, N, DBG):
    # Returns (X^E) mod N
    print(DBG)
    R  = 2**1024
    RN = R % N
    R2N = (R*R) % N
    A  = RN
    X_tilde = MontMul(X,R2N,N, DBG)
    print(f"X_tilde : {X_tilde:02X}")
    t = bitlen(E)
    for i in range(0,t):
        print(f"{'_'*20:20} {i}")
        print(t-i-1)
        if bit(E,t-i-1) == 1:
            print("First Condition")
            print("CMD : 0x01")
            A       = MontMul(A,X_tilde,N, DBG)
            print(f"Result : {A:02X}")
            print(f"{'_'*20:20}")
            print("CMD : 0x0B")
            X_tilde = MontMul(X_tilde,X_tilde,N, DBG)
            print(f"Result : {X_tilde:02X}")
        else:
            print("Second Condition")
            print("CMD : 0x0D")
            X_tilde = MontMul(A,X_tilde,N, DBG)
            print(f"Result : {X_tilde:02X}")
            print(f"{'_'*20:20}")
            print("CMD : 0x03")
            A       = MontMul(A,A,N, DBG)
            print(f"Result : {A:02X}")

        #break
    print(f"{'_'*20:20}")
    A = MontMul(A,1,N, DBG)
    print(f"Result : {A:02X}")
    return A

if __name__ == "__main__":
    X = 0x8eb60bf5e833600adfdd8a07dad62ff16d598dc59c7dbc9832ece3c7b055e0b0d54dfc4fa8d0087b73b23009adb1e6f246d0fccbefb98465b8de04119df17a8179638497c4cef4e3f9c9c2efa40fef1eb20079da4deda86fcfeee16be329c697d3d7226b11a9378db6c466fd671397f0ad8a0fd6fe6a62b65d058af9433b2afe
    E = 0x00009985
    N = 0xccd61077400aba4c98a62f433339650adcf9069c6bb24dd60bba4028f693324978055a3d08714b05015e270b7556d71488695fd12f8272f1d520ac979d96440401d3de7ddddab60b458971b6e683fc3c3de09b8cdef188efe99045ab59000e06e5345506bc860be0a1fd8b703b3a20de58e314bf47a5e8142d275cd928c9249d

    MontExp_MontPowerLadder(X,E,N, 1)
