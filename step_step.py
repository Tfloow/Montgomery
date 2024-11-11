# this is an estimation based on the 64 first and last bits of every operand
a = 0xa958eb1ec7084cf83d25941ba30b0aadaad986839a3a8e3028503037e875bce4637cdd321ca3ffe3c39adb4dfbbc230d4c2237acc33f636f2b9f4edb9d9401a9c2b2a90f26c56cefe22d49eefd468bbcb82a645835a537a9b80c3b9a8b16e6f271eece2712b9d229dc7534b9512c9fe0ee4ec5642dcb0c51c75d6baa6b219b97
b = 0x9cabe30bb78713ae0cff2f816a4fb7ca0633e5598cf4f6b2274bfa55522d4130ce5c7c664427aa56bb471ad1727d11dfa83162695e19fd434025a7893d04cceab19910ab60c1691dd2a5fb4f45ad6f685e98eca311cc388bb197e52df9b17776e84ef3121a773482cdc3dbfc548396abf3bf3dd70f217e4da5bda2e4eb76b197
m = 0xe14accdd8d4576ec8485f5589055b1caca2ebf09486d8f1e7870695a5fd3754b497c7c7f85fd2c2494df65f34e8be4b6ce67ea5e430793519f94c1c64abff479ad99cea14fa1f042f6a3d1b73d549e1da1c62f7854d012c5065953008e8a32c34191f144894c87c4ed6869cd5368df5fca97a90eae185bada3244e021c3791d3

c = 0

print(bin(a))

for i in range(0,1023,2):
    print(f"{'_':_<20} i = {i} {'_':_<20}")
    mask = 0b11 << i
    
    print(f"Operand A : {hex(c)}")
    print(f"Operand B : {hex((((a & mask) >> i) * b))}")
    print(f"Maks val  : {(((a & mask) >> i))}")

    c = c + (((a & mask) >> i) * b)
    


    print(f"First step : {hex(c)}")
    print()

    if(((c & 0b11) == 1) & ((m & 0b11) == 1) | ((c & 0b11) == 3) & ((m & 0b11) == 3)):
        print(f"Operand A : {hex(c)}")
        print(f"Operand B : {hex(3*m)}")
        c = (c + 3*m) >> 2
        print("First")
    elif (((c & 0b11) == 2) & ((m & 0b11) == 1) | ((c & 0b11) == 2) & ((m & 0b11) == 3)):
        print(f"Operand A : {hex(c)}")
        print(f"Operand B : {hex(m)}")
        c = (c + 2*m) >> 2
        print("Second")
    elif (((c & 0b11) == 3) & ((m & 0b11) == 1) | ((c & 0b11) == 1) & ((m & 0b11) == 3)):
        print(f"Operand A : {hex(c)}")
        print(f"Operand B : {hex(m)}")
        c = (c + m) >> 2
        print("Third")
    else:
        c = c >> 2
        print("Last")
    print(f"Second step : {hex(c)}")
    print()

while(c > m):
    print(f"{'_':_<20} Condition Subtraction {'_':_<20}")
    print(f"Before step : {hex(c)}")
    
    c = c - m

    print(f"After step : {hex(c)}")
    print()

print(f"Finish : {hex(c)}")
print()

