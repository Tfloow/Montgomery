# API information - RSA - codesign


- [API information - RSA - codesign](#api-information---rsa---codesign)
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

| Register | Description | Explanations |
| :------: | :---------: | :----------: |
|  Rout0   |             |              |
|  Rout1   |             |              |
|  Rout2   |             |              |
|  Rout3   |             |              |
|  Rout4   |             |              |
|  Rout5   |             |              |
|  Rout6   |             |              |
|  Rout7   |             |              |