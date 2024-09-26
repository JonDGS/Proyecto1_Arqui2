from constants import key, text, R_CON, RGF_matrix, RGF_matrix_transpose, Inv_RGF_matrix, Inv_RGF_matrix_transpose, S_BOX, INV_S_BOX

def format_vector(vector):
    formatted_vector = []
    for i in range(0, len(vector), 4):
        # Combine 4 bytes into one 32-bit integer
        combined = (vector[i] << 24) | (vector[i+1] << 16) | (vector[i+2] << 8) | vector[i+3]
        formatted_vector.append(combined)
    return formatted_vector

def format_matrix(matrix):
    formatted_matrix = []
    for row in matrix:
        # Combine the 4 bytes of each row into one 32-bit integer
        combined = (row[0] << 24) | (row[1] << 16) | (row[2] << 8) | row[3]
        formatted_matrix.append(combined)
    return formatted_matrix

def fill_with_zeroes(f, start, end):
    """ Fill the space between `start` and `end` addresses with zeroes """
    f.write(f"  [{start}..{end-1}]: 0;\n")

def write_mif_file(file_name):
    depth = 12288
    width = 256

    # Format the constants that need formatting
    formatted_key = format_vector(key)
    formatted_rcon = format_matrix(R_CON)
    formatted_rgf_matrix = format_matrix(RGF_matrix)
    formatted_rgf_matrix_transpose = format_matrix(RGF_matrix_transpose)
    formatted_inv_rgf_matrix = format_matrix(Inv_RGF_matrix)
    formatted_inv_rgf_matrix_transpose = format_matrix(Inv_RGF_matrix_transpose)
    formatted_text = format_vector(text)

    with open(file_name, 'w') as f:
        f.write(f"DEPTH = {depth};\n")
        f.write(f"WIDTH = {width};\n\n")
        f.write("ADDRESS_RADIX = DEC;\n")
        f.write("DATA_RADIX = HEX;\n\n")
        f.write("CONTENT BEGIN\n")

        # Write the key at address range 0x0 to 0x10
        for i, value in enumerate(formatted_key):
            f.write(f"  {i:04X}: {value:08X};\n")
        
        # Fill the space between key and R_CON (0x10 to 0xB8)
        fill_with_zeroes(f, 0x10, 0xB8)

        # Write the R_CON at address range 0xB8 to 0xE0
        for i, value in enumerate(formatted_rcon):
            f.write(f"  {0xB8 + i:04X}: {value:08X};\n")

        # Fill the space between R_CON and RGF_matrix (0xE0 to 0xE4)
        fill_with_zeroes(f, 0xE0, 0xE4)

        # Write the RGF_matrix at address range 0xE4 to 0xF4
        for i, value in enumerate(formatted_rgf_matrix):
            f.write(f"  {0xE4 + i:04X}: {value:08X};\n")

        # Fill the space between RGF_matrix and RGF_matrix_transpose (0xF4 to 0xF8)
        fill_with_zeroes(f, 0xF4, 0xF8)

        # Write the RGF_matrix_transpose at address range 0xF8 to 0x108
        for i, value in enumerate(formatted_rgf_matrix_transpose):
            f.write(f"  {0xF8 + i:04X}: {value:08X};\n")

        # Fill the space between RGF_matrix_transpose and Inv_RGF_matrix (0x108 to 0x10C)
        fill_with_zeroes(f, 0x108, 0x10C)

        # Write the Inv_RGF_matrix at address range 0x10C to 0x11C
        for i, value in enumerate(formatted_inv_rgf_matrix):
            f.write(f"  {0x10C + i:04X}: {value:08X};\n")

        # Fill the space between Inv_RGF_matrix and Inv_RGF_matrix_transpose (0x11C to 0x120)
        fill_with_zeroes(f, 0x11C, 0x120)

        # Write the Inv_RGF_matrix_transpose at address range 0x120 to 0x130
        for i, value in enumerate(formatted_inv_rgf_matrix_transpose):
            f.write(f"  {0x120 + i:04X}: {value:08X};\n")

        # Fill the space between Inv_RGF_matrix_transpose and S_BOX (0x130 to 0x134)
        fill_with_zeroes(f, 0x130, 0x134)

        # Write the S_BOX at address range 0x134 to 0x218 (no formatting needed)
        for i, row in enumerate(S_BOX):
            f.write(f"  {0x134 + i:04X}: {''.join(f'{byte:02X}' for byte in row)};\n")

        # Fill the space between S_BOX and INV_S_BOX (0x218 to 0x21C)
        fill_with_zeroes(f, 0x218, 0x21C)

        # Write the INV_S_BOX at address range 0x21C to 0x300 (no formatting needed)
        for i, row in enumerate(INV_S_BOX):
            f.write(f"  {0x21C + i:04X}: {''.join(f'{byte:02X}' for byte in row)};\n")

        # Fill the space between INV_S_BOX and Text (0x300 to 0x948)
        fill_with_zeroes(f, 0x300, 0x948)

        # Write the text at address range 0x948 to 0x849C
        for i, value in enumerate(formatted_text):
            f.write(f"  {0x948 + i:04X}: {value:08X};\n")

        # Fill the remaining space (assumes 0 for unfilled addresses)
        f.write(f"  [0x849C..{depth - 1}]: 0;\n")

        f.write("END;\n")

# Specify the file name you want to create
write_mif_file('output.mif')