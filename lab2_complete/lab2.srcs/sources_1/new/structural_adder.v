`timescale 1ns / 1ps

module structural_adder #(parameter W=14)(
    input [W-1:0] a, //14 bits
    input [W-1:0] b, //14 bits
    output [W:0] sum //15 bits
    );
    
    wire [W:0] intermediate_carry;
    assign intermediate_carry[0] = 0;
    assign sum[W] = intermediate_carry[W];
    
     
    genvar i;
    generate
        for (i = 0; i < W; i = i + 1) 
        begin : make_FAs    
           full_adder gen_FA(.a(a[i]), 
                            .b(b[i]), 
                            .carry_in(intermediate_carry[i]), 
                            .sum(sum[i]), 
                            .carry_out(intermediate_carry[i+1]));
        end
    endgenerate
endmodule
