#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = random                    
//                                                               
//  The variables are defined for the RSA                        
// encryption and decryption operations. And they are assigned   
// by the script for the generated testvector. Do not create a   
// new variable in this file.                                    
//                                                               
// When you are submitting your results, be careful to verify    
// the test vectors created for seeds from 2024.1, to 2024.5     
// To create them, run your script as:                           
//   $ python testvectors.py rsa 2024.1                          
                                                                 
// modulus                                                       
alignas(128) uint32_t N[32]       = {0xe7a1244f, 0x2cfb89d2, 0xbec81f37, 0x1b86b29a, 0xd2596280, 0x470fe700, 0xd6ae288a, 0x183f231b, 0x8c551b65, 0xc57a9283, 0xb68c8bee, 0xdeb55370, 0x2037e78c, 0x3e2c1580, 0x7ebc97bf, 0xccacb6b6, 0xb987ff4d, 0x1ee12f81, 0x91f023af, 0x8d877663, 0xe3279dd3, 0xe98d926c, 0x6e517fa8, 0x8ab8758f, 0xc34e6dc9, 0xa34fbdb3, 0xa97eec85, 0xd0ab90e2, 0x6d03d620, 0x0f2b6b47, 0x0c6eedce, 0xc40ebbeb};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x0000f8b7};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0xfa721d47, 0x2b7493e7, 0x93141046, 0x1525619f, 0x224208b3, 0xfa4ee957, 0xc8a290e3, 0xf332a039, 0x1c068396, 0x5afda76a, 0xc58cfd3e, 0x12b353f3, 0x6a509297, 0x6e596275, 0xf1de1995, 0x8d1543fd, 0x7b2cf0b2, 0x33c9eef9, 0xb08de335, 0x1d3f9a22, 0xd8765d1e, 0xcda3fbcf, 0x615124b2, 0x57d6b189, 0x43ac9c48, 0x4120a0d4, 0xcaa3ac9c, 0xc1a81767, 0xb5e23940, 0x3e05ccf4, 0x349a32f6, 0x1e3db8e7};           
alignas(128) uint32_t d_len       =  1021;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x6e61551a, 0xac81f152, 0x057e0e67, 0x44c293ef, 0x15ed3da7, 0xea6ff9c1, 0xa77ab672, 0xbf6808b9, 0x481d2911, 0x199de4d6, 0x4e569f73, 0xc12f5a7a, 0x149c97f3, 0x0a59f5a4, 0x103039ad, 0xba6701e5, 0xe05f38ea, 0x7ff7493e, 0x19201504, 0x946efcdc, 0x5abb2696, 0x6bceac9d, 0xfa10777b, 0xb9d40dd8, 0xc406c71b, 0x2f3130ac, 0x75748f68, 0x7905db9c, 0x102241ba, 0xafd583a9, 0x847562a9, 0xbf88e7d4};           
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0x185edbb1, 0xd304762d, 0x4137e0c8, 0xe4794d65, 0x2da69d7f, 0xb8f018ff, 0x2951d775, 0xe7c0dce4, 0x73aae49a, 0x3a856d7c, 0x49737411, 0x214aac8f, 0xdfc81873, 0xc1d3ea7f, 0x81436840, 0x33534949, 0x467800b2, 0xe11ed07e, 0x6e0fdc50, 0x7278899c, 0x1cd8622c, 0x16726d93, 0x91ae8057, 0x75478a70, 0x3cb19236, 0x5cb0424c, 0x5681137a, 0x2f546f1d, 0x92fc29df, 0xf0d494b8, 0xf3911231, 0x3bf14414};        
alignas(128) uint32_t R2_N[32]    = {0x5c674e3c, 0x0d9fe510, 0x272df813, 0x147f2411, 0xb9abfce2, 0xfd1b4944, 0x3d676419, 0x3e8c24f5, 0x5dfd55bc, 0xb14bafd3, 0x1d63fc25, 0x11b5a998, 0xc5394728, 0xbc5bc2fc, 0x641e505f, 0x66b632be, 0xb1b12234, 0xc28b63ab, 0x67dc04f1, 0x9a514e34, 0x6d31ec6d, 0x89b43c43, 0x6cb0e049, 0x8ee60bb3, 0x14884e1f, 0xf1068633, 0xabce305e, 0xae082d46, 0x01d4cf46, 0xf12fb0bf, 0xe12c34ec, 0x0abad4ec};        
