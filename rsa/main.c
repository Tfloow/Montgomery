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

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    xil_printf("%08x %08x %08x %08x\n\r",
                src[i+3], src[i+2], src[i+1], src[i]);
}

void compare_array_contents(uint32_t* res, uint32_t* obtained) {
  int i;
  for (i=31; i>=0; i--){
	  if(res[i] != obtained[i]){
		  printf("ARRAYS NOT EQUAL !\n");
		  return;
	  }
	}
  printf("Arrays are equal!\n");
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

void print_encoded_message(uint32_t* m){
  /*
  m               : the 128 bytes aligned buffer after using encode_message
  */
  int i;
  for (i=32-1; i>=0; i--){
	for(int j = 3; j >=0; j--){
		if((char)(m[i] >> j*8) == 00){
			printf("\n");
			return;
		}
		printf("%c",(char) (m[i] >> j*8));
	}
  }
  printf("\n");
}

void encrypt(volatile uint32_t* HWreg, uint32_t* A, uint32_t* M, uint32_t* R_N, uint32_t* e, uint32_t e_len ){

  // HERE IS THE START OF THE ALGORITHM
  // Running the montgomery Exponentiation
  HWreg[RXADDR]  = (uint32_t) M;
  //HWreg[TXADDR]  = (uint32_t) X_tilde;
  // Launch Montgomery Multiplication
  HWreg[COMMAND] = 0x01;
  while((HWreg[STATUS] & 0x01) == 0);
  HWreg[COMMAND] = 0x00;

  // Won't use memcpy just to avoid library dependencies
  for(int count = 0; count < 32; count++){
    A[count] = R_N[count];
  }

  for(int i = 0; i < e_len; i++){
    if(bit(e, e_len - i - 1)){ // check the exponent to run the Power ladder algorithm
      // do for R_N
      // Launch Montgomery Multiplication
      HWreg[RXADDR]  = (uint32_t) A;
      HWreg[TXADDR]  = (uint32_t) A;
      HWreg[COMMAND] = 0x03;
      while((HWreg[STATUS] & 0x01) == 0);
      HWreg[COMMAND] = 0x00;
    }else{
      // do for X_tilde
      // Launch Montgomery Multiplication
      HWreg[RXADDR]  = (uint32_t) A;
      HWreg[TXADDR]  = (uint32_t) A;
      HWreg[COMMAND] = 0x05;
      while((HWreg[STATUS] & 0x01) == 0);
      HWreg[COMMAND] = 0x00;
    }
  }

  // do the final operation
  // Launch Montgomery Multiplication
  HWreg[RXADDR]  = (uint32_t) A;
  HWreg[TXADDR]  = (uint32_t) A;

  HWreg[COMMAND] = 0x07;
  while((HWreg[STATUS] & 0x01) == 0);
  HWreg[COMMAND] = 0x00;
}

void load_data(volatile uint32_t* HWreg, uint32_t* N, uint32_t* R2_N ){
  HWreg[RXADDR] = (uint32_t) N;
  HWreg[LOADING] = (uint32_t) 8 + 1; // 0b1000 + i indicating the state and which datas are being loaded.
  while((HWreg[STATUS] & 0x01) == 0);   // wait for the FPGA to be done
  HWreg[LOADING] = (uint32_t) 0; // to reset for the next state

  HWreg[RXADDR] = (uint32_t) R2_N;
  HWreg[LOADING] = (uint32_t) 8 + 3; // 0b1000 + i indicating the state and which datas are being loaded.
  while((HWreg[STATUS] & 0x01) == 0);   // wait for the FPGA to be done
  HWreg[LOADING] = (uint32_t) 0; // to reset for the next state
}

void rsa_encryption(volatile uint32_t* HWreg, uint32_t* M, uint32_t* N, uint32_t* R_N, uint32_t* R2_N, uint32_t* e, uint32_t e_len){
  // M is the message and will hold the encrypted message
  load_data(HWreg, N, R2_N);
  encrypt(HWreg, M, M, R_N,e,e_len);
}

void rsa_decryption(volatile uint32_t* HWreg, uint32_t* A, uint32_t* N, uint32_t* R_N, uint32_t* R2_N, uint32_t* d, uint32_t d_len){
  // A is the Ct and will hold the message after decryption
  load_data(HWreg, N, R2_N);
  encrypt(HWreg, A, A, R_N,d,d_len);
}

void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint32_t c = 0;
    uint32_t i = 0;

    uint32_t tmp = 0;

    for(; i < size; i++){
        tmp = (a[i] - c);
        res[i] = tmp - b[i];
        if (tmp >= b[i]){
            c = 0;
        }else{
            c = 1;
        }
    }
}
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint32_t c = 0;
    uint32_t i = 0;

    for(; i < size; i++){
        res[i] = (a[i] + b[i] + c);
        // c already take care of this possible so it is annoying
        // i will split

        c = ((((uint16_t) (a[i] >> 16)) + ((uint16_t) (b[i] >> 16))) + ((((uint16_t) a[i] + (uint16_t) b[i] + c) >> 16)>>16));
    }
    res[i] = c;
}

// Do A+B % N
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
    // add like before
    mp_add(a,b,res,size);

    // to the mod we simply need to substract once easy !
    if(res[size] >= N[size]){
        mp_sub(res,N,res,size);
    }

    // simple clean of the size+1 32 bits part since it may contain a garbage 1
    res[size] = 0;
}

// Those functions were assisted using AI, will need a bit more of fine tuning
int mp_cmp(uint32_t *a, uint32_t *b, uint32_t size) {
    // Compare from the most significant limb
    for (int i = size - 1; i >= 0; i--) {
        if (a[i] > b[i]) return 1;
        if (a[i] < b[i]) return -1;
    }
    return 0;
}

void mod_mult(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size) {
  // Initialize result to zero
  uint32_t zero[size + 1];
  for(int i = 0; i < size +1; i++){
    zero[i] = 0;
    res[i]  = 0;
  }
  uint32_t temp[size + 1];

  for (int i = 0; i < size * 32; i++) {
    // Determine the current bit of b
    int bit_index = i / 32;
    int bit_offset = i % 32;
    uint32_t current_bit = (b[bit_index] >> bit_offset) & 1;

    if (current_bit) {
      // If bit is 1, add a to the result
      mod_add(res, a, N, temp, size);
      for(int i = 0; i < size +1; i++){
        res[i] = temp[i];
      }
    }

    // Double a (left shift by 1)
    uint32_t carry[size + 1];
    for(int i = 0; i < size +1; i++){
      carry[i] = 0;
    }

    // Left shift a
    carry[0] = a[size - 1] >> 31;
    for (int j = size - 1; j > 0; j--) {
      a[j] = (a[j] << 1) | (a[j-1] >> 31);
    }
    a[0] <<= 1;

    // Modular reduction of a
    if (mp_cmp(a, N, size) >= 0) {
      mod_add(a, zero, N, temp, size);
      for(int i = 0; i < size +1; i++){
        a[i] = temp[i];
      }
    }
  }
  res[size] = 0;
}

void mp_mult(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size) {
  // Clear the result array to ensure clean initial state
  for(int i = 0; i < 2*size +1; i++){
    res[i] = 0;
  }

  // Perform multiplication using grade-school algorithm
  for (uint32_t i = 0; i < size; i++) {
    uint64_t carry = 0;
    for (uint32_t j = 0; j < size; j++) {
      uint64_t product = (uint64_t)a[i] * (uint64_t)b[j];
      uint64_t sum = (uint64_t)res[i + j] + product + carry;
      res[i + j] = (uint32_t)sum;
      carry = sum >> 32;
    }
    res[i + size] = carry;
  }
}

void rsa_decryption_CRT(volatile uint32_t* HWreg, uint32_t* A, uint32_t* N, uint32_t* R_N, uint32_t* R2_N, uint32_t* d, uint32_t d_len, uint32_t* RES,
                        uint32_t* dP, uint32_t dP_len,  uint32_t* dQ, uint32_t dQ_len, uint32_t* qinv, uint32_t qinv_len, uint32_t* p, uint32_t*q){
  // R = 2^1024 so R_N and R2_N is the same
  // A holds the encrypted message
  load_data(HWreg, N, R2_N);
  alignas(128) uint32_t M1[32] = {0};
  alignas(128) uint32_t M2[32] = {0};
  // Copy the encrypted message in both
  for(int i = 0; i < 32; i++){
    M1[i] = A[i];
    M2[i] = A[i];
  }
  // Do the M1
  encrypt(HWreg, M1, M1, R_N,dP,dP_len);
  // Do the M2
  encrypt(HWreg, M2, M2, R_N,dQ,dQ_len);
  // Subtraction
  mp_sub(M1,M2,M1,32);
  // Need to do the multiplication and sum mult later
  alignas(128) uint32_t H[32] = {0};
  alignas(128) uint32_t HQ[32] = {0};
  mod_mult(qinv,M1,p,H,32);
  mp_mult(H,q,HQ,32);
  mp_add(M2,HQ,RES,32);
}


uint32_t my_strlen(char* string){
  // I know this is the dumbest idea to do a custom strlen but IDK if we have string.h library
  // Please COSIC be nice and don't do buffer overflow pleaseeeeee
  for(int i = 0; i < 1000; i++){
    if(string[i] == '\0'){
      return i;
    }
  }
  return 10001; // if issue
}

int main() {

  init_platform();
  init_performance_counters(0);

  xil_printf("Begin\n\r");

  // Register file shared with FPGA
  volatile uint32_t* HWreg = (volatile uint32_t*)0x40400000;

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

  // result with seed 2024.X
  alignas(128) uint32_t res1[32] = { 0x0d411286, 0x18becc55, 0x9abf7e79, 0x509ba59e, 0x9dd82520, 0xb7c04b1c, 0x1dbe0f32, 0xb4d112ab, 0x4b3bc30f, 0xf78ade71, 0xe1f7c27c, 0x6e698f25, 0x336164a9, 0x433d6f5f, 0xbac30fc4, 0xd8c572a5, 0x687a72db, 0x0eea2db8, 0x3578b901, 0xd1890c27, 0xfd95e53a, 0x53724464, 0xc5f83d02, 0x48bdb43b, 0xec00e92b, 0xfb5ce372, 0xc72caed5, 0xd546126a, 0xdea74a05, 0xdcd04cc8, 0xecfe2357, 0x0fad8c31  };
  alignas(128) uint32_t res2[32] = { 0xeb40f7ca, 0x32765ecf, 0x225aa155, 0x78c4279d, 0x68c43502, 0x903a708f, 0xba244f89, 0x2e6be34a, 0x7ff5c8f2, 0x676c7443, 0xfdd4e10c, 0x5ac77158, 0x3e2d8d20, 0x40dd4ed2, 0xce483014, 0xddcb1326, 0xb030e9ff, 0xae117e37, 0xcc9381a4, 0xf51e0c1c, 0x7471aae1, 0xe8f129fa, 0xcebd118c, 0x775cd2b9, 0xca6f4ebf, 0x6d6939a2, 0x2173b059, 0xcff21ab0, 0x81906a86, 0xdd8840d6, 0xd91a5c72, 0x6832be86  };
  alignas(128) uint32_t res3[32] = { 0xdac6ab99, 0x98a0a290, 0xfcb4100a, 0xd77e232c, 0x6257276e, 0xdc571cc8, 0x29da2ced, 0xe22ff55a, 0xe88342e4, 0x7fea7811, 0x860a3fbb, 0x28db4074, 0x491841ae, 0x880e9274, 0xa22bad80, 0x289b950a, 0x07db49aa, 0x954d9e22, 0x456e6c98, 0x9193ddf7, 0x78632551, 0xa1ff4070, 0xd504a1be, 0x30453103, 0x49760f60, 0x17e3bd95, 0xe4482600, 0x474ff41e, 0x6d860af0, 0x24772ca6, 0x8b3c03e2, 0x39db1f0e  };
  alignas(128) uint32_t res4[32] = { 0x456003ed, 0xba02b50f, 0x6c9bcbb6, 0xd9e60769, 0xa13c4092, 0x93687e0b, 0x738c4680, 0xf3129083, 0x19a1b099, 0x23a840b2, 0x852494df, 0x311a9e79, 0xad7efc3a, 0xf86ae07d, 0xa4212e8a, 0x680b9a7f, 0xdc165a46, 0x4f84eb99, 0x2ccfda2e, 0x89a62148, 0xbb3a3e6b, 0xa58d0b61, 0xe4920ed3, 0x38de9de9, 0xad779a43, 0x12f60128, 0xe54fedb0, 0x87a9e617, 0x97825525, 0xfb09f3c4, 0x1655ade5, 0x5adb7182  };
  alignas(128) uint32_t res5[32] = { 0xfc528a4a, 0x36f2b77d, 0xfee809e3, 0xf5ad1354, 0xf5edba8f, 0xe11b46ea, 0x64dc8043, 0x5fbe086b, 0xeabd5d67, 0x9b2bd5ef, 0x8909dd32, 0xff241031, 0x8d0fc943, 0x6d30a595, 0x5b5fc008, 0xf016e77e, 0x433e9f16, 0xdf1c2fb6, 0xf205a8ed, 0xaadb1fe0, 0xac1d090f, 0xa2dddb6b, 0xc7c81529, 0xdf1bf2b7, 0x365287ef, 0xefb35ca3, 0x2fd53e35, 0x528af1cd, 0x1e5e35b5, 0x1c9416b9, 0xa9a23ba9, 0x3a266894  };

  // Trust me on that one
  uint32_t* res = (d_len == 1022) ? res1 : ((d_len == 1018) ? res4 : ((d_len == 1023) ? res5 : (e[0] == 0x0000a295) ? res3 : res2));

  // Proposed CSR for command : use 8 bits : 0bxxxx x used xxx used for number fed
  load_data(HWreg, N, R2_N);
  // the message stays inside the DMA
  /*
  CHANGE TO THE API
  COMMAND :
    0b0001 : 0x01 : A: NOT VALID              X_tilde: MontMul(A      , R2N, N) using A register as the X
    0b0011 : 0x03 : A: MontMul(A,X_tilde,N)   X_tilde: MontMul(X_tilde, X_tilde, N)
    0b0101 : 0x05 : A: MontMul(A,A,N, DBG)    X_tilde: MontMul(A      , X_tilde,N, DBG)
    0b0111 : 0x07 : A: MontMul(A,1,N, DBG)    X_tilde: NOT VALID
  */

  if(SEND_MY_MESSAGE){
    printf("TO BE CREATED\n");
    char* my_message = "Hello world ! This is a message that is longer than 128 characters. So we can also check if this handles longer string of character (hopefully). Can you decrypt it ?\n To avoid the program to go crazy we can for now send maximum a 1000 characters at a time because my strlen isn't really secure. Sorry COSIC.";
    alignas(128) uint32_t message_buffer[32] = {0};
    uint32_t size = my_strlen(my_message);
    uint32_t amount_of_frame = (uint32_t)  ((size-1)/128 + 1);
    //uint32_t message_decrypted[size+1] = {0};

    alignas(128) uint32_t X_tilde[32] = {0};
    alignas(128) uint32_t A[32] = {0};

    for(uint32_t blocks = 0; blocks < amount_of_frame; blocks++){
      encode_message(message_buffer, my_message,size,blocks);
      printf("Message to send : \n");
      print_encoded_message(message_buffer);
      printf("____\n");

      encrypt(HWreg, A, message_buffer, R_N, e, e_len );
      printf("Message encrypted : \n");
      print_encoded_message(A); // This should hold the encrypted message
      printf("____\n");

      encrypt(HWreg, A, A, R_N, d, d_len );
      printf("Message decrypted : \n");
      print_encoded_message(A); // This should hold the decrypted message

      compare_array_contents(A,message_buffer);
      printf("___________\n");
    }

  }else{
    alignas(128) uint32_t X_tilde[32] = {0};
    alignas(128) uint32_t A[32] = {0};
    // Won't use memcpy just to avoid library dependencies
    // HERE IS THE START OF THE ALGORITHM
    START_TIMING
	  encrypt(HWreg, A, M, R_N, e, e_len );

    STOP_TIMING
    // END OF THE ALGORITHM
    printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));
    printf("LSB_N 1 %08X\r\n", (unsigned int)HWreg[1]);
    printf("LSB_R_N 2 %08X\r\n", (unsigned int)HWreg[2]);
    printf("LSB_R2_N 3 %08X\r\n", (unsigned int)HWreg[3]);
    printf("DMA 4 %08X\r\n", (unsigned int)HWreg[4]);
    printf("Loading 5 %08X\r\n", (unsigned int)HWreg[5]);
    printf("State 6 %08X\r\n", (unsigned int)HWreg[6]);
    printf("Load 7 %08X\r\n", (unsigned int)HWreg[7]);

    // print the result against the output datas
    printf("\r\nExpected:\r\n"); print_array_contents(res);
    printf("\r\nGot:\r\n"); print_array_contents(A);
    compare_array_contents(res,A);


    // Decrypt
    START_TIMING
	encrypt(HWreg, A, A, R_N, d, d_len );
    STOP_TIMING
    // END OF THE ALGORITHM
    printf("STATUS 0 %08X | Done %d | Idle %d | Error %d \r\n", (unsigned int)HWreg[STATUS], ISFLAGSET(HWreg[STATUS],0), ISFLAGSET(HWreg[STATUS],1), ISFLAGSET(HWreg[STATUS],2));
    printf("LSB_N 1 %08X\r\n", (unsigned int)HWreg[1]);
    printf("LSB_R_N 2 %08X\r\n", (unsigned int)HWreg[2]);
    printf("LSB_R2_N 3 %08X\r\n", (unsigned int)HWreg[3]);
    printf("DMA 4 %08X\r\n", (unsigned int)HWreg[4]);
    printf("Loading 5 %08X\r\n", (unsigned int)HWreg[5]);
    printf("State 6 %08X\r\n", (unsigned int)HWreg[6]);
    printf("Load 7 %08X\r\n", (unsigned int)HWreg[7]);

    printf("\r\nExpected:\r\n"); print_array_contents(M);
    printf("\r\nGot:\r\n"); print_array_contents(A);
    compare_array_contents(A,M);
  }

  cleanup_platform();

  return 0;
}
