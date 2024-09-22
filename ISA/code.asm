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
    addi $pc, $pc, 4 #Returns to caller function

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
    addi $pc, $pc, 4 #Returns to caller function

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
    vset $v0, $t1 # Load v0 with a vector full of t1
    vset $v1, $zero # Loads v1 with a vector full of zeroes
    addi $t3, $zero, $ADDR *
    vst $v1, $t3, 0 # Sets a sector of memory to full zeroes
    addi $t3, $zero, 0xFF # Loads 0xFF to t3
    addi $t4, $t3, $t0 # Loads index for mask value
    sw $t3, $t4, 0 # Stores mask value on memory
    vld $v1, $ADDR, 0 # Loads mask to v1
    vand $v0, $v1, $v0 # Loads the correct vector to v0

;Computes the value for w_{i} if the index
;is a multiple of 4
grk_multiple_case:
    addi $t5, $zero, 0x100 # Sets an initial mem address to temp save indexes
    sw $t0, $t5, 0 # Stores current index at mem address $t5
    sw $t1, $t5, 4 # Stores final index at mem address $t5 + 4
    add $t0, $zero, t0 # Loads the current index to t0
    addi $t6, $pc, 4 # Loads pc to t6
    j rotateColumn #Rotate column
    lw $t0, $t5, 0 # Restores current index for subValue stage
    addi $t1, $zero, $zero # Loads a 0 to register t1
    addi $t6, $pc, 4 # Loads pc to t6
    j subValuesInColumn
    #next instruc
    



;Generates a key for a single round
;Uses r1 as main index
generateRoundKey:
    addi $t2, $zero, 3 #Loads 3 to temporal register
    and, $t2, t0, t2 #Loads modulo of index for base 4
    beq $zero, $t2, grk_multiple_case
    addi $t2, $t0, -1 #Loads index for w_i_{-1}
    vld $v0, $t2, 0 #Loads w_i_{-1} to vr1
    addi $t3, $t0, -4 #Loads index for w_i_{-4}
    vld $v1, $t3, 0 #Loads w_i_{-1} to vr2
    addi $t0, $t0, 1 #Increases index by 1
    j generateRoundKeysAux

;If index 44 has been reached
;Continue the algorithm
generateRoundKeysAux:
    blt $t0, $t1, generateRoundKey #While keyschedule not complete, continue generating
    j XXX


;Generates the round keys
generateRoundKeys:
    addi t0, $zero, 4 #Loads initial index
    addi t1, $zero, 44 #Loads final index to compare to
    j generateRoundKeysAux
    
