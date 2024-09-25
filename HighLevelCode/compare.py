import time
import simpleencrypt, simpledecrypt, vectorizedencrypt, vectorizeddecrypt
import memory

def compare_functions(funcA, funcB, funcC, funcD, *argsA, **kwargsA):
    def time_function(func, *args, **kwargs):
        start_time = time.time()
        func(*args, **kwargs)
        end_time = time.time()
        return end_time - start_time

    # Timing functionA vs functionB
    time_A = time_function(funcA, *argsA, **kwargsA)
    print(memory.state)
    memory.restartMemory()
    
    time_B = time_function(funcB, *argsA, **kwargsA)
    print(memory.state)
    print(f"Function A vs B: A={time_A:.6f} sec, B={time_B:.6f} sec")
    memory.restartMemory()

    # Timing functionC vs functionD
    time_C = time_function(funcC, *argsA, **kwargsA)
    print(memory.state)
    memory.restartMemory()
    time_D = time_function(funcD, *argsA, **kwargsA)
    print(memory.state)
    print(f"Function C vs D: C={time_C:.6f} sec, D={time_D:.6f} sec")

compare_functions(simpleencrypt.aesEncrypt, vectorizedencrypt.aesEncrypt, simpledecrypt.aesDecrypt, vectorizeddecrypt.aesDecrypt)
