CLI_ERROR_CODE = 2

# types
R = 'R'
I = 'I'
J = 'J'

IMM_SIZE = 16
ADDR_SIZE = 26

#mnemonics l2

START = 'start'
END = 'end'

#scalars

ADD = 'add'             #suma (R)
ADDIMM = 'addi'         #suma inmediato (I)
SUB = 'sub'             #resta (R)

#sin estructura
SHIFTLL = 'sll'         #shift left logical (R)
SHIFTRL = 'srl'         #shift right logical (R)
XOR = 'xor'             #xor logico (R)
AND = 'and'             #and logico (R)
MULT = 'mult'           #multiplicacion (R)

BETO = 'beq'            #branch equal (I)
BLT = 'blt'             #branch less than (I)
STW = 'sw'              #store word (I)
LDW = 'lw'              #load word (I)
JMP = 'j'               #salto (J)

#vectorial

VSET = 'vset'           #set vectorial (I)
VADD = 'vadd'           #suma vectorial (R)
VMUL = 'vmult'          #multiplicacion vectorial (R)
VSUM = 'vsum'           #sumatoria vectorial (R)

#sin estructura
VSHIFTLL = 'vsll'       #shift left logical vectorial (R)
VSHIFTRL = 'vsrl'       #shift right logical vectorial (R)
VXOR = 'vxor'           #xor logico vectorial (R)
VAND = 'vand'           #and logico vectorial (R)

VST = 'vst'             #store vectorial (I)
VLD = 'vld'             #load vectorial (I)


isa = {
    #con listo me refiero a que estan referenciados en interpreter.py 
    # pero no necesariamente listos a nivel de funcionalidad
    # Control
    START: {'type': None, 'opcode': '110010'},
    END: {'type': None, 'opcode': '110001'},
    
    # Escalares

    ADD: {'type': R, 'opcode': '000000', 'funct': '000000'},  #traducido
    SUB : {'type': R, 'opcode': '000000', 'funct': '000001'}, #trad
    ADDIMM: {'type': I, 'opcode': '010000'},  #trad
     

    #sin estructura
    SHIFTLL : {'type': R, 'opcode': '000000', 'funct': '100000'},  
    SHIFTRL: {'type': R, 'opcode': '000000', 'funct': '100000'},  
    XOR: {'type': R, 'opcode': '000000', 'funct': '100000'},  
    AND: {'type': R, 'opcode': '000000', 'funct': '100000'},  
    MULT: {'type': R, 'opcode': '000000', 'funct': '100000'},  

    BETO: {'type': I, 'opcode': '100000'}, #trad 
    BLT: {'type': I, 'opcode': '100001'}, #trad
    STW: {'type': I, 'opcode': '010001'}, #trad
    LDW: {'type': I, 'opcode': '010010'}, #trad
    JMP: {'type': J, 'opcode': '100010'}, #trad

    # Vectoriales

    VSET: {'type': I, 'opcode': '010100', 'funct': '100000'},
    VADD: {'type': R, 'opcode': '001100', 'funct': '000000'}, #trad
    VMUL: {'type': R, 'opcode': '001100', 'funct': '000010'}, #trad
    VSUM: {'type': R, 'opcode': '010100', 'funct': '100000'}, 

    #sin estructura
    VSHIFTLL: {'type': R, 'opcode': '010100', 'funct': '100000'},
    VSHIFTRL: {'type': R, 'opcode': '010100', 'funct': '100000'},
    VXOR: {'type': R, 'opcode': '010100', 'funct': '100000'},
    VAND: {'type': R, 'opcode': '010100', 'funct': '100000'},

    VST: {'type': I, 'opcode': '011101'}, #trad
    VLD: {'type': I, 'opcode': '011110'}, #trad

}

#Registers names
registers = {
    '$zero': '00000',
    '$t0': '00001', 
    '$t1': '00010', 
    '$t2': '00011', 
    '$t3': '00100', 
    '$t4': '00101', 
    '$t5': '00110', 
    '$t6': '00111', 
    '$t8': '01000', 
    '$t9': '01001', 
    '$t10': '01010', 
    '$t11': '01011', 
    '$t12': '01100', 
    '$t13': '01101', 
    '$t14': '01110', 
    '$v0': '10000', 
    '$v1': '10001', 
    '$v2': '10010', 
    '$v3': '10011', 
    '$v4': '10100', 
    '$v5': '10101', 
    '$v6': '10110', 
    '$v7': '10111', 
    '$stall': '01000', 
    '$cpi': '01001', 
    '$ac': '01010', 
    '$mem': '01011', 
    '$': '01100', 
    '$': '01101', 
    '$': '01110', 
    '$': '01111',

}