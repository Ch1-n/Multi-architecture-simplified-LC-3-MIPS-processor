# Multi-architecture-simplified-LC-3-MIPS-processor
In this paper, a multi-structure simplified MIPS processor is designed. 
The processor's instruction bit width is 16 bits, and the opcode is the upper four bits of the instruction.
The processor supports four types of instructions, namely operation instructions, address jump instructions, data storage instructions and data fetch instructions;
supports immediate addressing mode, register addressing mode, relative addressing mode, indirect addressing mode and base offset addressing mode.
In this paper, the instruction cycle is divided into seven cycles, which are fetch F1, value F2, decode D, address calculation EA, fetch operand, 
execute and write back WB. According to the division of instruction cycles, the design of the data channel finite state machine FSDM is completed, 
and the flow of instruction execution and the jumps between states are clarified. At the same time, according to the data channel finite state machine FSDM, 
the design of the processor data channel structure is completed; the ADD, LD and JMP instruction microcode signal design is completed; finally, 
the verification of the whole system is given. Instructions such as ADD, AND, LD, ST, LDI, STI, LDR, STR, and BR are verified.
