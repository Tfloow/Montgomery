#include "common.h"
#include <stdalign.h>
#include <math.h>
#include <string.h>
  
// These variables are defined in the testvector.c
// that is created by the testvector generator python script
extern uint32_t N[32],    // modulus
                e[32],    // encryption exponent
                e_len,    // encryption exponent length
                d[32],    // decryption exponent
                d_len,    // decryption exponent length
                M[32],    // message
                R_N[32],  // 2^1024 mod N
                R2_N[32];// (2^1024)^2 mod N

#define ISFLAGSET(REG,BIT) ( (REG & (1<<BIT)) ? 1 : 0 )
#define SEND_MY_MESSAGE 0

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    xil_printf("%08x %08x %08x %08x\n\r",
      src[i+3], src[i+2], src[i+1], src[i]);
}

void write_to_buffer(uint32_t* message_buffer, char* message){
    /*
    message_buffer : a 128 bytes array of 32 bits integer
    message        : a string of character we want to send that has been already set into 128 bytes
    */
    // Writing to the buffer
    for(int i = 32; i > 0; i--){
        message_buffer[i-1] = (uint32_t) (message[128 - 4*i + 3]) + (uint32_t) ((message[128 - 4*i + 2]) << 8)
                            + (uint32_t) ((message[128 - 4*i + 1]) << 16) + (uint32_t) ((message[128 - 4*i + 0]) << 24); // write 8 bits character in 4 bytes
    }
}

void encode_message(uint32_t* m, char* message_to_send, uint32_t size, uint32_t blocks){
  /*
  m               : the 128 bytes aligned buffer 
  message_to_send : the full text we want to encrypt
  size            : amount of character in the message_to_send string
  blocks          : to keep track if we are at the first or more block of message
  */
  char sanitize_input[32*4] = {0};
  // write to the sanitize input
  for(uint32_t j = 0; j < fmin(128, size - blocks*128); j++){
      sanitize_input[j] = message_to_send[blocks*128 + j];
  }
  write_to_buffer(m, sanitize_input);
}

int main() {

  init_platform();
  init_performance_counters(0);

  xil_printf("Begin\n\r");

  // Register file shared with FPGA
  volatile uint32_t* HWreg = (volatile uint32_t*)0x40400000;

  #define COMMAND 0
  #define RXADDR  1
  #define TXADDR  2
  #define T       3
  #define T_LEN   4
  #define LOADING 5
  // OUT
  #define STATUS  0
  #define LSB_N    1
  #define LSB_R_N  2
  #define LSB_R2_N 3
  #define DMA_RX 4
  #define LOADING 5
  #define STATE 6
  // DBG
  #define DBG 0

  // Aligned input and output memory shared with FPGA
  alignas(128) uint32_t idata[32];
  alignas(128) uint32_t odata[32];

  // Initialize odata to all zero's
  memset(odata,0,128);
  memset(idata,0,128);

  printf("RXADDR %08X\r\n", (unsigned int)HWreg[RXADDR]);
  printf("TXADDR %08X\r\n", (unsigned int)HWreg[TXADDR]);

  printf("STATUS %08X\r\n", (unsigned int)HWreg[STATUS]);
  printf("REG[3] %08X\r\n", (unsigned int)HWreg[3]);
  printf("REG[4] %08X\r\n", (unsigned int)HWreg[4]);

  // Thomas writing
  // For the exponentiation we need to provide M, e, N, R mod N, R^2 mod N
  // R is just 2^1024
  // So we need to send 5 1024 bits data

  // This data comes from the testvectors.py
  alignas(128) uint32_t N1[32]       = {0x28c9249d, 0x2d275cd9, 0x47a5e814, 0x58e314bf, 0x3b3a20de, 0xa1fd8b70, 0xbc860be0, 0xe5345506, 0x59000e06, 0xe99045ab, 0xdef188ef, 0x3de09b8c, 0xe683fc3c, 0x458971b6, 0xdddab60b, 0x01d3de7d, 0x9d964404, 0xd520ac97, 0x2f8272f1, 0x88695fd1, 0x7556d714, 0x015e270b, 0x08714b05, 0x78055a3d, 0xf6933249, 0x0bba4028, 0x6bb24dd6, 0xdcf9069c, 0x3339650a, 0x98a62f43, 0x400aba4c, 0xccd61077};
  alignas(128) uint32_t e1[32]       = {0x00009985};
  uint32_t e1_len       = 16;
  alignas(128) uint32_t d1[32]       = {0x0140f46d, 0xe8ca4cb4, 0x2fd3b080, 0xb3847fcd, 0x25a13e1a, 0x0d32d306, 0xc8e8f4b9, 0x45246806, 0x7c4fa9c6, 0xfbc6c8ab, 0x7254281b, 0xb490e8ae, 0x7b277a9a, 0xc7146fc3, 0x8258bf27, 0x78513490, 0x12142274, 0x5570bc18, 0xfd1abea5, 0x6036cb79, 0xf6e633a2, 0x6e9f550c, 0x5efa6632, 0x5093578a, 0x69d5dbbe, 0x311d223f, 0xd83a7ae3, 0xa68011ce, 0x1661a975, 0x948034ef, 0x98f8271b, 0x20df3a57};           
  alignas(128) uint32_t d1_len       =  1022;    
  alignas(128) uint32_t M1[32]       = {0x433b2afe, 0x5d058af9, 0xfe6a62b6, 0xad8a0fd6, 0x671397f0, 0xb6c466fd, 0x11a9378d, 0xd3d7226b, 0xe329c697, 0xcfeee16b, 0x4deda86f, 0xb20079da, 0xa40fef1e, 0xf9c9c2ef, 0xc4cef4e3, 0x79638497, 0x9df17a81, 0xb8de0411, 0xefb98465, 0x46d0fccb, 0xadb1e6f2, 0x73b23009, 0xa8d0087b, 0xd54dfc4f, 0xb055e0b0, 0x32ece3c7, 0x9c7dbc98, 0x6d598dc5, 0xdad62ff1, 0xdfdd8a07, 0xe833600a, 0x8eb60bf5};
  alignas(128) uint32_t R_N1[32]     = {0xd736db63, 0xd2d8a326, 0xb85a17eb, 0xa71ceb40, 0xc4c5df21, 0x5e02748f, 0x4379f41f, 0x1acbaaf9, 0xa6fff1f9, 0x166fba54, 0x210e7710, 0xc21f6473, 0x197c03c3, 0xba768e49, 0x222549f4, 0xfe2c2182, 0x6269bbfb, 0x2adf5368, 0xd07d8d0e, 0x7796a02e, 0x8aa928eb, 0xfea1d8f4, 0xf78eb4fa, 0x87faa5c2, 0x096ccdb6, 0xf445bfd7, 0x944db229, 0x2306f963, 0xccc69af5, 0x6759d0bc, 0xbff545b3, 0x3329ef88};
  alignas(128) uint32_t R2_N1[32]    = {0x1247ae04, 0x847a5bd1, 0xad9bd3f5, 0x114f8acd, 0x1202d618, 0x37198dd8, 0x3f74e618, 0xbaf66206, 0xb62440a8, 0x3f787503, 0xd5258da9, 0x9bca8d50, 0x03ee5078, 0x77949f4f, 0x520c79b5, 0x3f92cef0, 0xfdd351a3, 0x4e96c23d, 0xd043fc80, 0xf13f8be9, 0x6c9a19f2, 0xfb8ad493, 0x91abfe40, 0x444da791, 0xa336a065, 0xec2d0339, 0x6c347e19, 0x17580550, 0xd1b94a0d, 0xadb669fe, 0xccf6db0e, 0x1f15c169};

  alignas(128) uint32_t N2[32]       = {0xbd254e67, 0x2612fc2c, 0x92acbb8c, 0x200c3f02, 0xbaa6def6, 0x07e5428b, 0xf30a5f46, 0x8da94e3a, 0x36e8ed11, 0x43554989, 0x5d2bb1fb, 0x730d4246, 0xb11a64a9, 0x5702a21f, 0x5d5f692e, 0x67fcb9cf, 0x87ca8c97, 0x151f4cbc, 0x380aa837, 0x005565c2, 0xe6ca10c0, 0x00f1b04d, 0xf1a672db, 0x69965c9d, 0x23f78f4a, 0x7e26e084, 0xd7d82b6a, 0xb754e3f9, 0xdeb9bad5, 0x2fbaf4e5, 0x3007be0d, 0x95df9303};
  alignas(128) uint32_t e2[32]       = {0x0000dc85};
  uint32_t e2_len       = 16;
  alignas(128) uint32_t d2[32]        = {0x584de77d, 0x5d1feb8b, 0x8cdb1000, 0xaa4082b5, 0x6b22a217, 0x7dc416d0, 0x9ea82b83, 0xdabe99cf, 0x2efab48c, 0x80b8685d, 0x1e2542cc, 0xdb6aec3b, 0x5eef2cfc, 0xf047fff1, 0xb3afb61a, 0x646d1270, 0xe3546a41, 0xcc8fdc68, 0xcee73e66, 0x07c2ff8a, 0xe4f8b9ab, 0x40cf5181, 0x2cd67859, 0x5f6770e9, 0x6da55b69, 0x174e327e, 0x92b928b5, 0x8c8080fb, 0x8f121111, 0x765ecfad, 0x6a4ac123, 0x8fdb8408};           
  alignas(128) uint32_t d2_len        =  1024; 
  alignas(128) uint32_t M2[32]       = {0xae0a4bb1, 0x4e978eca, 0x1aae08bb, 0x063c1b7a, 0xf3f49bca, 0x08c0b66a, 0xb1436f1b, 0x500b8193, 0x78572616, 0xefac7ce0, 0xdb3060dd, 0xcf9bad31, 0x60a90d7e, 0x59b867e1, 0xa2b78c54, 0x72f78be5, 0xd6a9b24e, 0x38e1c835, 0x785f4baa, 0x2b245afb, 0xc4d85d48, 0xae15482e, 0x04d265ae, 0xb2640402, 0xd12cd363, 0xc1037d3e, 0x7b197428, 0xb934963b, 0xc4cb7a5a, 0x5b61821c, 0x07d7f9b9, 0x8a82ed13};
  alignas(128) uint32_t R_N2[32]     = {0x42dab199, 0xd9ed03d3, 0x6d534473, 0xdff3c0fd, 0x45592109, 0xf81abd74, 0x0cf5a0b9, 0x7256b1c5, 0xc91712ee, 0xbcaab676, 0xa2d44e04, 0x8cf2bdb9, 0x4ee59b56, 0xa8fd5de0, 0xa2a096d1, 0x98034630, 0x78357368, 0xeae0b343, 0xc7f557c8, 0xffaa9a3d, 0x1935ef3f, 0xff0e4fb2, 0x0e598d24, 0x9669a362, 0xdc0870b5, 0x81d91f7b, 0x2827d495, 0x48ab1c06, 0x2146452a, 0xd0450b1a, 0xcff841f2, 0x6a206cfc};
  alignas(128) uint32_t R2_N2[32]    = {0x3dfe4ace, 0xf14fdebd, 0x6b9b20ec, 0xe7659f64, 0xb1e06915, 0x1d86e802, 0x3bea9fda, 0x8e6e4703, 0x2168546c, 0x006192fa, 0xdac8169a, 0x0f78083b, 0xaa044776, 0xc66fefd1, 0xb6a3777c, 0x91b889cb, 0x36faf504, 0x49cc0ce1, 0x420cbadb, 0xc36a2d17, 0x2adea798, 0xd3a11417, 0x87ba5dc8, 0x02b7915f, 0x7889c9c4, 0x3ce80a0c, 0xc9a84058, 0x8032b2ec, 0xfdaea751, 0xcf15b33a, 0x74e77354, 0x2875888c};

  alignas(128) uint32_t N3[32]       = {0x4d9882e1, 0x8d406d5e, 0x89a23c48, 0xb2ac5bb8, 0xa8788a71, 0x09cb0491, 0x697a3c7c, 0x42a46497, 0xac2364c6, 0xe98e5858, 0x2d5b2488, 0xc3fc921b, 0x15a29b2b, 0xf428ba22, 0x63ea9a75, 0xd84a1fe6, 0x2a447c77, 0xad941c53, 0xb435f31e, 0x3b6863b7, 0x2e2b6b87, 0x1451c9f7, 0x5d643274, 0xa6441ac8, 0x088a3a7b, 0x02c56b4a, 0x6d57efc9, 0x43149240, 0x8ae64021, 0x3b938c83, 0x5f1ff702, 0xc7a8a8d8};
  alignas(128) uint32_t e3[32]       = {0x0000a295};
  uint32_t e3_len       = 16;
  alignas(128) uint32_t d3[32]       = {0x47ebebbd, 0xe04e889a, 0x93347a79, 0xfe6bd1ed, 0x8a84a417, 0x53026e4a, 0xbc36a7a1, 0x5485c36a, 0x4d8a5437, 0xf087ecda, 0x932b1e00, 0x886ae030, 0x8fcd10eb, 0x489dfea6, 0x8eba3569, 0x300919f0, 0xea92eb4d, 0x8e43cb19, 0xf41ea744, 0x1e9775aa, 0xab59f4fa, 0xbba0b857, 0x29286dad, 0x0f674489, 0x2d5ee931, 0x4f1b22f0, 0xb5725487, 0x820ec808, 0x6ff80d8d, 0x73c2b92c, 0xa633c70b, 0xa729d9b3};           
  alignas(128) uint32_t d3_len       =  1024;    
  alignas(128) uint32_t M3[32]       = {0xd62ebb3d, 0xe8e29ae6, 0xcaf0fc16, 0x4f2f7bad, 0x40b5a916, 0xb38e5ce6, 0x69d0b5af, 0x075ad3a5, 0xa2e6f239, 0xc234fbad, 0x1bb7c840, 0x33a9d4e8, 0x85cb8ad7, 0x42e977bb, 0x8e802cc9, 0xf33546a3, 0xec1821b8, 0x5da2f4d9, 0x6fa484e7, 0x0e2502ca, 0x8798548f, 0x8fb7adfa, 0xfb656311, 0xf000f6e6, 0xdb5ee3bc, 0x82a35dd6, 0xb24655bf, 0x89fc5646, 0x0dd46bcd, 0x3a52eefe, 0x98a1877e, 0xb3f9b3c1};
  alignas(128) uint32_t R_N3[32]     = {0xb2677d1f, 0x72bf92a1, 0x765dc3b7, 0x4d53a447, 0x5787758e, 0xf634fb6e, 0x9685c383, 0xbd5b9b68, 0x53dc9b39, 0x1671a7a7, 0xd2a4db77, 0x3c036de4, 0xea5d64d4, 0x0bd745dd, 0x9c15658a, 0x27b5e019, 0xd5bb8388, 0x526be3ac, 0x4bca0ce1, 0xc4979c48, 0xd1d49478, 0xebae3608, 0xa29bcd8b, 0x59bbe537, 0xf775c584, 0xfd3a94b5, 0x92a81036, 0xbceb6dbf, 0x7519bfde, 0xc46c737c, 0xa0e008fd, 0x38575727};
  alignas(128) uint32_t R2_N3[32]    = {0x13afe808, 0xf46882f4, 0x47867265, 0x62fc7609, 0xfa61f516, 0x4ca9ba81, 0x6a6d1cd0, 0xf4e15de7, 0xcb7d6b89, 0xd6e14a9f, 0x586caaa4, 0xfa3c56d1, 0xd431c8d3, 0xd9117c7a, 0x7b06f0e8, 0xfd6d9acc, 0xcdbe6f0c, 0x64a81b28, 0x89dfbf88, 0x857ba058, 0xc1eb4d8e, 0x871e48d8, 0x68ef82da, 0xf684c172, 0x53243184, 0xb1116f3f, 0x6abdce64, 0xccfa5f17, 0xb61bf3ff, 0x398c5658, 0x1b1d8aff, 0x3c6b2113};

  alignas(128) uint32_t N4[32]       = {0x27066497, 0xc67fd8a5, 0xdaeb190b, 0x6a4a9a18, 0x157dc8f7, 0x47ff41a5, 0x8a7b06fb, 0xb33e1390, 0x20c0520a, 0xa4a64994, 0x4fd8999c, 0x97258efa, 0x6e9c0346, 0x371be512, 0xc195e73b, 0x2cb0b2af, 0x58987a8d, 0x943f14e8, 0x5c9915e5, 0x999d183b, 0xf576c24d, 0x0a93325d, 0xcfbc183c, 0xdc1f2b29, 0x85765dce, 0x7c590c39, 0x226dec62, 0xb4959fff, 0xe6cb3f85, 0xfe13f036, 0x6499e2ef, 0x8ab0413e};
  alignas(128) uint32_t e4[32]       = {0x0000d7fb};
  uint32_t e4_len       = 16;
  alignas(128) uint32_t d4[32]       = {0xa987261b, 0x17a2f57c, 0x7df4a42b, 0xb4be4f48, 0xc0dc18fd, 0x4e11e692, 0x655ad04a, 0x8f0f9d51, 0x65368f29, 0x0d365209, 0x82d3b33b, 0xe36cd139, 0x473e7d25, 0x0eb587b2, 0x8cc1e155, 0x9bd4e111, 0x0ed6839c, 0x3151f3bb, 0xd323f162, 0xbd4b1a07, 0x646e3a76, 0xf4db2f83, 0x634b93d2, 0xe11e69bb, 0xe885f184, 0x21e67852, 0xf0271e73, 0x20f837cf, 0x36fece05, 0x0b936aa6, 0xe2ec9626, 0x0349d696};           
  alignas(128) uint32_t d4_len       =  1018;
  alignas(128) uint32_t M4[32]       = {0x566c5152, 0xf48ed093, 0x5f264e46, 0x40f71dda, 0xe91ed223, 0xd36b0e1e, 0x45368466, 0xb817c964, 0x41f12358, 0xf76dc9f8, 0x95e30e20, 0xe3a3752a, 0xf0c056f9, 0x26644206, 0xae6613a3, 0xf76624b3, 0x0ef6a770, 0x99f4eea3, 0xa47dcc3e, 0x5e8513d1, 0x1a60fc75, 0x626bfd46, 0x5548ab2c, 0x04d656bf, 0xd45c1da5, 0x1e6a0c5e, 0x171810a7, 0x007d1e76, 0x9b4c4c34, 0xfa4167dd, 0x899f58dc, 0x807da975};
  alignas(128) uint32_t R_N4[32]     = {0xd8f99b69, 0x3980275a, 0x2514e6f4, 0x95b565e7, 0xea823708, 0xb800be5a, 0x7584f904, 0x4cc1ec6f, 0xdf3fadf5, 0x5b59b66b, 0xb0276663, 0x68da7105, 0x9163fcb9, 0xc8e41aed, 0x3e6a18c4, 0xd34f4d50, 0xa7678572, 0x6bc0eb17, 0xa366ea1a, 0x6662e7c4, 0x0a893db2, 0xf56ccda2, 0x3043e7c3, 0x23e0d4d6, 0x7a89a231, 0x83a6f3c6, 0xdd92139d, 0x4b6a6000, 0x1934c07a, 0x01ec0fc9, 0x9b661d10, 0x754fbec1};
  alignas(128) uint32_t R2_N4[32]    = {0xe0130b76, 0x629ea0ba, 0x6c69f936, 0xc1051b85, 0x7ebd6505, 0xc54938c8, 0x25f4c061, 0xdf2e955a, 0xfec6315a, 0x476765a1, 0xc4869f8e, 0xde73285a, 0x55435818, 0x88bc6da7, 0xd342cd5b, 0xd6dacb6d, 0xeb40900a, 0xf5dfadb3, 0x8e26e10f, 0x6b928d10, 0xfee78ba0, 0xbd83d428, 0x0bad3723, 0x1e2a3092, 0xacdf015c, 0x4a4a3c43, 0xdebcd5f1, 0x4ed18520, 0x80e0e412, 0x81ee9548, 0x4aafe59b, 0x894f57e8};

  alignas(128) uint32_t N5[32]       = {0x82fdb85f, 0xecd2dd02, 0xd4cdb6f6, 0x2e480264, 0x7e377731, 0xbf111203, 0xbcb53bf1, 0x369e6a30, 0xb2df937c, 0x34b7417f, 0x9748e1c3, 0x52704147, 0xe831fd08, 0xf442abaf, 0xd96f9753, 0x67f098e2, 0xedd6a65a, 0x464823da, 0xc0e56621, 0xfdc4136f, 0x6b3ccd2e, 0x67c4ba7b, 0x79be1636, 0x548b0320, 0x0bd3f1eb, 0x59f134b1, 0x4fd15206, 0x15e45e0a, 0x8af1fc55, 0x25c5fea3, 0x6c47f27b, 0x832d10e9};
  alignas(128) uint32_t e5[32]       = {0x00008e1f};
  uint32_t e5_len       = 16;
  alignas(128) uint32_t d5[32]        = {0x188dfddf, 0x032c3fac, 0x5accddb7, 0x73990c6a, 0x02bc3f7d, 0x3d6c80cd, 0xbf6535c5, 0xbdf2d5b6, 0x9efb1538, 0x5e0c0ab1, 0xa2643142, 0x663202cd, 0x961302a5, 0x3eba4ad9, 0xb7e35f47, 0x247c9964, 0xac9e9869, 0x0fb895ac, 0xedd84778, 0x269b1036, 0x1c5d59dc, 0xd3687f90, 0xefc10e96, 0xf1fa1fbe, 0xdba271cf, 0x7c0c66ab, 0x64bb05b0, 0xb2978989, 0x00638bfd, 0xc525f5a3, 0x729184c5, 0x5b6ef8a4};           
  alignas(128) uint32_t d5_len        =  1023;
  alignas(128) uint32_t M5[32]       = {0x68412c4e, 0x178b2581, 0x424a7145, 0x9e5b6b76, 0x6e9380cf, 0x8a85b200, 0x1cc93bc5, 0xb68eebc8, 0x2d12be1e, 0x423fa6b2, 0x3391d5fd, 0x44d53e7b, 0x52ed09a0, 0x1a971e36, 0x00ad8780, 0xc0e1885e, 0x25579f55, 0x6c808239, 0xd34d3995, 0x09db071d, 0x3f68304f, 0x9a6a0d57, 0xff724eea, 0x39c7cf54, 0xeec7d7d1, 0x52ea9b5a, 0x3dd72f14, 0xd95f245f, 0x6cf9cd47, 0xbc076f42, 0x6cf9bfe6, 0x800bfe4e};
  alignas(128) uint32_t R_N5[32]     = {0x7d0247a1, 0x132d22fd, 0x2b324909, 0xd1b7fd9b, 0x81c888ce, 0x40eeedfc, 0x434ac40e, 0xc96195cf, 0x4d206c83, 0xcb48be80, 0x68b71e3c, 0xad8fbeb8, 0x17ce02f7, 0x0bbd5450, 0x269068ac, 0x980f671d, 0x122959a5, 0xb9b7dc25, 0x3f1a99de, 0x023bec90, 0x94c332d1, 0x983b4584, 0x8641e9c9, 0xab74fcdf, 0xf42c0e14, 0xa60ecb4e, 0xb02eadf9, 0xea1ba1f5, 0x750e03aa, 0xda3a015c, 0x93b80d84, 0x7cd2ef16};
  alignas(128) uint32_t R2_N5[32]    = {0x2c4f65df, 0x28c8c14d, 0x01a8e745, 0x9e0c7665, 0x91617c61, 0x1d19f784, 0x15eefa14, 0xdd22583f, 0xb78521ff, 0x749f2485, 0xe3e413f1, 0x82ff0964, 0x7ff0ead6, 0x68cc150c, 0x6ecf5a74, 0x0a883f52, 0x6ec40532, 0x5c4df038, 0x60c66e25, 0xeb9fcc20, 0x058b78cb, 0x777dabd1, 0xcd2c3b6a, 0x22ec7036, 0xf40f7e7a, 0xa1ad03b1, 0x142c6779, 0xa591893a, 0xa41beede, 0x17b347d0, 0x4ff11990, 0x2d9873fd};

  // result with seed 2024.X
  alignas(128) uint32_t res1[32] = { 0x0d411286, 0x18becc55, 0x9abf7e79, 0x509ba59e, 0x9dd82520, 0xb7c04b1c, 0x1dbe0f32, 0xb4d112ab, 0x4b3bc30f, 0xf78ade71, 0xe1f7c27c, 0x6e698f25, 0x336164a9, 0x433d6f5f, 0xbac30fc4, 0xd8c572a5, 0x687a72db, 0x0eea2db8, 0x3578b901, 0xd1890c27, 0xfd95e53a, 0x53724464, 0xc5f83d02, 0x48bdb43b, 0xec00e92b, 0xfb5ce372, 0xc72caed5, 0xd546126a, 0xdea74a05, 0xdcd04cc8, 0xecfe2357, 0x0fad8c31  };
  alignas(128) uint32_t res2[32] = { 0xeb40f7ca, 0x32765ecf, 0x225aa155, 0x78c4279d, 0x68c43502, 0x903a708f, 0xba244f89, 0x2e6be34a, 0x7ff5c8f2, 0x676c7443, 0xfdd4e10c, 0x5ac77158, 0x3e2d8d20, 0x40dd4ed2, 0xce483014, 0xddcb1326, 0xb030e9ff, 0xae117e37, 0xcc9381a4, 0xf51e0c1c, 0x7471aae1, 0xe8f129fa, 0xcebd118c, 0x775cd2b9, 0xca6f4ebf, 0x6d6939a2, 0x2173b059, 0xcff21ab0, 0x81906a86, 0xdd8840d6, 0xd91a5c72, 0x6832be86  };
  alignas(128) uint32_t res3[32] = { 0xdac6ab99, 0x98a0a290, 0xfcb4100a, 0xd77e232c, 0x6257276e, 0xdc571cc8, 0x29da2ced, 0xe22ff55a, 0xe88342e4, 0x7fea7811, 0x860a3fbb, 0x28db4074, 0x491841ae, 0x880e9274, 0xa22bad80, 0x289b950a, 0x07db49aa, 0x954d9e22, 0x456e6c98, 0x9193ddf7, 0x78632551, 0xa1ff4070, 0xd504a1be, 0x30453103, 0x49760f60, 0x17e3bd95, 0xe4482600, 0x474ff41e, 0x6d860af0, 0x24772ca6, 0x8b3c03e2, 0x39db1f0e  };
  alignas(128) uint32_t res4[32] = { 0x456003ed, 0xba02b50f, 0x6c9bcbb6, 0xd9e60769, 0xa13c4092, 0x93687e0b, 0x738c4680, 0xf3129083, 0x19a1b099, 0x23a840b2, 0x852494df, 0x311a9e79, 0xad7efc3a, 0xf86ae07d, 0xa4212e8a, 0x680b9a7f, 0xdc165a46, 0x4f84eb99, 0x2ccfda2e, 0x89a62148, 0xbb3a3e6b, 0xa58d0b61, 0xe4920ed3, 0x38de9de9, 0xad779a43, 0x12f60128, 0xe54fedb0, 0x87a9e617, 0x97825525, 0xfb09f3c4, 0x1655ade5, 0x5adb7182  };
  alignas(128) uint32_t res5[32] = { 0xfc528a4a, 0x36f2b77d, 0xfee809e3, 0xf5ad1354, 0xf5edba8f, 0xe11b46ea, 0x64dc8043, 0x5fbe086b, 0xeabd5d67, 0x9b2bd5ef, 0x8909dd32, 0xff241031, 0x8d0fc943, 0x6d30a595, 0x5b5fc008, 0xf016e77e, 0x433e9f16, 0xdf1c2fb6, 0xf205a8ed, 0xaadb1fe0, 0xac1d090f, 0xa2dddb6b, 0xc7c81529, 0xdf1bf2b7, 0x365287ef, 0xefb35ca3, 0x2fd53e35, 0x528af1cd, 0x1e5e35b5, 0x1c9416b9, 0xa9a23ba9, 0x3a266894  };

  // Put all of this nicely in a list so we can loop easily
  uint32_t* N_list[5]     = {N1, N2, N3, N4, N5};
  uint32_t* e_list[5]     = {e1, e2, e3, e4, e5};
  uint32_t* e_len_list[5] = {e1_len, e2_len, e3_len, e4_len, e5_len};
  uint32_t* d_list[5]     = {d1, d2, d3, d4, d5};
  uint32_t* d_len_list[5] = {d1_len, d2_len, d3_len, d4_len, d5_len};
  uint32_t* M_list[5]     = {M1, M2, M3, M4, M5};
  uint32_t* R_N_list[5]   = {R_N1, R_N2, R_N3, R_N4, R_N5};
  uint32_t* R2_N_list[5]  = {R2_N1, R2_N2, R2_N3, R2_N4, R2_N5};
  uint32_t* res_list[5]   = {res1, res2, res3, res4, res5};

  HWreg[TXADDR] = (uint32_t)&odata; // store address odata in reg2

  // running multiple test
  uint32_t* N; uint32_t* e; uint32_t* d; uint32_t* M;
  uint32_t* R_N; uint32_t* R2_N; uint32_t* res;
  uint32_t e_len; uint32_t d_len;
  for(int j = 0; j < 1; j++){
    // Data loading
    N     = N_list[j];
    e     = e_list[j];
    e_len = e_len_list[j];
    d     = d_list[j];
    d_len = d_len_list[j];
    M     = M_list[j];
    R_N   = R_N_list[j];
    R2_N  = R2_N_list[j];
    res   = res_list[j];


    // Proposed CSR for command : use 8 bits : 0bxxxx x used xxx used for number fed
    uint32_t* adress_list[3] = {N,e,R2_N};
    START_TIMING
    for(int i = 1; i <= 3; i+=2){ // skipping the R_N write cause no more need !!!!
        HWreg[RXADDR] = (uint32_t) adress_list[i-1]; // store address idata in reg1
        HWreg[LOADING] = (uint32_t) 8 + i; // 0b1000 + i indicating the state and which datas are being loaded.

        if(DBG){
        	printf("____\n");
			printf("Status %08X\r\n", (unsigned int)HWreg[STATUS]);
			printf("LSB_N %08X\r\n", (unsigned int)HWreg[LSB_N]);
			printf("LSB_R_N %08X\r\n", (unsigned int)HWreg[LSB_R_N]);
			printf("LSB_R2_N %08X\r\n", (unsigned int)HWreg[LSB_R2_N]);
			printf("DMA 4 %08X\r\n", (unsigned int)HWreg[DMA_RX]);
			printf("Loading %08X\r\n", (unsigned int)HWreg[LOADING]);
			printf("State %08X\r\n", (unsigned int)HWreg[STATE]);
        }

        // wait for the FPGA to be done
        while((HWreg[STATUS] & 0x01) == 0);
        HWreg[LOADING] = (uint32_t) 0; // to reset for the next state
    }

    
    // saves the length of exponent
    HWreg[T]     = e[0];
    HWreg[T_LEN] = 16;
    
    if SEND_MY_MESSAGE{
      char* my_message = "Hello World ! This is a test text for the RSA algorithm. This text is longer than 128 characters to check the splitting of message. Does it work ?";
      uint32_t size = (uint32_t) strlen(my_message);
      uint32_t amount_of_frame = (uint32_t) ceil((float) size/128);
      alignas(128) uint32_t* m[32] = {0};


      for(uint32_t blocks = 0; blocks < amount_of_frame; blocks++){
        encode_message(m, my_message,size,blocks);

        // the message stays inside the DMA
        HWreg[RXADDR]  = (uint32_t) m;

        // Running the montgomery Exponentiation

        HWreg[COMMAND] = 0x01;
        // Wait until FPGA is done
        while((HWreg[STATUS] & 0x01) == 0);
        STOP_TIMING

        HWreg[COMMAND] = 0x00;

        printf("\r\nO_Data:\r\n"); 
        print_array_contents(odata);
        printf("_______\n");
      }


    }
    else{
      // the message stays inside the DMA
      // THIS VERSION WILL JUST RUN THE MONTGOMERY MULTIPLICATION IN HARDWARE AND THE REST IN SOFTWARE
      /*
      CHANGE TO THE API
      COMMAND :
        0b0001 : 0x01 : MontMul(DMA, X_tilde, N)
        0b0011 : 0x03 : MontMul(DMA, DMA, N)
        0b0101 : 0x05 : MontMul(DMA, 1, N)
        Write to registers commands
        0b1001 : 0x09 : MontMul(DMA, R2N, N)
        0b1011 : 0x0B : MontMul(X_tilde, X_tilde, N)
        0b1101 : 0x0D : MontMUl(DMA, X_tilde, N)
     */

      // Running the montgomery Exponentiation
      HWreg[RXADDR]  = (uint32_t) M;
      // Launch Montgomery Multiplication
      HWreg[COMMAND] = 0x09;
      while((HWreg[STATUS] & 0x01) == 0);
      HWreg[COMMAND] = 0x00;

      alignas(128) uint32_t A[32] = {0};
      // Won't use memcpy just to avoid library dependencies 
      for(int count = 0; count < 32; count++){
        A[i] = R_N[count];
      }
      HWreg[RXADDR]  = (uint32_t) A;
      HWreg[TXADDR]  = (uint32_t) A;

      for(int i = 0; i < e1_len; i++){
        if((E[i/32] >> e-(i%32)-1) & 0x1){
          // do for R_N
          // Launch Montgomery Multiplication
          HWreg[COMMAND] = 0x01;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;

          // do for X_tilde 
          // Launch Montgomery Multiplication
          HWreg[COMMAND] = 0x0B;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;
        }else{
          // do for X_tilde 
          // Launch Montgomery Multiplication
          HWreg[COMMAND] = 0x0D;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;

          // do for R_N
          // Launch Montgomery Multiplication
          HWreg[COMMAND] = 0x03;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;
        }

        // do the final operation 
        // Launch Montgomery Multiplication
        HWreg[COMMAND] = 0x05;
        while((HWreg[STATUS] & 0x01) == 0);
        HWreg[COMMAND] = 0x00;

        odata = A;
      }

      STOP_TIMING
      printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));
      printf("LSB_N 1 %08X\r\n", (unsigned int)HWreg[1]);
      printf("LSB_R_N 2 %08X\r\n", (unsigned int)HWreg[2]);
      printf("LSB_R2_N 3 %08X\r\n", (unsigned int)HWreg[3]);
      printf("DMA 4 %08X\r\n", (unsigned int)HWreg[4]);
      printf("Loading 5 %08X\r\n", (unsigned int)HWreg[5]);
      printf("State 6 %08X\r\n", (unsigned int)HWreg[6]);
      printf("Load 7 %08X\r\n", (unsigned int)HWreg[7]);
      

      // print the result against the output datas
      printf("\r\nI_Data:\r\n"); print_array_contents(res);
      printf("\r\nO_Data:\r\n"); print_array_contents(odata);
    }
  }

  cleanup_platform();

  return 0;
}
