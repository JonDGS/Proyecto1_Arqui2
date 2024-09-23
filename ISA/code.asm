; Rotate values from index to index + 4
rotateColumn:
    lw $t1, t0, -4 #Loads w-1[0] to $t0
    lw $t2, t0, -3 #Loads w-1[1] to $t1
    lw $t3, t0, -2 #Loads w-1[2] to $t2
    lw $t4, t0, -1 #Loads w-1[3] to $t3
    sw $t1, $t0, 3 #Stores w-1[0] to last
    sw $t2, $t0, 0 #Stores w-1[1] to first
    sw $t3, $t0, 1 #Stores w-1[2] to second
    sw $t4, $t0, 2 #Stores w-1[3] to third
    addi $pc, $t6, 4 #Returns to caller function

;;Loads a vector with the column at t0
;;Returns vector on v0
loadColumnVector:
    lw $t1, $t0, 0 # Loads columns as scalar to register t1
    vset $v0, 0 # Loads a vector full of zeroes
    addi $t3, $zero, $ADDR *# Loads address for vector to be temporary saved
    vst $v0, $t3 # Stores vector full of zeroes to memory
    sw $t1, $t3, 0 # Saves columns onto vector located at $ADDR
    vld $v0, $t3 # Loads vector back to register v0
    #return to callee *

;Given a memory index at t0, replace its value with
; the corresponding value in the S_BOX
subValueAtIndex:
    lw $t1, $t0, 0 # Loads value at memory address
    srl $t2, $t1, 4 # Shifts value at t1 to get t1 // 16
    addi $t3, $zero, 0xF # Loads 0xF mask to t3
    and $t3, $t1, $t3 # Computes t1 % 16 using mask
    addi $t4, $zero, 15 # Loads row amounts for S_BOX
    mul $t2, $t2 # Computes row * rowNumbers for S_BOX
    add $t2, $t2, $t3 # Computes t2 + t3 for index in S_BOX
    lw $t2, $t1, 0 # loads value to replace
    sw $t2, $t0, 0 # Stores value to index in memory
    addi $pc, $t6, 4 #Returns to caller function

subValuesEnd:
    addi $pc, $t6, 4 # Returns to callee

;Assumes t0 holds address of column
;Assumes t1 holds the counter for traversing the column
subValuesInColumn:
    addi $t3, $zero, 4 # Loads a 4 to register t3
    beq $t2, $t3, subValuesEnd # Given index 4 reached, jump to end of subBytes
    addi $t7, $pc, 4 # Stores caller pc at register t7
    j subValueAtIndex # Jumps to function subValueAtIndex
    addi $t1, $t1, 1 # Increases the counter
    j subValuesInColumn # Recursively calls function

;Assume the index for the RCON column is at t0
getrconbyindex:
    lw $t1, $t0, 0 # Loads RCON value at t0
    vset $v0, $zero # Loads v1 with a vector full of zeroes
    addi $t3, $zero, $ADDR *
    vst $v0, $t3, 0 # Sets a sector of memory to full zeroes
    sw $t1, $t3, 0 # Loads RCON value a the beginning of v0 in memory
    vld $v0, $t3, 0 # Loads RCON vector to v0
    addi $pc, $t6, 4

;Computes the value for w_{i} if the index
;is a multiple of 4
grk_multiple_case:
    addi $t5, $zero, 0x100 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    sw $t6, $t5, 8 # Stores pc of callee at mem address $t5 + 8
    lw $t1, $t0, -4 # Loads previous column in current index (copy w{-1} to t1)
    sw $t1, $t0, 0 # Copies the contents of w{-1} to w{1}
    addi $t6, $pc, 4 # Loads pc to t6
    j rotateColumn #Rotate column
    lw $t0, $t5, 0 # Restores current index for subValue stage
    addi $t1, $zero, $zero # Loads a 0 to register t1
    addi $t6, $pc, 4 # Loads pc to t6
    j subValuesInColumn # SubBytes at column in index t0
    addi $t6, $pc, 4 # Loads pc to t6
    j getrconbyindex # Gets an RCON vector an loads it to v0
    vset $v1, 0 # Zeroes v1
    vadd $v1, $v0, $v1 # Copy contents of v0 to v1
    addi $t0, $t0, -4 # Gets index for w_{-4}
    addi $t6, $pc, 4 # Loads pc to t6
    j loadColumnVector # Computes w_{-4} to v0
    vset $v2, 0 # Loads v3 with zeroes
    vadd $v2, $v0, $v2 # Copy v0 value to v2
    addi $t0, $t0, 4 # Restore t0 to original value
    addi $t6, $pc, 4 # Loads pc to t6
    j loadColumnVector # Computes w{i} to v0
    vxor $v3, $v2, $v0 # Computes v0 xor v2 (w-4 xor wi)
    vxor $v3, $v3, $v1 # Computes v3 xor v1 (v3 xor rcon)
    addi $t0, $zero, $ADDR * # Computes memory address for v3
    vst $v3, $t0, 0 # Store v3 in memory
    lw $t2, $t0, 0 # Loads first column in v3 which is on memory
    lw $t0, $t5, 0 # Restores original value of t0
    lw $t1, $t5, 4 # Restores original value of t1
    lw $t6, $t5, 8 # Restores original value of t6
    sw $t2, $t0, 0 # Stores compute for round key
    addi $pc, $t6, 8 # Returns callee and skips default case

grk_default_case:
    addi $t5, $zero, 0x100 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    sw $t6, $t5, 8 # Stores pc of callee at mem address $t5 + 8
    lw $t1, $t0, -4 # Loads previous column in current index (copy w{-1} to t1)
    sw $t1, $t0, 0 # Copies the contents of w{-1} to w{i}
    addi $t6, $pc, 4 # Loads pc to t6
    j loadColumnVector # Loads w{-1} to v0
    vset $v1, 0 # Zeroes v1
    vadd $v1, $v0, $v1 # Copies contents of v0 to v1
    add $t0, $t0, -16 # Computes index for w{i-4}
    addi $t6, $pc, 4 # Loads pc to t6
    j loadColumnVector # Loads w{i-4} to v0
    vxor $v0, $v0, $v1 # Computes v0 xor v1 (w-4 xor w-1)
    addi $t0, $zero, $ADDR * # Computes memory address for v3
    vst $v0, $t0, 0 # Store v0 in memory
    lw $t2, $t0, 0 # Loads first column in v0 which is on memory
    lw $t0, $t5, 0 # Restores original value of t0
    lw $t1, $t5, 4 # Restores original value of t1
    lw $t6, $t5, 8 # Restores original value of t6
    sw $t2, $t0, 0 # Stores compute for round key
    addi $pc, $t6, 4 # Returns callee
    


;Generates a key for a single round
;Uses t1 as main index
generateRoundKey:
    addi $t2, $zero, 3 #Loads 3 to temporal register for modulo 4
    and, $t2, $t0, $t2 #Loads modulo of index for base 4
    add $t6, $pc, $zero #Loads pc to t6
    beq $zero, $t2, grk_multiple_case
    j grk_default_case
    addi $t0, $t0, 1 #Increases index by 1
    j generateRoundKeysAux



roundLoop:
    


;;Given a text and keyschedule, encrypt a text
encrypt:
    lw $t0, $zero, $ADDR * # Saves state memory address to t0
    vld $v0, $t0 # Loads state as a vector to v0
    lw $t0 $zero, $ADDR * # Saves keySchedule address
    addi $t0, $t0, 16 $ # Computes address for first round in key schedule
    vld $v1, $t0 # Loads round 0 key to v1
    vxor $v1, $v0, $v1 # Operates v0 xor v1 {state(text) xor roundkey(0)}
    addi $t0, $zero, 1 # Loads counter for rounds
    addi $t1, $zero, 11 # Loads max rounds
    add $t6, $pc, $zero #Loads pc to t6
    j round_loop


;If index 44 has been reached
;Continue the algorithm
generateRoundKeysAux:
    blt $t0, $t1, generateRoundKey #While keyschedule not complete, continue generating
    j encrypt


;Generates the round keys
generateRoundKeys:
    addi t0, $zero, 4 #Loads initial index
    addi t1, $zero, 44 #Loads final index to compare to
    j generateRoundKeysAux
    
