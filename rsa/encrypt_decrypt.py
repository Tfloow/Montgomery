import binascii

def rsa_encrypt(message: str, N: int, exponent: int) -> int:
    """
    Encrypt a message using RSA.
    
    Args:
        message (str): The plaintext message to encrypt.
        N (int): The modulus (part of the public key).
        exponent (int): The exponent (part of the public key, usually 'e').
    
    Returns:
        int: The encrypted message as a numeric value.
    """
    # Convert the message to an integer
    message_int = int(binascii.hexlify(message.encode()), 16)
    
    # Ensure the message fits within the modulus
    if message_int >= N:
        raise ValueError("The message is too large for the modulus.")
    
    # Perform RSA encryption: ciphertext = (message ^ exponent) % N
    ciphertext = pow(message_int, exponent, N)
    
    return ciphertext

if __name__ == "__main__":
    # RSA public key parts (example values)
    N = 0x28c9249d2d275cd947a5e81458e314bf3b3a20dea1fd8b70bc860be0e534550659000e06e99045abdef188ef3de09b8ce683fc3c458971b6dddab60b01d3de7d9d964404d520ac972f8272f188695fd17556d714015e270b08714b0578055a3df69332490bba40286bb24dd6dcf9069c3339650a98a62f43400aba4cccd61077
    e = 0x00009985
    e_len = 16
    M = "Hello World ! This is a test text for the RSA algorithm. This text is longer than 128 characters to check the splitting of message. Does it work ?"
    R_N = 0xd736db63d2d8a326b85a17eba71ceb40c4c5df215e02748f4379f41f1acbaaf9a6fff1f9166fba54210e7710c21f6473197c03c3ba768e49222549f4fe2c21826269bbfb2adf5368d07d8d0e7796a02e8aa928ebfea1d8f4f78eb4fa87faa5c2096ccdb6f445bfd7944db2292306f963ccc69af56759d0bcbff545b33329ef88
    R2_N = 0x1247ae04847a5bd1ad9bd3f5114f8acd1202d61837198dd83f74e618baf66206b62440a83f787503d5258da99bca8d5003ee507877949f4f520c79b53f92cef0fdd351a34e96c23dd043fc80f13f8be96c9a19f2fb8ad49391abfe40444da791a336a065ec2d03396c347e1917580550d1b94a0dadb669feccf6db0e1f15c169
    
    M = "This is a test"
    
    # Encrypt the message
    encrypted = rsa_encrypt(M, N, e)
    
    print(f"Encrypted message (numeric): {hex(encrypted)}")