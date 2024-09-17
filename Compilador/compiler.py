import sys
import codes as cd

def clean_isnt(instruction):
    temp = instruction.split(" ")
    return [i.replace("\n", "").replace(",", "").replace("[", "").replace("]", "") for i in temp]



def get_jump_addr(jumps, tag):
    for j in jumps:
        if j[0] == tag:
            return j[1]
    raise Exception(f"[ERROR in line {total_lines}] Tag: {tag} not found")

def get_first_run_tags(file):
    index = 0 # Línea de código
    decrement = 0 # Porque cada tag hace que las lineas de abajo suban una fila
    first_run = []
    with open(file) as code_file:
        for code_line in code_file:
            f_character = code_line[0]
            if f_character == "_":  # Es un label
                first_run.append((code_line.replace("\n", "").replace(":", ""), 4*(index-decrement))) # *4 por como lo lee la FPGA
                decrement += 1
                index += 1
            elif f_character == "/" or code_line.strip() == "":  # Es un comentario o línea en blanco
                pass
            else:  # Es línea común
                index += 1
    return first_run


def decode(instr):
    instr_split = clean_isnt(instr)
    dec_instr = ""
    print(instr_split)
    # print(instr_split)
    if instr_split[0] not in cd.inst:
        raise Exception(f"[ERROR in line {total_lines}] Instruction {instr_split[0]} does not exist.")
    else:  # Decode instruction
        opcode = cd.inst.get(instr_split[0])  # Gets opcode
        dec_instr += opcode  # adds opcode

        if (opcode == cd.inst.get('STR')): #or (opcode == cd.inst.get('ICOMPI'))):
            dec_instr = f"{dec_instr}0000{cd.regs.get(instr_split[1])}0000"

        elif (opcode == cd.inst.get('MOV')):
            dec_instr = dec_instr + cd.regs.get(instr_split[1])
            binario = bin(int(instr_split[2]))[2:]
            dec_instr = f"{dec_instr}{binario.rjust(8,'0')}"

        elif len(instr_split) > 2:
            dec_instr = dec_instr + cd.regs.get(instr_split[1])
            register2 = cd.regs.get(instr_split[2])

            if register2 is None:
                dec_instr = f"{dec_instr}0000{(bin(int(instr_split[2]))[2::]).zfill(cd.Fillers['INS_FILL'])}"

            else:
                dec_instr = dec_instr + register2
                if len(instr_split) == 4:
                    register3 = cd.regs.get(instr_split[3])
                    if register3 is None:
                        dec_instr = dec_instr + (bin(int(instr_split[3]))[2::]).zfill(cd.Fillers['INS_FILL'])
                    else:
                        dec_instr = dec_instr + register3.zfill(cd.Fillers['INS_FILL'])
                else:
                    dec_instr = dec_instr + ''.zfill(cd.Fillers['INS_FILL'])

        elif opcode == cd.inst['JASON']: #or opcode == cd.inst['JE']:
            dec_instr += bin(get_jump_addr(jump_tags, instr_split[1]))\
                .replace("b", "")\
                .zfill(cd.Fillers['J_FILL'])
    print(dec_instr)
    #print(hex(int(dec_instr, 2))[2::])
    #print("-----")
    print((int(dec_instr, 2)))
    #return hex(int(dec_instr, 2))[2::]
    return str(int(dec_instr, 2))


if __name__ == '__main__':
    code_filename = sys.argv[1]
    asm_file = open(code_filename, "r")

    compiled_asm = open("instructions.mif", "w")
    compiled_asm.write('WIDTH=16;\n')
    compiled_asm.write('DEPTH=%d;\n' % 65536)
    compiled_asm.write('\n')
    compiled_asm.write('ADDRESS_RADIX=UNS;\n')
    compiled_asm.write('DATA_RADIX=UNS;\n')
    compiled_asm.write('\n')
    compiled_asm.write('CONTENT BEGIN\n')
    jump_tags = get_first_run_tags(code_filename)
    line_numbr = 0
    total_lines = 1  # Para errores
    compiled_asm.close()
    counter = 0
    for line in asm_file:
        first_character = line[0]
        if first_character == "_":  # Es un label
            total_lines += 1
            pass
        elif first_character == "/" or line.strip() == "":  # Es un comentario o línea en blanco
            total_lines += 1
            pass
        else:  # Es línea común
            
            compiled_asm = open("instructions.mif", "a")
            compiled_asm.writelines(str(counter)+":"+decode(line) + "\n")  # Decode
            counter += 1
            total_lines += 1
            line_numbr += 1

    compiled_asm.write('END;\n')

    compiled_asm.close()
    asm_file.close()