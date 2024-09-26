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

        address = 0  # Start address

        # Write the key at address range 0 to 16
        for value in formatted_key:
            f.write(f"  {address}: {value:08X};\n")
            address += 4  # Increment address by 4
        
        # Fill the space between key and R_CON (address 16 to 184)
        fill_with_zeroes(f, address, 184)
        address = 184  # Update address

        # Write the R_CON at address range 184 to 224
        for value in formatted_rcon:
            f.write(f"  {address}: {value:08X};\n")
            address += 4
        
        # Fill the space between R_CON and RGF_matrix (address 224 to 228)
        fill_with_zeroes(f, address, 228)
        address = 228  # Update address

        # Write the RGF_matrix at address range 228 to 244
        for value in formatted_rgf_matrix:
            f.write(f"  {address}: {value:08X};\n")
            address += 4
        
        # Fill the space between RGF_matrix and RGF_matrix_transpose (address 244 to 248)
        fill_with_zeroes(f, address, 248)
        address = 248  # Update address

        # Write the RGF_matrix_transpose at address range 248 to 264
        for value in formatted_rgf_matrix_transpose:
            f.write(f"  {address}: {value:08X};\n")
            address += 4
        
        # Fill the space between RGF_matrix_transpose and Inv_RGF_matrix (address 264 to 268)
        fill_with_zeroes(f, address, 268)
        address = 268  # Update address

        # Write the Inv_RGF_matrix at address range 268 to 284
        for value in formatted_inv_rgf_matrix:
            f.write(f"  {address}: {value:08X};\n")
            address += 4
        
        # Fill the space between Inv_RGF_matrix and Inv_RGF_matrix_transpose (address 284 to 288)
        fill_with_zeroes(f, address, 288)
        address = 288  # Update address

        # Write the Inv_RGF_matrix_transpose at address range 288 to 304
        for value in formatted_inv_rgf_matrix_transpose:
            f.write(f"  {address}: {value:08X};\n")
            address += 4
        
        # Fill the space between Inv_RGF_matrix_transpose and S_BOX (address 304 to 308)
        fill_with_zeroes(f, address, 308)
        address = 308  # Update address

        # Write the S_BOX at address range 308 to 1208 (no formatting needed)
        for row in S_BOX:
            for value in row:
                f.write(f"  {address}: {value:08X};\n")
                address += 4  # Increment address by 4
        
        # Fill the space between S_BOX and INV_S_BOX (address 1208 to 1212)
        fill_with_zeroes(f, address, 1212)
        address = 1212  # Update address

        # Write the INV_S_BOX at address range 1212 to 2112 (no formatting needed)
        for row in INV_S_BOX:
            for value in row:
                f.write(f"  {address}: {value:08X};\n")
                address += 4  # Increment address by 4
        
        # Fill the space between INV_S_BOX and Text (address 2112 to 2116)
        fill_with_zeroes(f, address, 2116)
        address = 2116  # Update address

        # Write the text at address range 2116 to 34620
        for value in formatted_text:
            f.write(f"  {address}: {value:08X};\n")
            address += 4  # Increment address by 4

        # Fill the remaining space (assumes 0 for unfilled addresses)
        fill_with_zeroes(f, address, depth)

        f.write("END;\n")

# Specify the file name you want to create
write_mif_file('output.mif')