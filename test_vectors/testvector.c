#include <stdint.h>                                              
#include <stdalign.h>                                            
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 2024.5                    
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
alignas(128) uint32_t N[32]       = {0x82fdb85f, 0xecd2dd02, 0xd4cdb6f6, 0x2e480264, 0x7e377731, 0xbf111203, 0xbcb53bf1, 0x369e6a30, 0xb2df937c, 0x34b7417f, 0x9748e1c3, 0x52704147, 0xe831fd08, 0xf442abaf, 0xd96f9753, 0x67f098e2, 0xedd6a65a, 0x464823da, 0xc0e56621, 0xfdc4136f, 0x6b3ccd2e, 0x67c4ba7b, 0x79be1636, 0x548b0320, 0x0bd3f1eb, 0x59f134b1, 0x4fd15206, 0x15e45e0a, 0x8af1fc55, 0x25c5fea3, 0x6c47f27b, 0x832d10e9};           
                                                                              
// encryption exponent                                                        
alignas(128) uint32_t e[32]       = {0x00008e1f};            
alignas(128) uint32_t e_len       = 16;                                       
                                                                              
// decryption exponent, reduced to p and q                                    
alignas(128) uint32_t d[32]       = {0x188dfddf, 0x032c3fac, 0x5accddb7, 0x73990c6a, 0x02bc3f7d, 0x3d6c80cd, 0xbf6535c5, 0xbdf2d5b6, 0x9efb1538, 0x5e0c0ab1, 0xa2643142, 0x663202cd, 0x961302a5, 0x3eba4ad9, 0xb7e35f47, 0x247c9964, 0xac9e9869, 0x0fb895ac, 0xedd84778, 0x269b1036, 0x1c5d59dc, 0xd3687f90, 0xefc10e96, 0xf1fa1fbe, 0xdba271cf, 0x7c0c66ab, 0x64bb05b0, 0xb2978989, 0x00638bfd, 0xc525f5a3, 0x729184c5, 0x5b6ef8a4};           
alignas(128) uint32_t d_len       =  1023;    
                                                                              
// the message                                                                
alignas(128) uint32_t M[32]       = {0x68412c4e, 0x178b2581, 0x424a7145, 0x9e5b6b76, 0x6e9380cf, 0x8a85b200, 0x1cc93bc5, 0xb68eebc8, 0x2d12be1e, 0x423fa6b2, 0x3391d5fd, 0x44d53e7b, 0x52ed09a0, 0x1a971e36, 0x00ad8780, 0xc0e1885e, 0x25579f55, 0x6c808239, 0xd34d3995, 0x09db071d, 0x3f68304f, 0x9a6a0d57, 0xff724eea, 0x39c7cf54, 0xeec7d7d1, 0x52ea9b5a, 0x3dd72f14, 0xd95f245f, 0x6cf9cd47, 0xbc076f42, 0x6cf9bfe6, 0x800bfe4e};           
                                                                              
// R mod N, and R^2 mod N, (R = 2^1024)                                       
alignas(128) uint32_t R_N[32]     = {0x7d0247a1, 0x132d22fd, 0x2b324909, 0xd1b7fd9b, 0x81c888ce, 0x40eeedfc, 0x434ac40e, 0xc96195cf, 0x4d206c83, 0xcb48be80, 0x68b71e3c, 0xad8fbeb8, 0x17ce02f7, 0x0bbd5450, 0x269068ac, 0x980f671d, 0x122959a5, 0xb9b7dc25, 0x3f1a99de, 0x023bec90, 0x94c332d1, 0x983b4584, 0x8641e9c9, 0xab74fcdf, 0xf42c0e14, 0xa60ecb4e, 0xb02eadf9, 0xea1ba1f5, 0x750e03aa, 0xda3a015c, 0x93b80d84, 0x7cd2ef16};        
alignas(128) uint32_t R2_N[32]    = {0x2c4f65df, 0x28c8c14d, 0x01a8e745, 0x9e0c7665, 0x91617c61, 0x1d19f784, 0x15eefa14, 0xdd22583f, 0xb78521ff, 0x749f2485, 0xe3e413f1, 0x82ff0964, 0x7ff0ead6, 0x68cc150c, 0x6ecf5a74, 0x0a883f52, 0x6ec40532, 0x5c4df038, 0x60c66e25, 0xeb9fcc20, 0x058b78cb, 0x777dabd1, 0xcd2c3b6a, 0x22ec7036, 0xf40f7e7a, 0xa1ad03b1, 0x142c6779, 0xa591893a, 0xa41beede, 0x17b347d0, 0x4ff11990, 0x2d9873fd};        
