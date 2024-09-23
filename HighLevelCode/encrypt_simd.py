from constants import key, S_BOX_FLAT, R_CON

def key_expansion(key):
    # Initialize key schedule with the original key
    key_schedule = list(key)

    # Expand the key schedule
    for i in range(4, 44):
        temp = key_schedule[(i-1)*4:i*4]

        if i % 4 == 0:
            # Rotate the word
            temp = temp[1:] + temp[:1]

            # Apply S-Box
            temp = [S_BOX_FLAT[b] for b in temp]

            # XOR with Rcon
            temp[0] ^= R_CON[i//4 - 1]

        # XOR with the word 4 positions before
        new_word = [temp[j] ^ key_schedule[(i-4)*4 + j] for j in range(4)]
        key_schedule.extend(new_word)

    return key_schedule

# Vectorized SubBytes (S-Box substitution)
def sub_bytes(state, s_box):
    # Assume processing 4 bytes in parallel (example)
    for i in range(0, 16, 4):  # Process 4 bytes at a time
        state[i:i+4] = [s_box[b] for b in state[i:i+4]]  # Substituting 4 bytes at once
    return state

# Vectorized ShiftRows (shifting multiple rows in parallel)
def shift_rows(state):
    # Shift second row (4 bytes in parallel)
    state[1], state[5], state[9], state[13] = state[5], state[9], state[13], state[1]
    # Shift third row (4 bytes in parallel)
    state[2], state[6], state[10], state[14] = state[10], state[14], state[2], state[6]
    # Shift fourth row (4 bytes in parallel)
    state[3], state[7], state[11], state[15] = state[15], state[3], state[7], state[11]
    return state

# Vectorized MixColumns (operating on 4 columns in parallel)
def mix_columns(state):
    for i in range(4):  # Process columns in parallel
        col = state[i*4:(i+1)*4]
        state[i*4:i*4+4] = [
            col[0] ^ col[1] ^ col[2] ^ col[3],  # Example XOR operations vectorized
            col[1] ^ col[2] ^ col[3] ^ col[0],
            col[2] ^ col[3] ^ col[0] ^ col[1],
            col[3] ^ col[0] ^ col[1] ^ col[2]
        ]
    return state

# Vectorized AddRoundKey (XOR multiple bytes in parallel)
def add_round_key(state, round_key):
    # XOR 4 bytes at a time (vectorized)
    for i in range(0, 16, 4):
        state[i:i+4] = [state[j] ^ round_key[j] for j in range(i, i+4)]
    return state

# AES Round with Vectorization
def aes_round(state, round_key, s_box):
    state = sub_bytes(state, s_box)
    state = shift_rows(state)
    state = mix_columns(state)
    state = add_round_key(state, round_key)
    return state

# Final Round without MixColumns, vectorized
def final_round(state, round_key, s_box):
    state = sub_bytes(state, s_box)
    state = shift_rows(state)
    state = add_round_key(state, round_key)
    return state

# AES Encryption with Vectorization
def aes_encrypt(plaintext, key, s_box, round_keys):
    state = list(plaintext)

    # Initial AddRoundKey (vectorized)
    state = add_round_key(state, key)

    # Main Rounds (vectorized)
    for i in range(9):
        round_key = round_keys[i:(i+16)]  # Extract 16 bytes (4 words)
        state = aes_round(state, round_key, s_box)

    # Final Round (vectorized)
    state = final_round(state, round_keys[9*16:-1], s_box)

    return state

plaintext = [0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34]
keyschedule = key_expansion(key)
print(aes_encrypt(plaintext, key, S_BOX_FLAT, keyschedule))