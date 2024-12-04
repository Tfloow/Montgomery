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
#define min(a, b) (((a) < (b)) ? (a) : (b))

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    xil_printf("%08x %08x %08x %08x\n\r",
      src[i+3], src[i+2], src[i+1], src[i]);
}

uint32_t bit(uint32_t* E, uint32_t position){
  uint32_t right_part = E[position/32];

  return (right_part >> (position % 32)) & 0x1;
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
  for(uint32_t j = 0; j < min(128, size - blocks*128); j++){
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

  HWreg[TXADDR] = (uint32_t) odata; // store address odata in reg2
  alignas(128) uint32_t res[32] = { 0x0d411286, 0x18becc55, 0x9abf7e79, 0x509ba59e, 0x9dd82520, 0xb7c04b1c, 0x1dbe0f32, 0xb4d112ab, 0x4b3bc30f, 0xf78ade71, 0xe1f7c27c, 0x6e698f25, 0x336164a9, 0x433d6f5f, 0xbac30fc4, 0xd8c572a5, 0x687a72db, 0x0eea2db8, 0x3578b901, 0xd1890c27, 0xfd95e53a, 0x53724464, 0xc5f83d02, 0x48bdb43b, 0xec00e92b, 0xfb5ce372, 0xc72caed5, 0xd546126a, 0xdea74a05, 0xdcd04cc8, 0xecfe2357, 0x0fad8c31  };


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
    // HWreg[T]     = e[0];
    HWreg[T_LEN] = e_len;

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
		printf("A : %08X\n",HWreg[1]);
		printf("B : %08X\n",HWreg[2]);
		printf("M : %08X\n",HWreg[3]);
      while((HWreg[STATUS] & 0x01) == 0);
      printf("A : %08X\n",HWreg[1]);
      HWreg[COMMAND] = 0x00;
      printf("A : %08X\n",HWreg[1]);


      alignas(128) uint32_t A[32] = {0};
      // Won't use memcpy just to avoid library dependencies
      for(int count = 0; count < 32; count++){
        A[count] = R_N[count];
      }
      HWreg[RXADDR]  = (uint32_t) A;
      HWreg[TXADDR]  = (uint32_t) odata;

      for(int i = 0; i < 2; i++){
    	printf("[LOG] bits value step by step : %ld \n", bit(e, e_len - i - 1));
        if(bit(e, e_len - i - 1)){ // check the exponent to run the Power ladder algorithm
          // do for R_N
          // Launch Montgomery Multiplication
        	printf("A : %08X\n",HWreg[1]);
        	printf("B : %08X\n",HWreg[2]);
        	printf("M : %08X\n",HWreg[3]);


          HWreg[COMMAND] = 0x01;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;

          printf("RES : %08X\n",HWreg[4]);
			printf("A : %08X\n",HWreg[1]);
			printf("B : %08X\n",HWreg[2]);
			printf("M : %08X\n",HWreg[3]);

          // do for X_tilde
          // Launch Montgomery Multiplication
          HWreg[COMMAND] = 0x0B;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;

          printf("RES : %08X\n",HWreg[4]);

        }else{
          // do for X_tilde
          // Launch Montgomery Multiplication
        	printf("A : %08X\n",HWreg[1]);
        	printf("B : %08X\n",HWreg[2]);
        	printf("M : %08X\n",HWreg[3]);
          HWreg[COMMAND] = 0x0D;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;

          printf("RES : %08X\n",HWreg[4]);
			printf("A : %08X\n",HWreg[1]);
			printf("B : %08X\n",HWreg[2]);
			printf("M : %08X\n",HWreg[3]);

          // do for R_N
          // Launch Montgomery Multiplication
          HWreg[COMMAND] = 0x03;
          while((HWreg[STATUS] & 0x01) == 0);
          HWreg[COMMAND] = 0x00;

          printf("RES : %08X\n",HWreg[4]);

        }

        // do the final operation
        // Launch Montgomery Multiplication
        HWreg[COMMAND] = 0x05;
        while((HWreg[STATUS] & 0x01) == 0);
        HWreg[COMMAND] = 0x00;

        //odata = A;
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
      printf("\r\nO_Data:\r\n"); print_array_contents(A);


  printf("done\n");
  cleanup_platform();

  return 0;
}
