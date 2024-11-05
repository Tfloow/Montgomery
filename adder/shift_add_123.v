//`include "adder.v"

module shift_add_123(
    input clk,
    input wire [1023:0] operand,
    input start, // will be 1 for a clock cycle
    input resetn,
    output done,
    output wire [1023:0] operand_out,
    output wire [1024:0] operand_2_out,
    output wire [1027:0] operand_3_out);
    
    assign operand_out = operand;
    
    reg shift; 
    wire shift_done;
    
    shift_register shifter(clk, operand, shift, resetn, start, operand_2_out, shift_done);
    
    // adding some padding for the 1027 bits operation
    wire [1026:0] padded_a;
    wire [1026:0] padded_b;
    
    assign padded_a = {3'b0, operand_out};
    assign padded_b = {2'b0, operand_2_out};
    
    mpadder adder(clk, resetn, shift_done, 1'd0, padded_a, padded_b, operand_3_out, done); 
    
    // control logic
    always@(posedge clk)  
        shift <= start;

    
endmodule