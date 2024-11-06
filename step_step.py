# this is an estimation based on the 64 first and last bits of every operand
a = 0x993a45a7ccc9834b9775fbbf1be8566199cf3883f29a2846a7357f314b1b6a719edf9b543addb902a023885c72b83d21d6bc2a14ed8adef3566f0da4c541f83c882bc4a1c21cb045d17eb1f773535af04b82a90c5823ac4f3076dbbd37c7019cb84e7b2e21849abd2860ef93d144c8564492ec8036b3d1a51bd98c94c145d8c3
b = 0xa21716d123007a82e337ffa9de869fbebb20cd18955897dc2b9e096146b56d5706ee40c1d38b6ab293f1ea65d8d8c98bbaad3ddd301080f3f1e11e02aa5c19b22a62d225bab93a13b629bfb493792fed1b7fa42442888c8e71b6de10dedeaa77a5c8a15bad9380346279ebc55720df62186e222a698a238f472e7d24ad2c6b2f
m = 0xc195d759bc8a96f3a59c363f4f4d8b596ce12e0aca41fca232eb07944fc92b2f798a902095c69a1c8c3ecd049169fe7ed2d1ae296658546e5b500edcf935e9a1a11ab841332a7a430f188012e42162703fbfba6be85ada06ec9a4fd80dab436c7a60ef5c1aa0a67c4542049b94dc649e57c56f782498df91c78f7c463cb6329d

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
    
    c = c - m

    print(f"After step : {hex(c)}")
    print()

print(f"Finish : {hex(c)}")
print()

