# BCH Encoder Units

This repository contains implementations of two Bose-Chaudhuri-Hocquenghem (BCH) Encoder Units:

1. **BCH (15,7,2) Encoder**
2. **BCH (63, 51,2) Encoder**

## Overview

BCH encoders are used for error correction in digital communication systems. The general representation of BCH Encoders is (n, k, t), where:
- `k` is the input bit length.
- `t` is the error-correcting capacity of the design.
- `n` is the codeword length, which is the concatenation of the input and the parity bits generated.

### Parameters for BCH Encoders

- **Block length (n)**: \( n = 2^m - 1 \)
- **Number of information bits (k)**: \( k \geq n - mt \)
- **Minimum distance (dmin)**: \( d_{min} \geq 2t + 1 \)
- **Detectable errors**: \( d_{min} - 1 \)

Where `m` is the degree of the extension field over the base GF(2). The extended field is \( GF(2^m) \) with \( 2^m \) elements in the field.

The parity bits are generated using a Linear Feedback Shift Register (LFSR) to perform polynomial division. The input message signal is divided by the generator polynomial to determine the remainders, hence the parity bits. These parity bits are then concatenated with the input message. The generator polynomial is determined using an irreducible polynomial for the said field, using the primitive elements.

## BCH (15,7,2) Encoder

- **Codeword length**: 15 bits
- **Input length**: 7 bits
- **Error correction capacity**: 2 bits
- **Minimum distance**: 5 bits (thus, 4 error bits can be detected)
- **Extended field**: \( GF(2^4) \), \( m = 4 \)
- **Generator polynomial**: \( g(x) = 1 + x^4 + x^6 + x^7 + x^8 \)

## BCH (63,51,2) Encoder

- **Codeword length**: 63 bits
- **Input length**: 51 bits
- **Error correction capacity**: 2 bits
- **Minimum distance**: 5 bits (thus, 4 error bits can be detected)
- **Extended field**: \( GF(2^6) \), \( m = 6 \)
- **Generator polynomial**: \( g(x) = 1 + x^3 + x^4 + x^5 + x^8 + x^{10} + x^{12} \)

