import numpy as np
from constants import S_BOX, R_CON

def gmul(a, b):
    p = 0
    for i in range(8):
        if b & 1:
            p ^= a
        high_bit_set = a & 0x80
        a <<= 1
        if high_bit_set:
            a ^= 0x1b
        b >>= 1
    return p & 0xFF

def add_round_key(state, key_schedule, round_num):
    for i in range(4):
        for j in range(4):
            state[i][j] ^= key_schedule[round_num * 4 + j][i]
    return state

def key_expansion(key):
    key_schedule = np.zeros((44, 4), dtype=np.uint8)
    for i in range(4):
        for j in range(4):
            key_schedule[i][j] = key[i * 4 + j]
    
    for i in range(4, 44):
        temp = key_schedule[i - 1]
        if i % 4 == 0:
            temp = np.roll(temp, -1)
            for j in range(4):
                temp[j] = S_BOX[temp[j] >> 4][temp[j] & 0x0F]
            temp[0] ^= R_CON[i // 4 - 1]
        key_schedule[i] = key_schedule[i - 4] ^ temp
    return key_schedule