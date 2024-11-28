#include <stdint.h>
#include <stdio.h>
#include <stdalign.h>

void print_array_contents(uint32_t* src) {
  int i;
  printf("1024'h");
  for (i=32-4; i>=0; i-=4)
    printf("%08x%08x%08x%08x",
      src[i+3], src[i+2], src[i+1], src[i]);
}


int main(){
    // This data comes from the testvectors.py
    alignas(128) uint32_t N1[32]       = {0x28c9249d, 0x2d275cd9, 0x47a5e814, 0x58e314bf, 0x3b3a20de, 0xa1fd8b70, 0xbc860be0, 0xe5345506, 0x59000e06, 0xe99045ab, 0xdef188ef, 0x3de09b8c, 0xe683fc3c, 0x458971b6, 0xdddab60b, 0x01d3de7d, 0x9d964404, 0xd520ac97, 0x2f8272f1, 0x88695fd1, 0x7556d714, 0x015e270b, 0x08714b05, 0x78055a3d, 0xf6933249, 0x0bba4028, 0x6bb24dd6, 0xdcf9069c, 0x3339650a, 0x98a62f43, 0x400aba4c, 0xccd61077};
    alignas(128) uint32_t e1[32]       = {0x00009985}; 
    alignas(128) uint32_t e1_len       = 16;
    alignas(128) uint32_t M1[32]       = {0x433b2afe, 0x5d058af9, 0xfe6a62b6, 0xad8a0fd6, 0x671397f0, 0xb6c466fd, 0x11a9378d, 0xd3d7226b, 0xe329c697, 0xcfeee16b, 0x4deda86f, 0xb20079da, 0xa40fef1e, 0xf9c9c2ef, 0xc4cef4e3, 0x79638497, 0x9df17a81, 0xb8de0411, 0xefb98465, 0x46d0fccb, 0xadb1e6f2, 0x73b23009, 0xa8d0087b, 0xd54dfc4f, 0xb055e0b0, 0x32ece3c7, 0x9c7dbc98, 0x6d598dc5, 0xdad62ff1, 0xdfdd8a07, 0xe833600a, 0x8eb60bf5};
    alignas(128) uint32_t R_N1[32]     = {0xd736db63, 0xd2d8a326, 0xb85a17eb, 0xa71ceb40, 0xc4c5df21, 0x5e02748f, 0x4379f41f, 0x1acbaaf9, 0xa6fff1f9, 0x166fba54, 0x210e7710, 0xc21f6473, 0x197c03c3, 0xba768e49, 0x222549f4, 0xfe2c2182, 0x6269bbfb, 0x2adf5368, 0xd07d8d0e, 0x7796a02e, 0x8aa928eb, 0xfea1d8f4, 0xf78eb4fa, 0x87faa5c2, 0x096ccdb6, 0xf445bfd7, 0x944db229, 0x2306f963, 0xccc69af5, 0x6759d0bc, 0xbff545b3, 0x3329ef88};
    alignas(128) uint32_t R2_N1[32]    = {0x1247ae04, 0x847a5bd1, 0xad9bd3f5, 0x114f8acd, 0x1202d618, 0x37198dd8, 0x3f74e618, 0xbaf66206, 0xb62440a8, 0x3f787503, 0xd5258da9, 0x9bca8d50, 0x03ee5078, 0x77949f4f, 0x520c79b5, 0x3f92cef0, 0xfdd351a3, 0x4e96c23d, 0xd043fc80, 0xf13f8be9, 0x6c9a19f2, 0xfb8ad493, 0x91abfe40, 0x444da791, 0xa336a065, 0xec2d0339, 0x6c347e19, 0x17580550, 0xd1b94a0d, 0xadb669fe, 0xccf6db0e, 0x1f15c169};

    print_array_contents(N1);
    printf("\n___\n");
    print_array_contents(M1);
    printf("\n___\n");
    print_array_contents(R_N1);
    printf("\n___\n");
    print_array_contents(R2_N1);
    printf("\n");

    return 0;
}