start $zero
j generateRoundKeys

# Rotate values from index to index + 4
# CHECK ADDRESSES BEFORE DEPLOYING
rotateColumn:
    lw $t0, $t0, 0 
    addi $t5, $zero, 0xFF
    addi $t6. $zero, 24
    srl $t1, $t0, $t6 # Loads column[0]
    addi $t6. $zero, 16
    srl $t2, $t0, $t6 # Loads column[1]
    and $t2, $t0, $t5 # Loads column[1] after mask
    addi $t6. $zero, 8
    srl $t3, $t0, $t6 # Loads column[2]
    and $t3, $t0, $t5 # Loads column[2] after mask
    and $t4, $t0, $t5 # Loads column[3] after mask
    addi $t6, $zero, 24 # Mask for first pos
    sll $t2, $t2, $t6 # Loads t2 to first pos
    addi $t6, $zero, 16 # Mask for second pos
    sll $t3, $t3, $t6 # Loads t3 to second pos
    addi $t6, $zero, 8 # Mask for third pos
    sll $t4, $t4, $t6 # Loads t4 to third pos
    add $t7, $zero, $t1
    add $t7, $t7, $t2
    add $t7, $t7, $t3
    add $t7, $t7, $t4
    sw $t0, $t7, 0
    j grk_multiple_case1

#Given a memory index at t0, replace its value with
# the corresponding value in the S_BOX
subValueAtIndex:
    lw $t1, $t0, 0 # Loads value at memory address
    addi $t6, $zero, 4
    srl $t2, $t1, $t6 # Shifts value at t1 to get t1 // 16
    addi $t3, $zero, 0xF # Loads 0xF mask to t3
    and $t3, $t1, $t3 # Computes t1 % 16 using mask
    addi $t4, $zero, 15 # Loads row amounts for S_BOX
    mul $t2, $t2 # Computes row * rowNumbers for S_BOX
    add $t2, $t2, $t3 # Computes t2 + t3 for index in S_BOX
    lw $t2, $t1, 0 # loads value to replace
    sw $t2, $t0, 0 # Stores value to index in memory
    beq $t14, $zero, subValuesInColumn2 # Assuming callee is subValuesInColumn
    addi $t13, $zero, 1 #Loads a 1 to t13
    beq $t14, $t13, round_Loop1 # Assuming callee is round_Loop
    addi $t13, $zero, 2 #Loads a 2 to t13
    beq $t14, $t13, round_Loop2 # Assuming callee is round_Loop1
    addi $t13, $zero, 3 #Loads a 3 to t13
    beq $t14, $t13, round_Loop3 # Assuming callee is round_Loop2
    j round_Loop4 # Assuming callee is round_Loop3

# Assumes t0 holds address of column
# Assumes t1 holds the counter for traversing the column
subValuesInColumn:
    addi $t3, $zero, 4 # Loads a 4 to register t3
    beq $t2, $t3, getrconbyindex # Given index 4 reached, jump to end of subBytes
    j subValueAtIndex # Jumps to function subValueAtIndex

subValuesInColumn2:
    addi $t1, $t1, 1 # Increases the counter
    j subValuesInColumn # Recursively calls function

# Assume the index for the RCON column is at t0
getrconbyindex:
    lw $t1, $t0, 0 # Loads RCON value at t0
    addi $t6, $zero, 24
    srl $t3, $t1, $t6 # Loads value on high of column
    j grk_multiple_case2

# Computes the value for w_{i} if the index
# is a multiple of 4
grk_multiple_case:
    addi $t5, $zero, 0xc5 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    lw $t1, $t0, -4 # Loads previous column in current index (copy w{-1} to t1)
    sw $t1, $t0, 0 # Copies the contents of w{-1} to w{1}
    j rotateColumn #Rotate column

grk_multiple_case1:
    lw $t0, $t5, 0 # Restores current index for subValue stage
    add $t1, $zero, $zero # Loads a 0 to register t1
    addi $t14, $zero, 0 # Loads condition
    j subValuesInColumn # SubBytes at column in index t0

grk_multiple_case2:
    lw $t4, $t0, 0 # Loads column wi
    addi $t9, $zero, 24
    srl $t4, $t4, $t9 # Loads column wi[0]
    lw $t5, $t0, -16 # Loads column wi-4
    srl $t5, $t5, $t9 # Loads column wi-4[0]
    xor $t6, $t4, $t5 # wi[0] xor wi-4[0]
    xor $t6, $t6, $t3 #  wi[0] xor wi-4[0] xor rcon[round]
    sll $t6, $t6, $t9 # Moves it to the beginning of t6
    add $t7, $t6, $zero # Copies result to t7
    lw $t4, $t0, 0 # Loads column wi
    addi $t9, $zero, 16
    srl $t4, $t4, $t9 # Loads column wi[1]
    addi $t8, $zero, 0xFF # Loads mask
    and $t4, $t4, $t8 # Loads LSB 2 bytes of t4
    lw $t5, $t0, -16 # Loads column wi-4
    srl $t5, $t5, $t9 # Loads column wi-4[1]
    and $t5, $t5, $t8 # Loads LSB 2 bytes of t5
    xor $t6, $t4, $t5 # wi[1] xor wi-4[1]
    sll $t6, $t6, $t9 # Shifts result to front
    add $t7, $t7, $t6 # Pushes result to second pos
    lw $t4, $t0, 0 # Loads column wi
    addi $t9, $zero, 8
    srl $t4, $t4, $t9 # Loads column wi[2]
    addi $t8, $zero, 0xFF # Loads mask
    and $t4, $t4, $t8 # Loads LSB 2 bytes of t4
    lw $t5, $t0, -16 # Loads column wi-4
    srl $t5, $t5, $t9 # Loads column wi-4[2]
    and $t5, $t5, $t8 # Loads LSB 2 bytes of t5
    xor $t6, $t4, $t5 # wi[2] xor wi-4[2]
    sll $t6, $t6, $t9 # Shifts result to front
    add $t7, $t7, $t6 # Pushes result to third pos
    lw $t4, $t0, 0 # Loads column wi
    addi $t8, $zero, 0xFF # Loads mask
    and $t4, $t4, $t8 # Loads LSB 2 bytes of t4
    lw $t5, $t0, -16 # Loads column wi-4
    and $t5, $t5, $t8 # Loads LSB 2 bytes of t5
    xor $t6, $t4, $t5 # wi[3] xor wi-4[3]
    add $t7, $t7, $t6 # Pushes result to last pos
    sw $t7, $t0, 0 # Store result in wi pos
    lw $t0, $t5, 0 # Restores original value of t0
    lw $t1, $t5, 4 # Restores original value of t1
    lw $t6, $t5, 8 # Restores original value of t6
    addi $t0, $t0, 1 # Increases index by 1
    j generateRoundKey # Returns to generateRoundKey

grk_default_case:
    addi $t5, $zero, 0xc5 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    sw $t6, $t5, 8 # Stores pc of callee at mem address $t5 + 8
    lw $t1, $t0, -4 # Loads previous column in current index (copy w{-1} to t1)
    sw $t1, $t0, 0 # Copies the contents of w{-1} to w{i}
    lw $t4, $t0, 0 # Loads column wi
    addi $t9, $zero, 24
    srl $t4, $t4, $t9 # Loads column wi[0]
    lw $t5, $t0, -16 # Loads column wi-4
    srl $t5, $t5, $t9 # Loads column wi-4[0]
    xor $t6, $t4, $t5 # wi[0] xor wi-4[0]
    sll $t6, $t6, $t9 # Moves it to the beginning of t6
    add $t7, $t6, $zero # Copies result to t7
    lw $t4, $t0, 0 # Loads column wi
    addi $t9, $zero, 16
    srl $t4, $t4, $t9 # Loads column wi[1]
    addi $t8, $zero, 0xFF # Loads mask
    and $t4, $t4, $t8 # Loads LSB 2 bytes of t4
    lw $t5, $t0, -16 # Loads column wi-4
    srl $t5, $t5, $t9 # Loads column wi-4[1]
    and $t5, $t5, $t8 # Loads LSB 2 bytes of t5
    xor $t6, $t4, $t5 # wi[1] xor wi-4[1]
    sll $t6, $t6, $t9 # Shifts result to front
    add $t7, $t7, $t6 # Pushes result to second pos
    lw $t4, $t0, 0 # Loads column wi
    addi $t9, $zero, 8
    srl $t4, $t4, $t9 # Loads column wi[2]
    addi $t8, $zero, 0xFF # Loads mask
    and $t4, $t4, $t8 # Loads LSB 2 bytes of t4
    lw $t5, $t0, -16 # Loads column wi-4
    srl $t5, $t5, $t9 # Loads column wi-4[2]
    and $t5, $t5, $t8 # Loads LSB 2 bytes of t5
    xor $t6, $t4, $t5 # wi[2] xor wi-4[2]
    sll $t6, $t6, $t9 # Shifts result to front
    add $t7, $t7, $t6 # Pushes result to third pos
    lw $t4, $t0, 0 # Loads column wi
    addi $t8, $zero, 0xFF # Loads mask
    and $t4, $t4, $t8 # Loads LSB 2 bytes of t4
    lw $t5, $t0, -16 # Loads column wi-4
    and $t5, $t5, $t8 # Loads LSB 2 bytes of t5
    xor $t6, $t4, $t5 # wi[3] xor wi-4[3]
    add $t7, $t7, $t6 # Pushes result to last pos
    sw $t7, $t0, 0 # Store result in wi pos
    lw $t0, $t5, 0 # Restores original value of t0
    lw $t1, $t5, 4 # Restores original value of t1
    lw $t6, $t5, 8 # Restores original value of t6
    addi $t0, $t0, 1 # Increases index by 1
    blt $t0, $t1, generateRoundKey #While keyschedule not complete, continue generating
    j encrypt

# Generates a key for a single round
# Uses t1 as main index
generateRoundKey:
    addi $t2, $zero, 3 #Loads 3 to temporal register for modulo 4
    and, $t2, $t0, $t2 #Loads modulo of index for base 4
    beq $zero, $t2, grk_multiple_case
    j grk_default_case

# Mixes the columns with the Matrix in memory
mixColumns:
    addi $t1, $zero, 0x63 # Loads address for matrix
    vld $v0, $t1, 0 # Loads matrix to register v1
    vset $v1, 0 # Zeroes v1
    addi $t2, $zero, 0x169 # Loads address in memory to be used temporarily
    vst $v1, $t2, 0 # Stores zeroed vector to memory
    lw $t3, $t0, 0 # Loads current column to register t3
    sw $t3, $t2, 0 # Stores current column to memory
    vld $v1, $t2, 0 # Brings vector of current column and zeroes
    vmul $v1, $v0, $v1 # Matrix multiplication of v0 and v1
    vst $v1, $t2, 0 # Stores resulting vector in memory
    lw $t3, $t2, 0 # Loads result to t3
    sw $t3, $t0, 0 # Replaces current column in memory
    j round_Loop5


# Finishes the program
cest_fini:
    end $zero

# Assumes t0 holds the round index, and t1 holds 11 (11 rounds)
round_Loop:
    addi $t3, $zero, 0xCC # First address in DATA
    lw $t0, $t3, 0 # Restores value of index round
    lw $t1, $t3, 4 # Restores value of max rounds
    blt $t0, $t1, cest_fini
    sw $t0, $t3, 0 # Saves index back to memory
    sw $t1, $t3, 4 # Saves max rounds back to memory
    add $t1, $t0, $zero # temporarily saves t0 to t1
    addi $t14, $zero, 1 # Loads t14 with a 1
    j subValueAtIndex # SubBytes at first column

round_Loop1:
    addi $t1, $zero, 4 # Increases addresss to reach second column
    addi $t14, $zero, 2 # Loads t14 with a 2
    j subValueAtIndex # SubBytes at second column

round_Loop2:
    addi $t1, $zero, 4 # Increases addresss to reach third column
    addi $t14, $zero, 3 # Loads t14 with a 3
    j subValueAtIndex # SubBytes at third column

round_Loop3:
    addi $t1, $zero, 4 # Increases addresss to reach fourth column
    addi $t14, $zero, 4 # Loads t14 with a 4
    j subValueAtIndex # SubBytes at fourth column

round_Loop4:
    #Rotate 2nd row
    addi $t8, $zero, 0x260 # Loads initial address of state
    addi $t9, $zero, 16 # Loads 16 for shifts
    addi $t10, $zero 0xFF # Loads mask
    lw $t0, $t8, 0 # Loads column
    srl $t0, $t0, $t9 # Shifts to get second value to LSB
    and $t0, $t0, $t10 # Apply mask
    lw $t1, $t8, 4 # Loads column
    srl $t1, $t1, $t9 # Shifts to get second value to LSB
    and $t1, $t1, $t10 # Apply mask
    lw $t2, $t8, 8 # Loads column
    srl $t2, $t2, $t9 # Shifts to get second value to LSB
    and $t2, $t2, $t10 # Apply mask
    lw $t3, $t8, 12 # Loads column
    srl $t3, $t3, $t9 # Shifts to get second value to LSB
    and $t3, $t3, $t10 # Apply mask
    sll $t4, $t1, $t9 # Shifts back in place
    sll $t5, $t2, $t9 # Shifts back in place
    sll $t6, $t3, $t9 # Shifts back in place
    sll $t7, $t0, $t9 # Shifts back in place
    addi $t10, $zero, 0xFF00FFFF # Changes mask
    lw $t0, $t8, 0 # Loads state column to t0
    xor $t0, $t0, $t10 # Applies mask
    add $t0, $t0, $t4 # Merges current column with result
    lw $t1, $t8, 4 # Loads state column to t1
    xor $t1, $t1, $t10 # Applies mask
    add $t1, $t1, $t5 # Merges current column with result
    lw $t2, $t8, 8 # Loads state column to t2
    xor $t2, $t2, $t10 # Applies mask
    add $t2, $t2, $t6 # Merges current column with result
    lw $t3, $t8, 12 # Loads state column to t3
    xor $t3, $t3, $t10 # Applies mask
    add $t3, $t3, $t7 # Merges current column with result
    sw $t0, $t8, 0 # Saves first column result
    sw $t1, $t8, 4 # Saves second column result
    sw $t2, $t8, 8 # Saves third column result
    sw $t3, $t8, 12 # Saves fourth column result
    #Rotate third row
    addi $t9, $zero, 8 # Loads 16 for shifts
    addi $t10, $zero 0xFF # Loads mask
    lw $t0, $t8, 0 # Loads column
    srl $t0, $t0, $t9 # Shifts to get second value to LSB
    and $t0, $t0, $t10 # Apply mask
    lw $t1, $t8, 4 # Loads column
    srl $t1, $t1, $t9 # Shifts to get second value to LSB
    and $t1, $t1, $t10 # Apply mask
    lw $t2, $t8, 8 # Loads column
    srl $t2, $t2, $t9 # Shifts to get second value to LSB
    and $t2, $t2, $t10 # Apply mask
    lw $t3, $t8, 12 # Loads column
    srl $t3, $t3, $t9 # Shifts to get second value to LSB
    and $t3, $t3, $t10 # Apply mask
    sll $t4, $t2, $t9 # Shifts back in place
    sll $t5, $t3, $t9 # Shifts back in place
    sll $t6, $t0, $t9 # Shifts back in place
    sll $t7, $t1, $t9 # Shifts back in place
    addi $t10, $zero, 0xFFFF00FF # Changes mask
    lw $t0, $t8, 0 # Loads state column to t0
    xor $t0, $t0, $t10 # Applies mask
    add $t0, $t0, $t4 # Merges current column with result
    lw $t1, $t8, 4 # Loads state column to t1
    xor $t1, $t1, $t10 # Applies mask
    add $t1, $t1, $t5 # Merges current column with result
    lw $t2, $t8, 8 # Loads state column to t2
    xor $t2, $t2, $t10 # Applies mask
    add $t2, $t2, $t6 # Merges current column with result
    lw $t3, $t8, 12 # Loads state column to t3
    xor $t3, $t3, $t10 # Applies mask
    add $t3, $t3, $t7 # Merges current column with result
    sw $t0, $t8, 0 # Saves first column result
    sw $t1, $t8, 4 # Saves second column result
    sw $t2, $t8, 8 # Saves third column result
    sw $t3, $t8, 12 # Saves fourth column result
    # Rotate fourth column
    addi $t9, $zero, 0 # Loads 16 for shifts
    addi $t10, $zero 0xFF # Loads mask
    lw $t0, $t8, 0 # Loads column
    srl $t0, $t0, $t9 # Shifts to get second value to LSB
    and $t0, $t0, $t10 # Apply mask
    lw $t1, $t8, 4 # Loads column
    srl $t1, $t1, $t9 # Shifts to get second value to LSB
    and $t1, $t1, $t10 # Apply mask
    lw $t2, $t8, 8 # Loads column
    srl $t2, $t2, $t9 # Shifts to get second value to LSB
    and $t2, $t2, $t10 # Apply mask
    lw $t3, $t8, 12 # Loads column
    srl $t3, $t3, $t9 # Shifts to get second value to LSB
    and $t3, $t3, $t10 # Apply mask
    sll $t4, $t3, $t9 # Shifts back in place
    sll $t5, $t0, $t9 # Shifts back in place
    sll $t6, $t1, $t9 # Shifts back in place
    sll $t7, $t2, $t9 # Shifts back in place
    addi $t10, $zero, 0xFFFFFF00 # Changes mask
    lw $t0, $t8, 0 # Loads state column to t0
    xor $t0, $t0, $t10 # Applies mask
    add $t0, $t0, $t4 # Merges current column with result
    lw $t1, $t8, 4 # Loads state column to t1
    xor $t1, $t1, $t10 # Applies mask
    add $t1, $t1, $t5 # Merges current column with result
    lw $t2, $t8, 8 # Loads state column to t2
    xor $t2, $t2, $t10 # Applies mask
    add $t2, $t2, $t6 # Merges current column with result
    lw $t3, $t8, 12 # Loads state column to t3
    xor $t3, $t3, $t10 # Applies mask
    add $t3, $t3, $t7 # Merges current column with result
    sw $t0, $t8, 0 # Saves first column result
    sw $t1, $t8, 4 # Saves second column result
    sw $t2, $t8, 8 # Saves third column result
    sw $t3, $t8, 12 # Saves fourth column result
    blt $t0, $t1, mixColumns # If round less than 10, mix columns
    j round_Loop5

round_Loop5:
    addi $t2, $zero, 16 # Loads 16 to memory
    mul $t2, $t2, $t0 # Computes round key address
    vld $v1, $t0, 0 # Loads round key to v0
    addi $t4, $zero, 0x485 # Loads memory address of state
    vld $v2, $t4, 0 # Loads state to register v2
    vxor $v2, $v2, $v1 # Computes roundkey xor state
    addi $t0, $t0, 1 # Increases round by 1
    j round_Loop

# Computes the state xor roundKey
# Assumes t1 has current round
addRoundKey:
    addi $t3, $zero, 4 # Loads 4 to t3
    add $t8, $zero, $t1 # Copies round index to t8
    mul $t3, $t3, $t1 # Computes round*4
    addi $t3, $t3, 0x0 # Computes the address of the first column of round key
    lw $t0, $zero, 0x260 # Stores first column of state to t0
    lw $t1, $t3, 0 # Stores first column of corresponding roundkey
    addi $t6, $zero, 24 # Loads shift amount for first elements
    srl $t0, $t0, $t6 # Loads first element of column state using shifts
    srl $t1, $t1, $t6 # Loads first element of column roundkey using shifts
    xor $t4, $t0, $t1 # Computes state[column][0] xor roundkey[column][0]
    sll $t4, $t4, $t6 # Shifts result to first pos
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 16 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads second element of column state using shifts
    srl $t1, $t1, $t6 # Loads second element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][1] xor roundkey[column][1]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 8 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads third element of column state using shifts
    srl $t1, $t1, $t6 # Loads third element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][2] xor roundkey[column][2]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][3] xor roundkey[column][3]
    add $t4, $t5, $t3 # Loads result to final register
    addi $t0, $zero, 0x260 # Loads starting address of state
    sw $t4, $t0, 0 # Stores result of key
    # Start computing second column
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t0, $t0, 4 # Address of second column
    addi $t1, $t1, 4 # Address of second column
    lw $t1, $t3, 0 # Stores first column of corresponding roundkey
    addi $t6, $zero, 24 # Loads shift amount for first elements
    srl $t0, $t0, $t6 # Loads first element of column state using shifts
    srl $t1, $t1, $t6 # Loads first element of column roundkey using shifts
    xor $t4, $t0, $t1 # Computes state[column][0] xor roundkey[column][0]
    sll $t4, $t4, $t6 # Shifts result to first pos
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 16 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads second element of column state using shifts
    srl $t1, $t1, $t6 # Loads second element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][1] xor roundkey[column][1]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 8 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads third element of column state using shifts
    srl $t1, $t1, $t6 # Loads third element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][2] xor roundkey[column][2]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][3] xor roundkey[column][3]
    add $t4, $t5, $t3 # Loads result to final register
    addi $t0, $zero, 0x260 # Loads starting address of state
    addi $t0, $zero, 4 # Loads address of second column in state
    sw $t4, $t0, 0 # Stores result of key
    # Start computing third column
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t0, $t0, 8 # Address of second column
    addi $t1, $t1, 8 # Address of second column
    lw $t1, $t3, 0 # Stores first column of corresponding roundkey
    addi $t6, $zero, 24 # Loads shift amount for first elements
    srl $t0, $t0, $t6 # Loads first element of column state using shifts
    srl $t1, $t1, $t6 # Loads first element of column roundkey using shifts
    xor $t4, $t0, $t1 # Computes state[column][0] xor roundkey[column][0]
    sll $t4, $t4, $t6 # Shifts result to first pos
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 16 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads second element of column state using shifts
    srl $t1, $t1, $t6 # Loads second element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][1] xor roundkey[column][1]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 8 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads third element of column state using shifts
    srl $t1, $t1, $t6 # Loads third element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][2] xor roundkey[column][2]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][3] xor roundkey[column][3]
    add $t4, $t5, $t3 # Loads result to final register
    addi $t0, $zero, 0x260 # Loads starting address of state
    addi $t0, $zero, 8 # Loads address of second column in state
    sw $t4, $t0, 0 # Stores result of key
    # Start computing fourth column
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t0, $t0, 12 # Address of second column
    addi $t1, $t1, 12 # Address of second column
    lw $t1, $t3, 0 # Stores first column of corresponding roundkey
    addi $t6, $zero, 24 # Loads shift amount for first elements
    srl $t0, $t0, $t6 # Loads first element of column state using shifts
    srl $t1, $t1, $t6 # Loads first element of column roundkey using shifts
    xor $t4, $t0, $t1 # Computes state[column][0] xor roundkey[column][0]
    sll $t4, $t4, $t6 # Shifts result to first pos
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 16 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads second element of column state using shifts
    srl $t1, $t1, $t6 # Loads second element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][1] xor roundkey[column][1]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t6, $zero, 8 # Loads shift amount for second elements
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    srl $t0, $t0, $t6 # Loads third element of column state using shifts
    srl $t1, $t1, $t6 # Loads third element of column roundkey using shifts
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][2] xor roundkey[column][2]
    sll $t5, $t5, $t6 # Shifts result to second pos
    add $t4, $t5, $t3 # Loads result to final register
    lw $t0, $zero, 0x260 # Stores address first column of state to t0
    lw $t1, $t3, 0 # Stores address first column of corresponding roundkey
    addi $t7, $zero, 0xFF # Loads mask for last two bytes
    and $t0, $t0, $t7 # Loads only las two bytes
    and $t1, $t0, $t7 # Loads only las two bytes
    xor $t5, $t0, $t1 # Computes state[column][3] xor roundkey[column][3]
    add $t4, $t5, $t3 # Loads result to final register
    addi $t0, $zero, 0x260 # Loads starting address of state
    addi $t0, $zero, 12 # Loads address of second column in state
    sw $t4, $t0, 0 # Stores result of key
    j round_Loop
    

# Given a text and keyschedule, encrypt a text
encrypt:
    addi $t0, $zero, 1 # Loads counter for rounds
    addi $t1, $zero, 11 # Loads max rounds
    addi $t2, $zero, 0xCC
    sw $t0, $t2, 0
    sw $t1, $t2, 4
    add $t1, $t0, $zero # Copies round to t1
    j addRoundKey

# Generates the round keys
generateRoundKeys:
    addi $t0, $zero, 4 #Loads initial index
    addi $t1, $zero, 44 #Loads final index to compare to
    j generateRoundKey