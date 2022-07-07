

module ram #(parameter ADDR_SIZE = 16 ,
             parameter DATA_SIZE = 16 )
            (WE, ADDRESS, DATA_IN, DATA_OUT);
    input                   WE;
    input  [ADDR_SIZE-1:0]  ADDRESS;
    input  [DATA_SIZE-1:0]  DATA_IN;
    output [DATA_SIZE-1:0]  DATA_OUT;

    localparam MEM_DEPTH = 1<< ADDR_SIZE;    
    reg [DATA_SIZE-1:0] MEM [0:MEM_DEPTH-1];    // memory     

    // ********* The first design method ****************
    // reg [DATA_SIZE-1:0]  DATA_OUT;
    // initial begin 
    // $readmemb("rams_init_file.data",MEM); 
    // end 

    // always @(WE, ADDRESS, DATA_IN, DATA_OUT) begin
    //     if (WE == 1'b1)
    //         MEM[ADDRESS] <= DATA_IN;
    //     else
    //         DATA_OUT <= MEM[ADDRESS];
    // end
            

    //********** the second design method ***************
    reg [DATA_SIZE-1:0]  DATA_OUT;
    
    always @(WE, ADDRESS, DATA_IN, DATA_OUT) begin
        if (WE == 1'b1) begin
            MEM[ADDRESS] <= DATA_IN;
            $display("\n WRITE into RAM: At time %0t :RAM NO.%0d <= %0h",$time,ADDRESS,DATA_IN);
        end else
            case(ADDRESS)
                // initialize
                16'b0000000000000000: begin DATA_OUT <= 16'b0101_000_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R0 R7 0  => R0=0",$time,ADDRESS);end // AND R0 R7 0  => R0=0
                16'b0000000000000001: begin DATA_OUT <= 16'b0101_001_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R1 R7 0  => R1=0",$time,ADDRESS); end // AND R1 R7 0  => R1=0
                16'b0000000000000010: begin DATA_OUT <= 16'b0101_010_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R2 R7 0  => R2=0 ",$time,ADDRESS); end // AND R2 R7 0  => R2=0
                16'b0000000000000011: begin DATA_OUT <= 16'b0101_011_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R3 R7 0  => R3=0  ",$time,ADDRESS); end // AND R3 R7 0  => R3=0   
                16'b0000000000000100: begin DATA_OUT <= 16'b0101_100_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R4 R7 0  => R4=0  ",$time,ADDRESS); end // AND R4 R7 0  => R4=0    
                16'b0000000000000101: begin DATA_OUT <= 16'b0101_101_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R5 R7 0  => R5=0 ",$time,ADDRESS); end // AND R5 R7 0  => R5=0 
                16'b0000000000000110: begin DATA_OUT <= 16'b0101_110_111_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R6 R7 0  => R6=0 ",$time,ADDRESS); end // AND R6 R7 0  => R6=0 
                16'b0000000000000111: begin DATA_OUT <= 16'b0101_111_000_1_00000; $display("\n At time %0t :RAM NO.%0d   AND R7 R0 0  => R7=0 ",$time,ADDRESS); end // AND R7 R0 0  => R7=0 
               
                16'b0000000000001000: begin DATA_OUT <= 16'b0001_001_000_1_00010;  $display("\n At time %0t :RAM NO.%0d   ADD R1 R0 imme:2 => R1=2",$time,ADDRESS);  end // ADD R1 R0 imme:110 => R1=2
                16'b0000000000001001: begin DATA_OUT <= 16'b0001_010_000_1_00101;  $display("\n At time %0t :RAM NO.%0d   ADD R2 R0 imme:5 => R2=5",$time,ADDRESS);  end // ADD R2 R0 imme:101 => R2=5
                16'b0000000000001010: begin DATA_OUT <= 16'b0001_011_001_0_00_010; $display("\n At time %0t :RAM NO.%0d   ADD R3 R1 R2 => R3=7",$time,ADDRESS);end // ADD R3 R1 R2 => R3=7
                16'b0000000000001011: begin DATA_OUT <= 16'b0101_100_001_0_00_010; $display("\n At time %0t :RAM NO.%0d   AND R4 R1 R2 => R4=b1111_1111_1111_1110 ",$time,ADDRESS); end // AND R4 R1 R2 => R4=b1111_1111_1111_1100
                16'b0000000000001100: begin DATA_OUT <= 16'b0011_011_000000010;   $display("\n At time %0t :RAM NO.%0d   ST R3,0b010=> ram:0000_1111 = 7 ",$time,ADDRESS); end //ST R3,0b010
                16'b0000000000001101: begin DATA_OUT <= 16'b0010_111_000000001;   $display("\n At time %0t :RAM NO.%0d   LD R7,0b001=> R7=ram:0000_1111(7) ",$time,ADDRESS); end // LD R7,0b010   
                16'b0000000000001110: begin DATA_OUT <= 16'b1100_000_111_000000;   $display("\n At time %0t :RAM NO.%0d   JMP R7 => PC->0 ",$time,ADDRESS); end // JMP R7      
                // 16'b0000000000001111: begin DATA_OUT <= 16'b0000_000000000110;$display("\n At time %0t : imme:6 ",$time);end //1
                
                default: begin DATA_OUT <= MEM[ADDRESS];$display("\n READ from RAM: At time %0t :  NO.%0d DATA OUT = %0h",$time,ADDRESS,MEM[ADDRESS]); end
            endcase
    end 

endmodule 

module ram_tb   #(parameter ADDR_SIZE = 16 ,
                  parameter DATA_SIZE = 16 );
    reg                   WE;
    reg  [ADDR_SIZE-1:0]  ADDRESS;
    reg  [DATA_SIZE-1:0]  DATA_IN;
    wire [DATA_SIZE-1:0]  DATA_OUT;

    reg [DATA_SIZE-1:0]  i;
    
    ram U_ram(WE, ADDRESS, DATA_IN, DATA_OUT);

    initial begin
        $monitor("WE = %h, ADDRESS = %h,  DATA_IN = %h, DATA_OUT = %h",WE, ADDRESS, DATA_IN, DATA_OUT);
        for ( i = 0 ; i< 8 ; i=i+1 ) begin
            $display("write:");
            ADDRESS = i ;
            DATA_IN = i;
            WE = 1 ;
            #10 

            $display("read:");
            WE = 0 ;
            #10;
        end
        $display("random test:");
        for ( i = 0 ; i< 8 ; i=i+1 ) begin
            $display("write:");
            ADDRESS = {$random}%ADDR_SIZE ;
            DATA_IN = {$random}%(1<<DATA_SIZE);
            WE = 1 ;
            #10 
            
            $display("read:");
            WE = 0 ;
            #10;
        end
    end

endmodule
