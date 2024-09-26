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
MULT = 'mul'           #multiplicacion (R)

BETO = 'beq'            #branch equal (I)
BLT = 'blt'             #branch less than (I)
STW = 'sw'              #store word (I)
LDW = 'lw'              #load word (I)
JMP = 'j'               #salto (J)

#vectorial

VSET = 'vset'           #set vectorial (I)
VADD = 'vadd'           #suma vectorial (R)
VMUL = 'vmult'          #multiplicacion vectorial (R)
VDOT = 'vdot'           #producto punto (R)

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
    START: {'type': None, 'opcode': '110010'}, # trad / listo
    END: {'type': None, 'opcode': '110001'}, # trad / listo 
    
    # Escalares

    ADD: {'type': R, 'opcode': '000000', 'funct': '000000'},  #trad / listo
    SUB : {'type': R, 'opcode': '000000', 'funct': '000001'}, #trad / listo
    ADDIMM: {'type': I, 'opcode': '010000'},  #trad / listo
     

    #sin estructura
    SHIFTLL : {'type': R, 'opcode': '000000', 'funct': '000101'}, # trad  / listo
    SHIFTRL: {'type': R, 'opcode': '000000', 'funct': '000111'},  # trad / listo
    XOR: {'type': R, 'opcode': '000000', 'funct': '000010'},  # trad / listo
    AND: {'type': R, 'opcode': '000000', 'funct': '000011'},  #  trad / listo
    MULT: {'type': R, 'opcode': '000000', 'funct': '001000'}, #  trad / listo

    BETO: {'type': I, 'opcode': '100000'}, #trad / listo
    BLT: {'type': I, 'opcode': '100001'}, #trad / listo
    STW: {'type': I, 'opcode': '010001'}, #trad / listo
    LDW: {'type': I, 'opcode': '010010'}, #trad / listo
    JMP: {'type': J, 'opcode': '100010'}, #trad / listo

    # Vectoriales

    VSET: {'type': I, 'opcode': '111111'}, # trad / listo
    VADD: {'type': R, 'opcode': '001100', 'funct': '000000'}, #trad / listo
    VMUL: {'type': R, 'opcode': '001100', 'funct': '000010'}, #trad / listo
    VDOT: {'type': R, 'opcode': '001100', 'funct': '110000'}, # trad / listo

    #sin estructura
    VSHIFTLL: {'type': R, 'opcode': '001100', 'funct': '100000'}, # / listo
    VSHIFTRL: {'type': R, 'opcode': '001100', 'funct': '100000'}, # / listo
    VXOR: {'type': R, 'opcode': '001100', 'funct': '100000'}, #  / listo
    VAND: {'type': R, 'opcode': '001100', 'funct': '100000'}, #  / listo

    VST: {'type': I, 'opcode': '011101'}, #trad / listo
    VLD: {'type': I, 'opcode': '011110'}, #trad / listo

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
    '$t7': '01000', 
    '$t8': '01001', 
    '$t9': '01010', 
    '$t10': '01011', 
    '$t11': '01100', 
    '$t12': '01101', 
    '$t13': '01110', 
    '$t14': '01111', 
    '$v0': '10000', 
    '$v1': '10001', 
    '$v2': '10010', 
    '$v3': '10011', 
    '$v4': '10100', 
    '$v5': '10101', 
    '$v6': '10110', 
    '$v7': '10111', 
    '$': '11000', 
    '$': '11001', 
    '$': '11010', 
    '$': '11011', 
    '$': '11100', 
    '$': '11101', 
    '$': '11110',

}