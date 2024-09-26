import memory
import numpy
from constants import key, encryptedtext, Inv_RGF_matrix

#Loads key to first 4 columns, vectors of the scheduler
def loadKeyToMemory():
    for i in range(4):
        memory.storeVector("keyschedule", numpy.array(key[(i*4):(i*4 + 4)]), i)

#Convert a value to its equivalent in the SBOX
def sbox_convert(value):
    x_index = value // 16
    y_index = value % 16
    replacement = memory.loadValue("S_BOX", x_index, secIndex=y_index)
    return replacement

#Convert a value to its equivalent in the SBOX
def invsbox_convert(value):
    x_index = value // 16
    y_index = value % 16
    replacement = memory.loadValue("INV_BOX", x_index, secIndex=y_index)
    return replacement

#Converts the values in a vector by its values
#in the SBox
def substituteBySBox(vector):
    for i in range(4):
        vector[i] = sbox_convert(vector[i])
    return vector

#Converts the values in a vector by its values
#in the SBox
def substituteByInvSBox(vector):
    for i in range(4):
        vector[i] = invsbox_convert(vector[i])
    return vector

#Generates a key scheduler and loads it onto memory
def generateKeySchedule():
    for i in range(4, 44):
        currentVector = numpy.array(memory.loadVector("keyschedule", i-1))
        w4 = memory.loadVector("keyschedule", i-4)
        if i % 4 == 0:
            currentVector = numpy.roll(currentVector, -1)
            currentVector = substituteBySBox(currentVector)
            rcon = memory.loadVector("RCON", (i-1) // 4)
            midVector = numpy.bitwise_xor(numpy.array(w4), currentVector)
            currentVector = numpy.bitwise_xor(midVector, numpy.array(rcon))
        else:
            currentVector = numpy.bitwise_xor(numpy.array(w4), currentVector)
        memory.storeVector("keyschedule", currentVector, i)

#Adds the round key to a given state
def addRoundKey(state, round):
    for i in range(4):
        keyScheduleColumn = numpy.array(memory.keyschedule[round*4 + i])
        state[(i*4):(i*4+4)] = numpy.bitwise_xor(numpy.array(state[(i*4):(i*4+4)]),
                                                        keyScheduleColumn).tolist()
    return state

#Substitutes the values on a state
def subBytes(state):
    for i in range(4):
        for j in range(4):
            state[i*4 + j] = sbox_convert(state[i*4 + j])
    return state

#Substitutes the values on a state
def InvsubBytes(state):
    for i in range(4):
        for j in range(4):
            state[i*4 + j] = invsbox_convert(state[i*4 + j])
    return state

#Rotate a single row in a state
def InvrotateRow(state, index):
    values = [state[index], state[index+4], state[index+8], state[index+12]]
    state[index] = values[3]
    state[index+4] = values[0]
    state[index+8] = values[1]
    state[index+12] = values[2]
    return state


#Rotates the rows in state where each row is shifted by
#n where n is the index of said row in the state
def InvshiftRows(state):
    for i in range(4):
        for _ in range(i):
            state = InvrotateRow(state, i)
    return state

#Multiplies a given matrix by a vector
def matrixVectorMultiplication(matrixA, vectorA):
    tmatrix = numpy.transpose(matrixA)
    vectorB = numpy.dot(tmatrix, vectorA) % 255
    return vectorB

#Mixes the columns in a given state
def mixColumns(state):
    for i in range(4):
        state[i*4:i*4+4] = matrixVectorMultiplication(Inv_RGF_matrix, state[i*4: i*4+4])
    return state

#Using the AES algorithm with no padding encrypts a text
def aesDecrypt():
    loadKeyToMemory()
    generateKeySchedule()
    memory.state = encryptedtext
    memory.state = addRoundKey(memory.state, 0)
    for round in range(1, 11):
        memory.state = InvsubBytes(memory.state)
        memory.state = InvshiftRows(memory.state)
        if round >= 10:
            memory.state = mixColumns(memory.state)
        memory.state = addRoundKey(memory.state, round)
