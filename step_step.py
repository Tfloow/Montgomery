# this is an estimation based on the 64 first and last bits of every operand
a = 0x2394a8c9e2c6abc0edb8734fb607d38620559f7220a7a45b60a298241a9888760f0aede90b9467975a6cf461e75242d6871a24d024f15ca6ab969a1617a5432363b4792838172caf1dec516490c43b22d592c9f84294af8bfe9ccd0e09cd5a683c84feec717eb638c74228f1393f8ebcf634845a3b1c51f893c2286ef76f49b1
b = 0x33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517
m = 0x83a6c5c93235f2f4905daaa92deddb7235d196d00c713a582030a113495b64c40d579c795c171370251a7651affcd685caeee9b4b7c1f7ed3c805f565c2ac5ed7e83e68b34ffba6bdeeb98894c6a406a4e6a2ea9d45e0285d4ad9250e6108b07150d513e834ae1d93ba570636737aaedf95d829f9bdb8ceeb0fefd5e1d47ef05

c = 0

print(bin(a))

for i in range(0,10,2):
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
    
    c = c - m

    print(f"After step : {hex(c)}")
    print()

print(f"Finish : {hex(c)}")
print()

