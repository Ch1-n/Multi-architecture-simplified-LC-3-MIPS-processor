

module tristate_b16(SEL, D_IN, D_OUT);
    input         SEL;
    input [15:0]  D_IN;
    output[15:0]  D_OUT;

    // ********* The first design method ****************  
    // reg   [15:0]  D_OUT;

    // always @(SEL or D_IN)
    // begin: tb
    //    if (SEL == 1'b1)
    //       D_OUT <= D_IN;
    //    else
    //       D_OUT <= {16{1'bZ}};
    // end

    //********** the second design method ***************
    // assign D_OUT = SEL ? D_IN : {16{1'bZ}}; 

    ///********** the third design method ***************
    tristate_b U0 (D_IN[0], SEL, D_OUT[0]);
    tristate_b U1 (D_IN[1], SEL, D_OUT[1]);
    tristate_b U2 (D_IN[2], SEL, D_OUT[2]);
    tristate_b U3 (D_IN[3], SEL, D_OUT[3]);
    tristate_b U4 (D_IN[4], SEL, D_OUT[4]);
    tristate_b U5 (D_IN[5], SEL, D_OUT[5]);
    tristate_b U6 (D_IN[6], SEL, D_OUT[6]);
    tristate_b U7 (D_IN[7], SEL, D_OUT[7]);
    tristate_b U8 (D_IN[8], SEL, D_OUT[8]);
    tristate_b U9 (D_IN[9], SEL, D_OUT[9]);
    tristate_b U10(D_IN[10], SEL, D_OUT[10]);
    tristate_b U11(D_IN[11], SEL, D_OUT[11]);
    tristate_b U12(D_IN[12], SEL, D_OUT[12]);
    tristate_b U13(D_IN[13], SEL, D_OUT[13]);
    tristate_b U14(D_IN[14], SEL, D_OUT[14]);
    tristate_b U15(D_IN[15], SEL, D_OUT[15]);
    
endmodule

module  tristate_b16_tb;
    reg [15:0]  D_IN;   // input
    reg         SEL;
    wire[15:0]  D_OUT;  // output
    
    //instantiation
    tristate_b16 U_tristate_b16(.SEL(SEL),
                                .D_IN(D_IN),
                                .D_OUT(D_OUT)); 
    initial begin
        $monitor("SEL = %h , D_IN = %h , D_OUT = %h",SEL,D_IN,D_OUT);
        
        repeat (10) begin
        D_IN    = $random;
        #10 SEL = 1'b0;
        #10 SEL = 1'b1;
        #10 ;
        end
    end
endmodule