import helpers
import HW
import SW

import sys

operation = 0
seed = "random"

print ("TEST VECTOR GENERATOR FOR DDP\n")

if len(sys.argv) in [2,3,4]:
  if str(sys.argv[1]) == "adder":           operation = 1
  if str(sys.argv[1]) == "subtractor":      operation = 2
  if str(sys.argv[1]) == "multiplication":  operation = 3
  if str(sys.argv[1]) == "exponentiation":  operation = 4
  if str(sys.argv[1]) == "rsa":             operation = 5

if len(sys.argv) in [3,4]:
  print ("Seed is: ", sys.argv[2], "\n")
  seed = sys.argv[2]
  helpers.setSeed(sys.argv[2])

if len(sys.argv) == 4:
  if (sys.argv[3].upper() == "NOWRITE"):
    print ("NOT WRITING TO TESTVECTOR.C FILE \n")

#####################################################

if operation == 0:
  print ("You should use this script by passing an argument like:")
  print (" $ python testvectors.py adder")
  print (" $ python testvectors.py subtractor")
  print (" $ python testvectors.py multiplication")
  print (" $ python testvectors.py exponentiation")
  print (" $ python testvectors.py rsa")
  print ("")
  print ("You can also set a seed for randomness to work")
  print ("with the same testvectors at each execution:")
  print (" $ python testvectors.py rsa 2024")
  print ("")
  print ("To NOT write to testvector.c file automatically: ")
  print (" $ python testvectors.py rsa 2024 nowrite")
  print ("")

#####################################################

if operation == 1:
  print ('#10 start = 1;')

  A = helpers.getRandomInt(1027)
  B = helpers.getRandomInt(1027)
  C = HW.MultiPrecisionAddSub_1027(A,B,"add")

  print ("in_a = 1027'", hex(A), ";")           # 1027-bits
  print ("in_b = 1027'", hex(B), ";")           # 1027-bits
  print("subtract = 0;")
  print ("expected_results = 1028'", hex(C), ";")           # 1028-bits
  
  print("#10 start = 0;")
  print(r'#100')
  print(r'$display("Diff =%x", expected_results-result);')
  print("#10")
#####################################################

if operation == 2:
  print ('#10 start = 1;')

  A = helpers.getRandomInt(1027)
  B = helpers.getRandomInt(1027)
  C = HW.MultiPrecisionAddSub_1027(A,B,"subtract")

  print ("in_a = 1027'", hex(A), ";")           # 1027-bits
  print ("in_b = 1027'", hex(B), ";")           # 1027-bits
  print("subtract = 1;")
  print ("expected_results = 1028'", hex(C), ";")           # 1028-bits
  
  print("#10 start = 0;")
  print(r'#100')
  print(r'$display("Diff =%x", expected_results-result);')
  print("#10")

#####################################################

if operation == 3:

  print ("Test Vector for Windoed Montgomery Multiplication\n")

  M = helpers.getModulus(1024)
  A = helpers.getRandomInt(1024) % M
  B = helpers.getRandomInt(1024) % M

  C = SW.MontMul(A, B, M)
  D = HW.MontMul(A, B, M)

  e = (C - D)

  print ("A                = ", hex(A))           # 1024-bits
  print ("B                = ", hex(B))           # 1024-bits
  print ("M                = ", hex(M))           # 1024-bits
  print ("(A*B*R^-1) mod M = ", hex(C))           # 1024-bits
  print ("(A*B*R^-1) mod M = ", hex(D))           # 1024-bits
  print ("error            = ", hex(e))

#####################################################

if operation == 4:

  print ("Test Vector for Montgomery Exponentiation\n")

  X = helpers.getRandomInt(1024)
  E = helpers.getRandomInt(8)
  M = helpers.getModulus(1024)
  C = HW.MontExp_MontPowerLadder(X, E, M)
  D = helpers.Modexp(X, E, M)
  e = C - D

  print ("X                = ", hex(X))           # 1024-bits
  print ("E                = ", hex(E))           # 8-bits
  print ("M                = ", hex(M))           # 1024-bits
  print ("(X^E) mod M      = ", hex(C))           # 1024-bits
  print ("(X^E) mod M      = ", hex(D))           # 1024-bits
  print ("error            = ", hex(e))

#####################################################

if operation == 5:

  print ("Test Vector for RSA\n")

  print ("\n--- Precomputed Values")

  # Generate two primes (p,q), and modulus
  [p,q,N] = helpers.getModuli(1024)

  print ("p            = ", hex(p))               # 512-bits
  print ("q            = ", hex(q))               # 512-bits
  print ("Modulus      = ", hex(N))               # 1024-bits

  # Generate Exponents
  [e,d] = helpers.getRandomExponents(p,q)

  print ("Enc exp      = ", hex(e))               # 16-bits
  print ("Dec exp      = ", hex(d))               # 1024-bits

  # Generate Message
  M     = helpers.getRandomMessage(1024,N)

  print ("Message      = ", hex(M))               # 1024-bits

  if len(sys.argv) == 4:
    if (sys.argv[3].upper() != "NOWRITE"):
      helpers.CreateConstants(seed, N, e, d, M)
  else:
    helpers.CreateConstants(seed, N, e, d, M)

  #####################################################

  print ("\n--- Execute RSA (for verification)")

  # Encrypt
  Ct = SW.MontExp(M, e, N)                        # 1024-bit exponentiation
  print ("Ciphertext   = ", hex(Ct))              # 1024-bits
  print("{ ", helpers.WriteConstants(Ct,32), " }")

  # Decrypt
  Pt = SW.MontExp(Ct, d, N)                       # 1024-bit exponentiation
  print ("Plaintext    = ", hex(Pt))              # 1024-bits

  #####################################################

  print ("\n--- Execute RSA in HW (slow)")

  # Encrypt
  Ct = HW.MontExp_MontPowerLadder(M, e, N)        # 1024-bit exponentiation
  print ("Ciphertext   = ", hex(Ct))              # 1024-bits
  # Decrypt
  Pt = HW.MontExp_MontPowerLadder(Ct, d, N)       # 1024-bit exponentiation
  print ("Plaintext    = ", hex(Pt))              # 1024-bits
