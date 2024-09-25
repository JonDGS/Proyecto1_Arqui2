import memory
from constants import S_BOX, INV_S_BOX, R_CON, key, text, RGF_matrix

#Loads key to first 4 columns, vectors of the scheduler
def loadKeyToMemory():
    for i in range(4):
        memory.storeVector("keyschedule", key[(i*4):(i*4 + 4)], i)

#Reorganizes the values in a column by placing the first element
#logically shifting it by 1 to the left
def rotateColumn(vector):
    return [vector[1], vector[2], vector[3], vector[0]]

#Convert a value to its equivalent in the SBOX
def sbox_convert(value):
    x_index = value // 16
    y_index = value % 16
    replacement = memory.loadValue("S_BOX", x_index, secIndex=y_index)
    return replacement

#Converts the values in a vector by its values
#in the SBox
def substituteBySBox(vector):
    for i in range(4):
        vector[i] = sbox_convert(vector[i])
    return vector

#Generates a key scheduler and loads it onto memory
def generateKeySchedule():
    for i in range(4, 44):
        currentVector = memory.loadVector("keyschedule", i-1)
        w4 = memory.loadVector("keyschedule", i-4)
        if i % 4 == 0:
            currentVector = rotateColumn(currentVector)
            currentVector = substituteBySBox(currentVector)
            rcon = memory.loadVector("RCON", (i-1) // 4)
            for j in range(4):
                currentVector[j] = w4[j] ^ currentVector[j] ^ rcon[j]
        else:
            for j in range(4):
                currentVector[j] = w4[j] ^ currentVector[j]
        memory.storeVector("keyschedule", currentVector, i)

#Adds the round key to a given state
def addRoundKey(state, round):
    for i in range(4):
        for j in range(4):
            state[j*4 + i] = state[j*4 + i] ^ memory.keyschedule[j + round*4][i]
    return state

#Substitutes the values on a state
def subBytes(state):
    for i in range(4):
        for j in range(4):
            state[i*4 + j] = sbox_convert(state[i*4 + j])
    return state

#Rotate a single row in a state
def rotateRow(state, index):
    values = [state[index], state[index+4], state[index+8], state[index+12]]
    state[index] = values[1]
    state[index+4] = values[2]
    state[index+8] = values[3]
    state[index+12] = values[0]
    return state

#Rotates the rows in state where each row is shifted by
#n where n is the index of said row in the state
def shiftRows(state):
    for i in range(4):
        for _ in range(i):
            state = rotateRow(state, i)
    return state

#Multiplies a given matrix by a vector
def matrixVectorMultiplication(matrixA, vectorA):
    vectorB = [0 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            vectorB[i] += (matrixA[j][i]*vectorA[j])
        vectorB[i] = vectorB[i] % 255
    return vectorB

#Mixes the columns in a given state
def mixColumns(state):
    for i in range(4):
        state[i*4:i*4+4] = matrixVectorMultiplication(RGF_matrix, state[i*4: i*4+4])
    return state

#Using the AES algorithm with no padding encrypts a text
def aesEncrypt():
    loadKeyToMemory()
    generateKeySchedule()
    memory.state = text
    memory.state = addRoundKey(memory.state, 0)
    for round in range(1, 11):
        memory.state = subBytes(memory.state)
        memory.state = shiftRows(memory.state)
        if round >= 10:
            memory.state = mixColumns(memory.state)
        memory.state = addRoundKey(memory.state, round)
