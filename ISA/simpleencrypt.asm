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

#Loads a vector with the column at t0
#Returns vector on v0
loadColumnVector:
    lw $t1, $t0, 0 # Loads columns as scalar to register t1
    vset $v0, 0 # Loads a vector full of zeroes
    addi $t3, $zero, 0x169 # Loads address for vector to be temporary saved
    vst $v0, $t3, 0 # Stores vector full of zeroes to memory
    sw $t1, $t3, 0 # Saves columns onto vector located at $ADDR
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
    addi $t0, $zero, 0x169 # Computes memory address for v3
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
    add $t0, $t1, $zero # Restores value for t0
    lw $t1, $t0, 4 # Loads state[1]
    lw $t2, $t0, 20 # Loads state[5]
    lw $t3, $t0, 36 # Loads state[9]
    lw $t4, $t0, 52 # Loads state[13]
    sw $t1, $t0, 52 # Stores state[1] at pos 13
    sw $t2, $t0, 4 # Stores state[5] at pos 1
    sw $t3, $t0, 20 # Stores state[9] at pos 5
    sw $t4, $t0, 36 # Stores state[13] at pos 9
    lw $t1, $t0, 8 # Loads state[2]
    lw $t2, $t0, 24 # Loads state[6]
    lw $t3, $t0, 40 # Loads state[10]
    lw $t4, $t0, 56 # Loads state[14]
    sw $t1, $t0, 40 # Stores state[2] at pos 10
    sw $t2, $t0, 56 # Stores state[6] at pos 14
    sw $t3, $t0, 8 # Stores state[10] at pos 2
    sw $t4, $t0, 24 # Stores state[14] at pos 6
    lw $t1, $t0, 12 # Loads state[3]
    lw $t2, $t0, 28 # Loads state[7]
    lw $t3, $t0, 44 # Loads state[11]
    lw $t4, $t0, 60 # Loads state[15]
    sw $t1, $t0, 60 # Stores state[3] at pos 15
    sw $t2, $t0, 12 # Stores state[7] at pos 3
    sw $t3, $t0, 28 # Stores state[11] at pos 7
    sw $t4, $t0, 44 # Stores state[15] at pos 11
    addi $t1, $zero, 10 # Loads 0 to register t1
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
    blt $t0, $t1, round_Loop
    end $zero

# Given a text and keyschedule, encrypt a text
encrypt:
    lw $t0, $zero, 0x485 # Saves state memory address to t0
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