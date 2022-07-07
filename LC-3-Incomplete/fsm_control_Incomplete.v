

module fsm_control( RESET, CLK, 
                    INSTR, 
                    N, Z, P, 
                    MARMUX_SEL, 
                    GATE_MARMUX_SEL, 
                    PCMUX_SEL, 
                    LDPC, 
                    GATE_PC_SEL, 
                    SR1, SR2, DR, 
                    LDREG, 
                    SR2MUX_SEL, 
                    ADDR2MUX_SEL, ADDR1MUX_SEL, 
                    ALUK, GATE_ALU_SEL,
                     LDIR, LDCC, 
                     LDMDR, LDMAR, MEM_RW, GATE_MDR_SEL);

    input            RESET;
    input            CLK;
    input [15:0]     INSTR;
    input            N;
    input            Z;
    input            P;
    output           MARMUX_SEL;
    output           GATE_MARMUX_SEL;
    output [1:0]     PCMUX_SEL;
    output           LDPC;
    output           GATE_PC_SEL;
    output [2:0]     SR1;
    reg    [2:0]     SR1;
    output [2:0]     SR2;
    reg    [2:0]     SR2;
    output [2:0]     DR;
    reg    [2:0]     DR;
    output           LDREG;
    output           SR2MUX_SEL;
    output [1:0]     ADDR2MUX_SEL;
    output           ADDR1MUX_SEL;
    output [1:0]     ALUK;
    reg    [1:0]     ALUK;
    output           GATE_ALU_SEL;
    output           LDIR;
    output           LDCC;
    output [1:0]     LDMDR;
    output           LDMAR;
    output           MEM_RW;
    output           GATE_MDR_SEL;
    
    
    parameter [2:0] fsm_state_F1 = 0,  // FETCH:  PC地址进入存储器
                    fsm_state_F2 = 1,  // FETCH:  取PC指令到IR；下一个指令地址进入PC
                    fsm_state_D  = 2,  // DECODE: 指令译码; 取寄存器文件
                    fsm_state_EA = 3,  // EVALUATE ADDRESS： 地址计算
                    fsm_state_OP = 4,  // FETCH OPERAND：取操作数
                    fsm_state_EX = 5,  // EXECUTE：执行
                    fsm_state_S  = 6;  // STORE RESULT：存放结果

    reg [2:0]        CURRENT_STATE;
    reg [2:0]        NEXT_STATE;
    reg [18:0]       CURRENT_SIGNALS;
    wire [3:0]       OPCODE;
 
    parameter ADD = 4'b0001; 
    parameter AND = 4'b0101; 
    parameter BR  = 4'b0000;
    parameter JMP = 4'b1100; 
    parameter JSR = 4'b0100;
    parameter LD  = 4'b0010; 
    parameter LDI = 4'b1010;
    parameter LDR = 4'b0110;
    parameter LEA = 4'b1110;
    parameter NOT = 4'b1001;
    parameter RTI = 4'b1000;
    parameter ST  = 4'b0011; 
    parameter STI = 4'b1011;
    parameter STR = 4'b0111;
    parameter TRAP= 4'b1111;  

    parameter MARMUX_SEL_ZEXT7  =19'b10_00_0000_00_0000_00_000;
    parameter GATE_MARMUX_EN    =19'b01_00_0000_00_0000_00_000;
    parameter PCMUX_SEL_PLUS    =19'b00_00_0000_00_0000_00_000;
    parameter PCMUX_SEL_OFFSET  =19'b00_01_0000_00_0000_00_000;
    parameter PCMUX_SEL_DIRECT  =19'b00_10_0000_00_0000_00_000;
    parameter LDPC_EN           =19'b00_00_1000_00_0000_00_000;
    parameter GATE_PC_SEL_EN    =19'b00_00_0100_00_0000_00_000;
    parameter LDREG_EN          =19'b00_00_0010_00_0000_00_000;
    parameter SR2MUX_SEL_SEXT4  =19'b00_00_0001_00_0000_00_000;
    parameter ADDR2MUX_SEXT5    =19'b00_00_0000_01_0000_00_000;
    parameter ADDR2MUX_SEXT8    =19'b00_00_0000_10_0000_00_000;
    parameter ADDR2MUX_SEXT10   =19'b00_00_0000_11_0000_00_000;
    parameter ADDR1MUX_PCOUT    =19'b00_00_0000_00_1000_00_000;
    parameter ADDR1MUX_SR1      =19'b00_00_0000_00_0000_00_000;
    parameter GATE_ALU_SEL_EN   =19'b00_00_0000_00_0100_00_000;
    parameter LDIR_EN           =19'b00_00_0000_00_0010_00_000;
    parameter LDCC_EN           =19'b00_00_0000_00_0001_00_000;
    parameter LDMDR_LD_MEMOUT   =19'b00_00_0000_00_0000_10_000;
    parameter LDMDR_LD_BUS      =19'b00_00_0000_00_0000_11_000;
    parameter LDMDR_MEMOUT      =19'b00_00_0000_00_0000_00_000;
    parameter LDMDR_BUS         =19'b00_00_0000_00_0000_01_000;
    parameter LDMAR_LD          =19'b00_00_0000_00_0000_00_100;
    parameter MEM_WE            =19'b00_00_0000_00_0000_00_010;
    parameter MEM_RD            =19'b00_00_0000_00_0000_00_000;
    parameter GATE_MDR_EN       =19'b00_00_0000_00_0000_00_001;

    assign OPCODE          = INSTR[15:12];
    assign MARMUX_SEL      = CURRENT_SIGNALS[18];
    assign GATE_MARMUX_SEL = CURRENT_SIGNALS[17];
    assign PCMUX_SEL       = CURRENT_SIGNALS[16:15];
    assign LDPC            = CURRENT_SIGNALS[14];
    assign GATE_PC_SEL     = CURRENT_SIGNALS[13];
    assign LDREG           = CURRENT_SIGNALS[12];
    assign SR2MUX_SEL      = CURRENT_SIGNALS[11];
    assign ADDR2MUX_SEL    = CURRENT_SIGNALS[10:9];
    assign ADDR1MUX_SEL    = CURRENT_SIGNALS[8];
    assign GATE_ALU_SEL    = CURRENT_SIGNALS[7];
    assign LDIR            = CURRENT_SIGNALS[6];
    assign LDCC            = CURRENT_SIGNALS[5];
    assign LDMDR           = CURRENT_SIGNALS[4:3];
    assign LDMAR           = CURRENT_SIGNALS[2];
    assign MEM_RW          = CURRENT_SIGNALS[1];
    assign GATE_MDR_SEL    = CURRENT_SIGNALS[0];
    
    
    always @(posedge CLK or posedge RESET)
    begin: sync_proc
        if (RESET == 1'b1)
            CURRENT_STATE <= fsm_state_F1;
        else 
            CURRENT_STATE <= NEXT_STATE;
    end
    
    
    always @(CURRENT_STATE or RESET)
    begin: comb_proc
        if (RESET == 1'b1)
        begin
            CURRENT_SIGNALS <= 19'b0011110000000000000;
            NEXT_STATE <= fsm_state_F1;
        end
        else
        begin
            CURRENT_SIGNALS <= 19'b0000000000000000000;
            $display("\n %m: At time %0t : CURRENT_STATE = %d",$time,CURRENT_STATE);
            case (CURRENT_STATE)
                // FETCH 1:  PC地址进入总线，从存储器读取对应的数据，数据至MDR
                fsm_state_F1 :
                begin
                    // GATE_PC_SEL: send pc to bus
                    // LDMAR : get the pc from bus into MAR(open the memory) 
                    // LDMDR : get the instr from memory into MDR ( instr doesn't go into bus)
                    // PC -> Bus -> MAR -> Memory -> MDR
                    CURRENT_SIGNALS <= GATE_PC_SEL_EN | LDMAR_LD | LDMDR_LD_MEMOUT;  //19'b00_00_010000000010100;              
                    NEXT_STATE <= fsm_state_F2;
                end 

                // FETCH 2:  取PC指令到IR；下一个指令地址进入PC
                fsm_state_F2 : 
                begin
                    // GATE_MDR_SEL: get instr from memory into bus 
                    // LDIR : get instr from bus into IR 
                    // LDPC : next PC （PC+1） address into PC
                    CURRENT_SIGNALS <= LDPC_EN | LDIR_EN |GATE_MDR_EN ;              //19'b00_00_1000_00_0010_00_001;
                    NEXT_STATE <= fsm_state_D;
                end
                
                // DECODE: 指令译码; 取寄存器文件
                fsm_state_D :
                begin
                    $display("%m: At time %0t : OPCODE = %b",$time,OPCODE);
                    CURRENT_SIGNALS <= 19'b0000000000000000000;
                    
                    // OPCODE:instructions:
                    if ((OPCODE[1:0] == 2'b10 | OPCODE[1:0] == 2'b11) & OPCODE != 4'b1111)
                        NEXT_STATE <= fsm_state_EA;
                    else
                        NEXT_STATE <= fsm_state_EX;
                    
                    // set ALU mode
                    ALUK <= INSTR[15:14];
                    
                    // source register 
                    if(OPCODE[1:0] == 2'b11)  SR1 <= INSTR[11:9]; // instuction: ST 
                    else                      SR1 <= INSTR[8:6];
                    
                    SR2 <= INSTR[2:0];
                    
                    // Destination register
                    if (OPCODE == 4'b0100)  // instuction: JSR=0100
                        DR <= 3'b111;
                    else
                        DR <= INSTR[11:9];
                end
                
                // EVALUATE ADDRESS： 地址计算
                fsm_state_EA :
                begin
                    // please add code to improve the function//
                    NEXT_STATE <= fsm_state_OP;
                end
                
                // FETCH OPERAND：取操作数
                fsm_state_OP :
                begin
                    // please add code to improve the function//
                    NEXT_STATE <= fsm_state_S;
                end
                
                fsm_state_EX :
                begin
                    case (OPCODE)
                        // ALU -> Bus
                        ADD : CURRENT_SIGNALS <= LDCC_EN |GATE_ALU_SEL_EN ;//19'b0000000000010100000;   //-- ADD
                        default: CURRENT_SIGNALS <= 19'b0000000000000000000;
                    endcase
                    
                    if ((OPCODE == 4'b0001 | OPCODE == 4'b0101) & INSTR[5] == 1'b1)
                        CURRENT_SIGNALS[11] <= 1'b1; // SR2MUX_SEL
                    
                    NEXT_STATE <= fsm_state_S;
                end
                
                fsm_state_S :
                begin
                    case(OPCODE)
                        // ALU -> Bus -> RegFile(DR)
                        ADD  :  CURRENT_SIGNALS <= LDCC_EN|GATE_ALU_SEL_EN |LDREG_EN ;//19'b0000001000010100000;//  -- ADD
                        default :  CURRENT_SIGNALS <= 19'b0000000000000000000;
                    endcase
                    NEXT_STATE <= fsm_state_F1;
                    
                    if ((OPCODE == 4'b0001 | OPCODE == 4'b0101) & INSTR[5] == 1'b1)
                        CURRENT_SIGNALS[11] <= 1'b1; // SR2MUX_SEL to SEXT4
                end
                
                default :begin
                    CURRENT_SIGNALS <= {19{1'b0}};
                    NEXT_STATE <= fsm_state_F1;
                end
            endcase
        end
    end

endmodule

module fsm_control_tb;
    reg CLK,RESET;

    fsm_control U_fsm_control(.CLK(CLK),.RESET(RESET));

    always #10 CLK=~CLK;
    initial begin
        CLK=1;
        RESET =1;
        #50 RESET = 0;
    end

endmodule