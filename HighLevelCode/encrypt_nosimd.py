from utils import gmul, add_round_key, key_expansion, np
from constants import key, S_BOX

def sub_bytes(state):
    for i in range(4):
        for j in range(4):
            state[i][j] = S_BOX[state[i][j] >> 4][state[i][j] & 0x0F]
    return state

def shift_rows(state):
    state[1] = np.roll(state[1], -1)
    state[2] = np.roll(state[2], -2)
    state[3] = np.roll(state[3], -3)
    return state

def mix_columns(state):
    for i in range(4):
        a = state[:, i]
        state[0][i] = gmul(a[0], 2) ^ gmul(a[1], 3) ^ gmul(a[2], 1) ^ gmul(a[3], 1)
        state[1][i] = gmul(a[0], 1) ^ gmul(a[1], 2) ^ gmul(a[2], 3) ^ gmul(a[3], 1)
        state[2][i] = gmul(a[0], 1) ^ gmul(a[1], 1) ^ gmul(a[2], 2) ^ gmul(a[3], 3)
        state[3][i] = gmul(a[0], 3) ^ gmul(a[1], 1) ^ gmul(a[2], 1) ^ gmul(a[3], 2)
    return state

def aes_encrypt(plaintext, key):
    state = np.array([[plaintext[i + 4 * j] for i in range(4)] for j in range(4)], dtype=np.uint8)
    key_schedule = key_expansion(key)

    state = add_round_key(state, key_schedule, 0)

    for round_num in range(1, 10):
        state = sub_bytes(state)
        state = shift_rows(state)
        state = mix_columns(state)
        state = add_round_key(state, key_schedule, round_num)

    state = sub_bytes(state)
    state = shift_rows(state)
    state = add_round_key(state, key_schedule, 10)

    ciphertext = np.zeros(16, dtype=np.uint8)
    for i in range(4):
        for j in range(4):
            ciphertext[i + 4 * j] = state[i][j]
    return ciphertext

# Example usage:
plaintext = [0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34]

ciphertext = aes_encrypt(plaintext, key)
print("Ciphertext:", ciphertext)
