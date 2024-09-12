import memory
from constants import S_BOX, INV_S_BOX, R_CON, key, text

#Loads key to first 4 columns, vectors of the scheduler
def loadKeyToMemory():
    for i in range(4):
        memory.storeVector("keyschedule", key[(i*4):(i*4 + 4)], i)

def rotateColumn(vector):
    return [vector[1], vector[2], vector[3], vector[0]]

def sbox_convert(value):
    x_index = value // 16
    y_index = value % 16
    replacement = memory.loadValue("S_BOX", x_index, secIndex=y_index)
    return replacement

def substituteBySBox(vector):
    for i in range(4):
        vector[i] = sbox_convert(vector[i])
    return vector

def generateKeySchedule():
    for i in range(4, 44):
        currentVector = memory.loadVector("keyschedule", i-1)
        w4 = memory.loadVector("keyschedule", i-4)
        if i % 4 == 0:
            currentVector = rotateColumn(currentVector)
            currentVector = substituteBySBox(currentVector)
            rcon = memory.loadVector("RCON", (i-1) // 4)
            for i in range(4):
                currentVector[i] = w4[i] ^ currentVector[i] ^ rcon[i]
        else:
            for i in range(4):
                currentVector[i] = w4[i] ^ currentVector[i]
        memory.storeVector("keyschedule", currentVector, i)


    
loadKeyToMemory()
generateKeySchedule()
print("Done")