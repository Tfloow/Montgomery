# API information RSA codesign


- [API information RSA codesign](#api-information-rsa-codesign)
  - [Input register](#input-register)
    - [Reasoning and discussion](#reasoning-and-discussion)
  - [Output register](#output-register)


## Input register

| Register |     Description     |                 Explanations                 |
| :------: | :-----------------: | :------------------------------------------: |
|   Rin0   |  command register   |     Main register to send input command      |
|   Rin1   |   dma_rx_address    |       here is the DMA receive address        |
|   Rin2   |   dma_tx_address    |       here is the DMA transmit address       |
|   Rin3   |          t          |       saves the value of the exponent        |
|   Rin4   |        t_len        |     used during the loading of the data      |
|   Rin5   | Loading data status | Command to indicate the state of the loading |
|   Rin6   |                     |                                              |
|   Rin7   |                     |                                              |

### Reasoning and discussion

I have decided to not transfer the exponet e over DMA since most common choice of exponents for RSA algorithm is a 16 bits + 1 integers and all of the vector test that I produced gave me some 16 bits exponents. 
Theoritically, we could go higher but we will loose in speed for any RSA implementation. So since we are taking less than 32 bits, I will transfer e and its length through a register and not wasting clock cycles loading it.

We will only 3 loading operations to load N,R_N and R2_N.

## Output register

| Register |  Description   |                   Explanations                   |
| :------: | :------------: | :----------------------------------------------: |
|  Rout0   |     Status     |       indicate the status of the Hardware        |
|  Rout1   |     LSB_N      |  will write the 32 last bits of the register N   |
|  Rout2   |    LSB_R_N     | will write the 32 last bits of the register R_N  |
|  Rout3   |    LSB_R2_N    | will write the 32 last bits of the register R2_N |
|  Rout4   | dma_rx_address |   dbg to check the address of the DMA receive    |
|  Rout5   |    Loading     |        indicate what data are we loading         |
|  Rout6   |     State      |          indicate the state of the FSM           |
|  Rout7   |                |                                                  |