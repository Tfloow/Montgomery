#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdalign.h>
#include <stdlib.h>
#include <stdint.h>

void print_array_contents(uint32_t* src) {
  int i;
  for (i=32-4; i>=0; i-=4)
    printf("%08x %08x %08x %08x\n\r",
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

void decode_message(uint32_t* message_buffer, char* message){
    /*
    message_buffer : a 128 bytes array of 32 bits integer
    message        : a string of character we want to send that has been already set into 128 bytes
    */
    // Writing to the buffer
    for(int i = 32; i > 0; i--){
        message[128 - 4*i + 3] = (char) (message_buffer[i-1]);
        message[128 - 4*i + 2] = (char) (message_buffer[i-1] >> 8);
        message[128 - 4*i + 1] = (char) (message_buffer[i-1] >> 16);
        message[128 - 4*i + 0] = (char) (message_buffer[i-1] >> 24);
    }
    message[128] = '\0';
}

int main(int argc, char** argv){
    if(argc != 2){
        printf("[LOG] : You should provide an input string between double quotes\n");
        return 1;
    }

    uint32_t size = (uint32_t) strlen(argv[1]);
    double amount_of_frame = ceil((float) size/128); // since we can fit as maximum 128 bytes (if ASCII we can fit 142)
    alignas(128) uint32_t message[32] = {0};
    char sanitize_input[32*4] = {0};
    char decode_output[32*4 + 1]  = {0};

    printf("[LOG] : Amount of characters : %d\n",size);
    printf("[LOG] : Text : %s\n", argv[1]);
    printf("[LOG] : Amount of frames : %f\n",  ceil((float) size/128));

    for(uint32_t blocks = 0; blocks < amount_of_frame; blocks++){
        // clean the sanitize input
        for(uint32_t j = 0; j < 32*4; j++){
            sanitize_input[j] = 0;
        }
        // write to the sanitize input
        for(uint32_t j = 0; j < fmin(128, size - blocks*128); j++){
            sanitize_input[j] = argv[1][blocks*128 + j];
        }
        write_to_buffer(message, sanitize_input);
        printf("______\n");
        print_array_contents(message);

        // Decode test
        decode_message(message, decode_output);
        printf("[LOG] : Decoded : %s\n",decode_output);
    }

    return 0;
}