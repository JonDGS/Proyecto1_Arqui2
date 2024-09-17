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

ADD = 'add'             #suma
ADDIMM = 'addi'         #suma inmediato
MULT = 'mult'           #multiplicacion
MULTIMM = 'multi'       #multiplicacion inmediato
EDIV = 'dive'           #division entera
MOD = 'mod'             #modulo
LOAD = 'loadw'          #load
LDIMM = 'ldi'           #load inmediato
STORE = 'storew'        #store
CMP = 'comp'            #comparar
NOP = 'choco'           #stall
BETO = 'beto'           #branch equal to
JMP = 'jump'            #salto

#vectorial
VADD = 'vecadd'         #suma vectorial
VMUL = 'vecmult'        #multiplicacion vectorial
VXOR = 'vecxor'         #xor vectorial
BOX_REPLACE = 'box_r'   #reemplaza un un elemento del vector por su equivalente en el SBOX
VLOAD = 'vecld'         #load vectorial
VLDIMM = 'vecldi'       #load inmediato vectorial
VSTR = 'vecstr'         #store vectorial

isa = {
    #con listo me refiero a que estan referenciados en interpreter.py 
    # pero no necesariamente listos a nivel de funcionalidad
    # Control
    START: {'type': None, 'opcode': '110010'},
    END: {'type': None, 'opcode': '110001'},
    
    # Escalares
    ADD: {'type': R, 'opcode': '000000', 'funct': '100000'},  #listo
    ADDIMM: {'type': I, 'opcode': '001000'}, #listo
    MULT: {'type': R, 'opcode': '000000', 'funct': '011000'}, #listo
    MULTIMM: {'type': I, 'opcode': '001001'}, #listo
    EDIV: {'type': R, 'opcode': '000000', 'funct': '011010'}, #listo
    MOD: {'type': R, 'opcode': '001010'}, #listo
    LOAD: {'type': I , 'opcode': '100011'},
    LDIMM: {'type': I, 'opcode': '001011'}, #listo
    STORE: {'type': I, 'opcode': '101011'},
    CMP: {'type': I, 'opcode': '000111'},
    NOP: {'type': None, 'opcode': '000000'},  # tomado como no-operation
    BETO: {'type': I, 'opcode': '000100'}, #listo
    JMP: {'type': J, 'opcode': '000010'}, #listo

    # Vectoriales
    VADD: {'type': R, 'opcode': '010100', 'funct': '100000'}, #listo
    VMUL: {'type': R, 'opcode': '010100', 'funct': '000010'}, #listo
    VXOR: {'type': R, 'opcode': '010100', 'funct': '001010'}, #listo
    BOX_REPLACE: {'type': R, 'opcode': '010101', 'funct': '001011'}, #listo pero no implementado
    VLOAD: {'type': I, 'opcode': '101110'},
    VLDIMM: {'type': I, 'opcode': '001100'}, #listo
    VSTR: {'type': I, 'opcode': '101111'},
}

#Registers names
registers = {
    '$zero': '00000',
    '$a0': '00001', 
    '$a1': '00010', 
    '$sp': '00011', 
    '$cbh': '00100', 
    '$cbt': '00101', 
    '$b0': '00110', 
    '$b1': '00111', 
    '$b2': '01000', 
    '$b3': '01001', 
    '$b4': '01010', 
    '$b5': '01011', 
    '$b6': '01100', 
    '$b7': '01101', 
    '$b8': '01110', 
    '$b9': '01111',
    '$v0': '10000', 
    '$v1': '10001', 
    '$v2': '10010', 
    '$v3': '10011', 
    '$v4': '10100', 
    '$v5': '10101', 
    '$v6': '10110', 
    '$v7': '10111', 
    '$': '01000', 
    '$': '01001', 
    '$': '01010', 
    '$': '01011', 
    '$': '01100', 
    '$': '01101', 
    '$': '01110', 
    '$': '01111',

}