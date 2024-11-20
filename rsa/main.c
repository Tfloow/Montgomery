#include "common.h"
#include <stdalign.h>
  
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

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    xil_printf("%08x %08x %08x %08x\n\r",
      src[i+3], src[i+2], src[i+1], src[i]);
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
  #define T_LEN   3
  #define LOADING 4
  #define STATUS  0

  // Aligned input and output memory shared with FPGA
  alignas(128) uint32_t idata[32];
  alignas(128) uint32_t odata[32];

  // Initialize odata to all zero's
  memset(odata,0,128);
  memset(idata,0,128);

  printf("RXADDR %08X\r\n", (unsigned int)HWreg[RXADDR]);
  printf("TXADDR %08X\r\n", (unsigned int)HWreg[TXADDR]);

  printf("STATUS %08b\r\n", (unsigned int)HWreg[STATUS]);
  printf("REG[3] %08b\r\n", (unsigned int)HWreg[3]);
  printf("REG[4] %08X\r\n", (unsigned int)HWreg[4]);

  // Thomas writing
  // For the exponentiation we need to provide M, e, N, R mod N, R^2 mod N
  // R is just 2^1024
  // So we need to send 5 1024 bits data

  // This data comes from the testvectors.py
  alignas(128) uint32_t N[32]       = {0xe7a1244f, 0x2cfb89d2, 0xbec81f37, 0x1b86b29a, 0xd2596280, 0x470fe700, 0xd6ae288a, 0x183f231b, 0x8c551b65, 0xc57a9283, 0xb68c8bee, 0xdeb55370, 0x2037e78c, 0x3e2c1580, 0x7ebc97bf, 0xccacb6b6, 0xb987ff4d, 0x1ee12f81, 0x91f023af, 0x8d877663, 0xe3279dd3, 0xe98d926c, 0x6e517fa8, 0x8ab8758f, 0xc34e6dc9, 0xa34fbdb3, 0xa97eec85, 0xd0ab90e2, 0x6d03d620, 0x0f2b6b47, 0x0c6eedce, 0xc40ebbeb};
  alignas(128) uint32_t e[32]       = {0x0000f8b7};
  alignas(128) uint32_t e_len       = 16;
  alignas(128) uint32_t M[32]       = {0x6e61551a, 0xac81f152, 0x057e0e67, 0x44c293ef, 0x15ed3da7, 0xea6ff9c1, 0xa77ab672, 0xbf6808b9, 0x481d2911, 0x199de4d6, 0x4e569f73, 0xc12f5a7a, 0x149c97f3, 0x0a59f5a4, 0x103039ad, 0xba6701e5, 0xe05f38ea, 0x7ff7493e, 0x19201504, 0x946efcdc, 0x5abb2696, 0x6bceac9d, 0xfa10777b, 0xb9d40dd8, 0xc406c71b, 0x2f3130ac, 0x75748f68, 0x7905db9c, 0x102241ba, 0xafd583a9, 0x847562a9, 0xbf88e7d4};
  alignas(128) uint32_t R_N[32]     = {0x185edbb1, 0xd304762d, 0x4137e0c8, 0xe4794d65, 0x2da69d7f, 0xb8f018ff, 0x2951d775, 0xe7c0dce4, 0x73aae49a, 0x3a856d7c, 0x49737411, 0x214aac8f, 0xdfc81873, 0xc1d3ea7f, 0x81436840, 0x33534949, 0x467800b2, 0xe11ed07e, 0x6e0fdc50, 0x7278899c, 0x1cd8622c, 0x16726d93, 0x91ae8057, 0x75478a70, 0x3cb19236, 0x5cb0424c, 0x5681137a, 0x2f546f1d, 0x92fc29df, 0xf0d494b8, 0xf3911231, 0x3bf14414};
  alignas(128) uint32_t R2_N[32]    = {0x5c674e3c, 0x0d9fe510, 0x272df813, 0x147f2411, 0xb9abfce2, 0xfd1b4944, 0x3d676419, 0x3e8c24f5, 0x5dfd55bc, 0xb14bafd3, 0x1d63fc25, 0x11b5a998, 0xc5394728, 0xbc5bc2fc, 0x641e505f, 0x66b632be, 0xb1b12234, 0xc28b63ab, 0x67dc04f1, 0x9a514e34, 0x6d31ec6d, 0x89b43c43, 0x6cb0e049, 0x8ee60bb3, 0x14884e1f, 0xf1068633, 0xabce305e, 0xae082d46, 0x01d4cf46, 0xf12fb0bf, 0xe12c34ec, 0x0abad4ec};

  HWreg[TXADDR] = (uint32_t)&odata; // store address odata in reg2

  // Data loading
  // Proposed CSR for command : use 8 bits : 0bxxxx x used xxx used for number fed
  uint32_t adress_list[4] = {(uint32_t) &e, (uint32_t) &N, (uint32_t) &R_N, (uint32_t) &R2_N};
  for(uint8_t i = 1; i <= 4; i++){
	  HWreg[RXADDR] = adress_list[i-1]; // store address idata in reg1
	  HWreg[LOADING] = 8 + i; // 0b1000 + i indicating the state and which datas are being loaded.

	  // wait for the FPGA to be done
	  // while((HWreg[STATUS] & 0x01) == 0);
  }
  // the message stays inside the DMA
  HWreg[LOADING] = 0;
  HWreg[RXADDR]  =  (uint32_t) &M;

  // saves the length of t
  HWreg[T_LEN] = e_len;

  // Running the montgomery Exponentiation
START_TIMING
  HWreg[COMMAND] = 0x01;
  // Wait until FPGA is done
  while((HWreg[STATUS] & 0x01) == 0);
STOP_TIMING
  
  HWreg[COMMAND] = 0x00;

  printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));
  printf("STATUS 1 %08X\r\n", (unsigned int)HWreg[1]);
  printf("STATUS 2 %08X\r\n", (unsigned int)HWreg[2]);
  printf("STATUS 3 %08X\r\n", (unsigned int)HWreg[3]);
  printf("STATUS 4 %08X\r\n", (unsigned int)HWreg[4]);
  printf("STATUS 5 %08X\r\n", (unsigned int)HWreg[5]);
  printf("STATUS 6 %08X\r\n", (unsigned int)HWreg[6]);
  printf("STATUS 7 %08X\r\n", (unsigned int)HWreg[7]);

  // writes in idata the expected result
  alignas(128) uint32_t res[32] = {  0xf24b896e, 0xc8cdb8e8, 0xd1cb1bf1, 0xa64b1802, 0xc37a7d7a, 0xf61b6aab, 0x8f8ef8c3, 0xf3560bc9, 0x8a24f7b2, 0xff755418, 0x3292e354, 0x3be0fa3f, 0x9183e65e, 0x201a88a0, 0x5dd1d697, 0x0ca51b75, 0x4c42fe12, 0x3c92aecb, 0xe24f0b77, 0xa647bc2f, 0x428f7ba7, 0x38251af4, 0x3818dd9c, 0x31c36244, 0xfb785abc, 0x1ec46cfa, 0xdd35b8cd, 0x0c0e92f2, 0xd3c6174a, 0x08f430fd, 0xcb1bfd03, 0x81c59474  };
  for(int i = 0; i < 32; i++){
	  idata[i] = res[i];
  }

  printf("\r\nI_Data:\r\n"); print_array_contents(idata);
  printf("\r\nO_Data:\r\n"); print_array_contents(odata);


  cleanup_platform();

  return 0;
}
