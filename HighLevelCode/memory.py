import constants

registers = [
    0 for i in range(10)
]

vregisters = [
    [0 for i in range (32)] for i in range(10)
]

keyschedule = [
    [0 for i in range(4)] for i in range(44)
]

state = [
    0 for _ in range(16)
]

#Loads a value based on an index from the various values in memory
def loadValue(case, index, secIndex=4):
    match case:
        case "S_BOX":
            return constants.S_BOX[index][secIndex]
        case "INV_BOX":
            return constants.INV_S_BOX[index][secIndex]
        case "RCON":
            return constants.R_CON[index][secIndex]
        case "keyschedule":
            return keyschedule[index][secIndex]
        case "text":
            return constants.text[index]
        case "encryptedtext":
            return constants.encryptedtext[index]
        case "state":
            return state[index]
        case _:
            return ValueError
        
#Loads a vector register from a constant in memory
def loadVector(case, index=0, secIndex=0, terciaryIndex=32):
    match case:
        case "S_BOX":
            return constants.S_BOX[index][secIndex:terciaryIndex]
        case "INV_BOX":
            return constants.INV_S_BOX[index][secIndex:terciaryIndex]
        case "RCON":
            return constants.R_CON[index]
        case "keyschedule":
            return keyschedule[index][secIndex:terciaryIndex]
        case "text":
            return constants.text[index:secIndex]
        case "encryptedtext":
            return constants.encryptedtext[index:secIndex]
        case "state":
            return state
        case _:
            return ValueError
        
#Stores a value or vector of values based on an index from the various values in memory
def storeValue(type, value, index, secIndex=0):
    match type:
        case "register":
            registers[index] = value
        case "vregister":
            vregisters[index][secIndex] = value
        case "keyschedule":
            keyschedule[index][secIndex] = value
        case "state":
            state[index]
        case _:
            return ValueError
        
#Stores a value or vector of values based on an index from the various values in memory
def storeVector(type, vector, index):
    match type:
        case "register":
            registers[index] = vector
        case "vregister":
            vregisters[index] = vector
        case "keyschedule":
            keyschedule[index] = vector
        case "state":
            state = vector
        case _:
            return ValueError
        
def restartMemory():
    global registers, vregisters, keyschedule, state
    registers = [
        0 for i in range(10)
    ]

    vregisters = [
        [0 for i in range (32)] for i in range(10)
    ]

    keyschedule = [
        [0 for i in range(4)] for i in range(44)
    ]

    state = [
        0 for _ in range(16)
    ]