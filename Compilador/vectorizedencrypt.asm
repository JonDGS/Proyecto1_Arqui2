start $zero
j generateRoundKeys

# Address
# RCON: 0xB8
# DATA: 0x844
# Text: 0xE88
# Matrix: 0xE4


# Rotate values from index to index + 4
# CHECK ADDRESSES BEFORE DEPLOYING
rotateColumn:
    lw $t0, $t0, 0 
    addi $t5, $zero, 0xFF
    addi $t6, $zero, 24
    srl $t1, $t0, $t6 # Loads column[0]
    addi $t6, $zero, 16
    srl $t2, $t0, $t6 # Loads column[1]
    and $t2, $t0, $t5 # Loads column[1] after mask
    addi $t6, $zero, 8
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

#Loads a vector with the column at t0
#Returns vector on v0
loadColumnVector:
    lw $t1, $t0, 0 # Loads columns as scalar to register t1
    vset $v0, 0 # Loads a vector full of zeroes
    addi $t3, $zero, 0x310 # Loads address for vector to be temporary saved
    vst $v0, $t3, 0 # Stores vector full of zeroes to memory
    sw $t1, $t3, 0 # Saves columns onto vector located at 0x310
    vld $v0, $t3, 0 # Loads vector back to register v0
    beq $t14, $zero, grk_multiple_case4 # Assumes callee is grk_multiple_case3
    addi $t13, $zero, 1 # Loads a 1 to t13
    beq $t14, $t13, grk_multiple_case5 # Assumes callee is grk_multiple_case4
    addi $t13, $zero, 2 # Loads a 2 to t13
    beq $t14, $t13, grk_default_case1 # Assumes calle is grk_default_case
    addi $t13, $zero, 3 # Loads a 3 to t13
    beq $t14, $t13, grk_default_case2 # Assumes calle is grk_default_case1

#Given a memory index at t0, replace its value with
# the corresponding value in the S_BOX
subValueAtIndex:
    lw $t1, $t0, 0 # Loads value at memory address
    addi $t9, $t9, 4
    srl $t2, $t1, $t9 # Shifts value at t1 to get t1 // 16
    addi $t3, $zero, 0xF # Loads 0xF mask to t3
    and $t3, $t1, $t3 # Computes t1 % 16 using mask
    addi $t4, $zero, 15 # Loads row amounts for S_BOX
    mul $t2, $t2, $t4 # Computes row * rowNumbers for S_BOX
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
    vset $v0, 0 # Loads v1 with a vector full of zeroes
    addi $t4, $zero, 0x310 # Assign address to memory for vectory
    vst $v0, $t4, 0 # Sets a sector of memory to full zeroes
    addi $t2, $zero, 2 # Shift amount for integer division of 4
    srl $t1, $t1, $t2 # value //4
    addi $t2, $zero, 1 # Substract 1
    sub $t1, $t1, $t2 # Substract 1 from t1
    addi $t2, $zero, 4 # Multiply by 4
    mul $t1, $t1, $t2 # Computes RCON offset
    addi $t1, $t1, 0xB8 # RCON address plus offset
    lw $t3, $t1, 0 # Loads RCON vector to register t3
    sw $t3, $t4, 0 # Loads RCON in first value of vector
    vld $v1, $t4, 0 # Loads RCON as a vector
    j grk_multiple_case3

# Computes the value for w_{i} if the index
# is a multiple of 4
grk_multiple_case:
    addi $t5, $zero, 0x844 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    sw $t6, $t5, 8 # Stores pc of callee at mem address $t5 + 8
    lw $t1, $t0, -4 # Loads previous column in current index (copy w{-1} to t1)
    sw $t1, $t0, 0 # Copies the contents of w{-1} to w{1}
    j rotateColumn #Rotate column

grk_multiple_case1:
    lw $t0, $t5, 0 # Restores current index for subValue stage
    add $t1, $zero, $zero # Loads a 0 to register t1
    addi $t14, $zero, 0 # Loads condition
    j subValuesInColumn # SubBytes at column in index t0

grk_multiple_case3:
    addi $t0, $t0, -4 # Gets index for w_{-4}
    addi $t14, $zero, 0 # Loads 0 to t14
    j loadColumnVector # Computes w_{-4} to v0

grk_multiple_case4:
    vset $v2, 0 # Loads v3 with zeroes
    vadd $v2, $v0, $v2 # Copy v0 value to v2
    addi $t0, $t0, 4 # Restore t0 to original value
    addi $t14, $zero, 1 # Loads 1 to t14
    j loadColumnVector # Computes w{i} to v0

grk_multiple_case5:
    vxor $v3, $v2, $v0 # Computes v0 xor v2 (w-4 xor wi)
    vxor $v3, $v3, $v1 # Computes v3 xor v1 (v3 xor rcon)
    addi $t0, $zero, 0x310 # Computes memory address for v3
    vst $v3, $t0, 0 # Store v3 in memory
    lw $t2, $t0, 0 # Loads first column in v3 which is on memory
    lw $t0, $t5, 0 # Restores original value of t0
    lw $t1, $t5, 4 # Restores original value of t1
    lw $t6, $t5, 8 # Restores original value of t6
    sw $t2, $t0, 0 # Stores compute for round key
    addi $t0, $t0, 1 # Increases index by 1
    j generateRoundKey # Returns to generateRoundKey

grk_default_case:
    addi $t5, $zero, 0x844 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    sw $t6, $t5, 8 # Stores pc of callee at mem address $t5 + 8
    lw $t1, $t0, -4 # Loads previous column in current index (copy w{-1} to t1)
    sw $t1, $t0, 0 # Copies the contents of w{-1} to w{i}
    addi $t14, $zero, 2 # Loads 2 to t14
    j loadColumnVector # Loads w{-1} to v0

grk_default_case1:
    vset $v1, 0 # Zeroes v1
    vadd $v1, $v0, $v1 # Copies contents of v0 to v1
    addi $t0, $t0, -16 # Computes index for w{i-4}
    addi $t14, $zero, 3 # Loads 3 to t14
    j loadColumnVector # Loads w{i-4} to v0

grk_default_case2:
    vxor $v0, $v0, $v1 # Computes v0 xor v1 (w-4 xor w-1)
    addi $t0, $zero, 0x310 # Computes memory address for v3
    vst $v0, $t0, 0 # Store v0 in memory
    lw $t2, $t0, 0 # Loads first column in v0 which is on memory
    lw $t0, $t5, 0 # Restores original value of t0
    lw $t1, $t5, 4 # Restores original value of t1
    lw $t6, $t5, 8 # Restores original value of t6
    sw $t2, $t0, 0 # Stores compute for round key
    addi $t0, $t0, 1 #Increases index by 1
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
    addi $t1, $zero, 0xE4 # Loads address for matrix
    vld $v0, $t1, 0 # Loads matrix to register v1
    vset $v1, 0 # Zeroes v1
    addi $t2, $zero, 0x310 # Loads address in memory to be used temporarily
    vst $v1, $t2, 0 # Stores zeroed vector to memory
    lw $t3, $t0, 0 # Loads current column to register t3
    sw $t3, $t2, 0 # Stores current column to memory
    vld $v1, $t2, 0 # Brings vector of current column and zeroes
    vdot $v1, $v0, $v1 # Matrix multiplication of v0 and v1
    vst $v1, $t2, 0 # Stores resulting vector in memory
    lw $t3, $t2, 0 # Loads result to t3
    sw $t3, $t0, 0 # Replaces current column in memory
    j round_Loop5


# Assumes the index for round is at t0
round_Loop:
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
    addi $t8, $zero, 0x844 # Loads initial address of state
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
    addi $t3, $zero, 0x844 # First address in DATA
    lw $t0, $t3, 0 # Restores value of index round
    lw $t1, $t3, 4 # Restores value of max rounds
    blt $t0, $t1, mixColumns # If round less than 10, mix columns
    j round_Loop5

round_Loop5:
    addi $t2, $zero, 16 # Loads 16 to memory
    mul $t2, $t2, $t0 # Computes round key address
    vld $v1, $t0, 0 # Loads round key to v0
    addi $t4, $zero, 0xE88 # Loads memory address of state
    vld $v2, $t4, 0 # Loads state to register v2
    vxor $v2, $v2, $v1 # Computes roundkey xor state
    addi $t0, $t0, 1 # Increases round by 1
    blt $t0, $t1, round_Loop
    end $zero

# Given a text and keyschedule, encrypt a text
encrypt:
    lw $t0, $zero, 0xE88 # Saves state memory address to t0
    vld $v0, $t0, 0 # Loads state as a vector to v0
    lw $t0 $zero, 0x0 # Saves keySchedule address
    addi $t0, $t0, 16 # Computes address for first round in key schedule
    vld $v1, $t0, 0 # Loads round 0 key to v1
    vxor $v1, $v0, $v1 # Operates v0 xor v1 {state(text) xor roundkey(0)}
    addi $t0, $zero, 1 # Loads counter for rounds
    addi $t1, $zero, 11 # Loads max rounds
    j round_Loop

# Generates the round keys
generateRoundKeys:
    addi $t0, $zero, 4 #Loads initial index
    addi $t1, $zero, 44 #Loads final index to compare to
    j generateRoundKey