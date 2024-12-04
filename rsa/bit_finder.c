#include <stdint.h>
#include <stdio.h>
#include <stdalign.h>

uint32_t bit(uint32_t* E, uint32_t position){
  uint32_t right_part = E[position/32];

  return (right_part >> (position % 32)) & 0x1;
}

int main(int argc, char** argv){
    // test vectors
    alignas(128) uint32_t e1[32]       = {0x00009985};
    uint32_t e1_len       = 16;
    alignas(128) uint32_t d1[32]       = {0x0140f46d, 0xe8ca4cb4, 0x2fd3b080, 0xb3847fcd, 0x25a13e1a, 0x0d32d306, 0xc8e8f4b9, 0x45246806, 0x7c4fa9c6, 0xfbc6c8ab, 0x7254281b, 0xb490e8ae, 0x7b277a9a, 0xc7146fc3, 0x8258bf27, 0x78513490, 0x12142274, 0x5570bc18, 0xfd1abea5, 0x6036cb79, 0xf6e633a2, 0x6e9f550c, 0x5efa6632, 0x5093578a, 0x69d5dbbe, 0x311d223f, 0xd83a7ae3, 0xa68011ce, 0x1661a975, 0x948034ef, 0x98f8271b, 0x20df3a57};
    uint32_t d1_len       =  1022;

    alignas(128) uint32_t e2[32]       = {0x0000dc85};
    uint32_t e2_len       = 16;
    alignas(128) uint32_t d2[32]        = {0x584de77d, 0x5d1feb8b, 0x8cdb1000, 0xaa4082b5, 0x6b22a217, 0x7dc416d0, 0x9ea82b83, 0xdabe99cf, 0x2efab48c, 0x80b8685d, 0x1e2542cc, 0xdb6aec3b, 0x5eef2cfc, 0xf047fff1, 0xb3afb61a, 0x646d1270, 0xe3546a41, 0xcc8fdc68, 0xcee73e66, 0x07c2ff8a, 0xe4f8b9ab, 0x40cf5181, 0x2cd67859, 0x5f6770e9, 0x6da55b69, 0x174e327e, 0x92b928b5, 0x8c8080fb, 0x8f121111, 0x765ecfad, 0x6a4ac123, 0x8fdb8408};
    uint32_t d2_len        =  1024;

    alignas(128) uint32_t e3[32]       = {0x0000a295};
    uint32_t e3_len       = 16;
    alignas(128) uint32_t d3[32]       = {0x47ebebbd, 0xe04e889a, 0x93347a79, 0xfe6bd1ed, 0x8a84a417, 0x53026e4a, 0xbc36a7a1, 0x5485c36a, 0x4d8a5437, 0xf087ecda, 0x932b1e00, 0x886ae030, 0x8fcd10eb, 0x489dfea6, 0x8eba3569, 0x300919f0, 0xea92eb4d, 0x8e43cb19, 0xf41ea744, 0x1e9775aa, 0xab59f4fa, 0xbba0b857, 0x29286dad, 0x0f674489, 0x2d5ee931, 0x4f1b22f0, 0xb5725487, 0x820ec808, 0x6ff80d8d, 0x73c2b92c, 0xa633c70b, 0xa729d9b3};
    uint32_t d3_len       =  1024;

    alignas(128) uint32_t e4[32]       = {0x0000d7fb};
    uint32_t e4_len       = 16;
    alignas(128) uint32_t d4[32]       = {0xa987261b, 0x17a2f57c, 0x7df4a42b, 0xb4be4f48, 0xc0dc18fd, 0x4e11e692, 0x655ad04a, 0x8f0f9d51, 0x65368f29, 0x0d365209, 0x82d3b33b, 0xe36cd139, 0x473e7d25, 0x0eb587b2, 0x8cc1e155, 0x9bd4e111, 0x0ed6839c, 0x3151f3bb, 0xd323f162, 0xbd4b1a07, 0x646e3a76, 0xf4db2f83, 0x634b93d2, 0xe11e69bb, 0xe885f184, 0x21e67852, 0xf0271e73, 0x20f837cf, 0x36fece05, 0x0b936aa6, 0xe2ec9626, 0x0349d696};
    uint32_t d4_len       =  1018;

    alignas(128) uint32_t e5[32]       = {0x00008e1f};
    uint32_t e5_len       = 16;
    alignas(128) uint32_t d5[32]        = {0x188dfddf, 0x032c3fac, 0x5accddb7, 0x73990c6a, 0x02bc3f7d, 0x3d6c80cd, 0xbf6535c5, 0xbdf2d5b6, 0x9efb1538, 0x5e0c0ab1, 0xa2643142, 0x663202cd, 0x961302a5, 0x3eba4ad9, 0xb7e35f47, 0x247c9964, 0xac9e9869, 0x0fb895ac, 0xedd84778, 0x269b1036, 0x1c5d59dc, 0xd3687f90, 0xefc10e96, 0xf1fa1fbe, 0xdba271cf, 0x7c0c66ab, 0x64bb05b0, 0xb2978989, 0x00638bfd, 0xc525f5a3, 0x729184c5, 0x5b6ef8a4};
    uint32_t d5_len        =  1023;

    uint32_t* e_list[5]     = {e1, e2, e3, e4, e5};
    uint32_t e_len_list[5] = {e1_len, e2_len, e3_len, e4_len, e5_len};
    uint32_t* d_list[5]     = {d1, d2, d3, d4, d5};
    uint32_t d_len_list[5] = {d1_len, d2_len, d3_len, d4_len, d5_len};

    for(uint32_t i = 0; i < 1; i++){
        for(uint32_t j = 0; j < e_len_list[i]; j++){
            printf("%d", bit(e_list[i], e_len_list[i]-j-1));
        }
        printf("\n");
        for(uint32_t j = 0; j < d_len_list[i]; j++){
            printf("%d", bit(d_list[i], d_len_list[i]-j-1));
        }
        printf("\n");
    }

    return 0;
}
