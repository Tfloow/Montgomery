my_message = "Hello world ! This is a message that is longer than 128 characters. So we can also check if this handles longer string of character (hopefully). Can you decrypt it ?"

transformed = ''.join(str(hex(ord(c))[2:]) for c in my_message)[:128*2]


N       = 0x28c9249d2d275cd947a5e81458e314bf3b3a20dea1fd8b70bc860be0e534550659000e06e99045abdef188ef3de09b8ce683fc3c458971b6dddab60b01d3de7d9d964404d520ac972f8272f188695fd17556d714015e270b08714b0578055a3df69332490bba40286bb24dd6dcf9069c3339650a98a62f43400aba4cccd61077                                                            
e       = 0x00009985         
e_len       = 16                                                                      
d       = 0x0140f46de8ca4cb42fd3b080b3847fcd25a13e1a0d32d306c8e8f4b9452468067c4fa9c6fbc6c8ab7254281bb490e8ae7b277a9ac7146fc38258bf2778513490121422745570bc18fd1abea56036cb79f6e633a26e9f550c5efa66325093578a69d5dbbe311d223fd83a7ae3a68011ce1661a975948034ef98f8271b20df3a57         
d_len       =  1022                                                              
M       = 0x433b2afe5d058af9fe6a62b6ad8a0fd6671397f0b6c466fd11a9378dd3d7226be329c697cfeee16b4deda86fb20079daa40fef1ef9c9c2efc4cef4e3796384979df17a81b8de0411efb9846546d0fccbadb1e6f273b23009a8d0087bd54dfc4fb055e0b032ece3c79c7dbc986d598dc5dad62ff1dfdd8a07e833600a8eb60bf5                                        
R_N     = 0xd736db63d2d8a326b85a17eba71ceb40c4c5df215e02748f4379f41f1acbaaf9a6fff1f9166fba54210e7710c21f6473197c03c3ba768e49222549f4fe2c21826269bbfb2adf5368d07d8d0e7796a02e8aa928ebfea1d8f4f78eb4fa87faa5c2096ccdb6f445bfd7944db2292306f963ccc69af56759d0bcbff545b33329ef88       
R2_N    = 0x1247ae04847a5bd1ad9bd3f5114f8acd1202d61837198dd83f74e618baf66206b62440a83f787503d5258da99bca8d5003ee507877949f4f520c79b53f92cef0fdd351a34e96c23dd043fc80f13f8be96c9a19f2fb8ad49391abfe40444da791a336a065ec2d03396c347e1917580550d1b94a0dadb669feccf6db0e1f15c169       


print(transformed)
print(e)
print(d)
print(N)
