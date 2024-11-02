`timescale 1ns / 1ps
`include "adder.v"

module montgomery(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1024:0] result,
  output          done
    );

  // Student tasks:
  // 1. Instantiate an Adder
  // 2. Use the Adder to implement the Montgomery multiplier in hardware.
  // 3. Use tb_montgomery.v to simulate your design.
                                                                //Definition A and to be multiplexed registers
  // Definition register A
    reg          regA_en;
    wire [1023:0] regA_D;// in
    reg  [1023:0] regA_Q;// out
    
    always @(posedge clk)
    begin
        if(~resetn)         regA_Q = 1024'd0;
        else if (regA_en)   regA_Q <= regA_D; //If not reset, paste input for a to register a
    end
    
    assign regA_D = in_a;
    
    // Definition register B 
    reg          regB_en;   
    wire [1026:0] regB_D;   // in
    reg  [1026:0] regB_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         regB_Q = 1027'd0;
        else if (regB_en)   regB_Q <= regB_D; //If not reset, paste input for b to register b
    end
  
      // Definition register 2B 
    reg          reg2B_en;   
    wire [1026:0] reg2B_D;   // in
    reg  [1026:0] reg2B_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg2B_Q = 1027'd0;
        else if (reg2B_en)   reg2B_Q <= reg2B_D;
    end
  
      // Definition register 3B 
    reg          reg3B_en;   
    wire [1026:0] reg3B_D;   // in
    reg  [1026:0] reg3B_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg3B_Q = 1027'd0;
        else if (reg3B_en)   reg3B_Q <= reg3B_D;
    end
    
        // Definition register M
    reg          regM_en;   
    wire [1026:0] regM_D;   // in
    reg  [1026:0] regM_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         regM_Q = 1027'd0;
        else if (regM_en)   regM_Q <= regM_D; //If not reset, paste input for m to register b
    end
    
            // Definition register 2M
    reg          reg2M_en;   
    wire [1026:0] reg2M_D;   // in
    reg  [1026:0] reg2M_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg2M_Q = 1027'd0;
        else if (reg2M_en)   reg2M_Q <= reg2M_D;
    end
    
            // Definition register 3M
    reg          reg3M_en;   
    wire [1026:0] reg3M_D;   // in
    reg  [1026:0] reg3M_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg3M_Q = 1027'd0;
        else if (reg3M_en)   reg3M_Q <= reg3M_D;
    end
    
                // Definition register C
    reg          regC_en;   
    wire [1027:0] regC_D;   // in
    reg  [1027:0] regC_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn || start)         regC_Q = 1028'd0;
        else if (regC_en)   regC_Q <= regC_D;
    end
                
    // Definition register regoutadder
    reg          regoutadder_en;   
    wire [1027:0] regoutadder_D;   // in
    reg  [1027:0] regoutadder_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)                regoutadder_Q = 1028'd0;
        else if (regoutadder_en)   regoutadder_Q <= regoutadder_D;
    end
          
    //shifting preparation stage
    wire [1026:0] operand_outM;
    wire [1026:0] operand_out2M;
    wire [1026:0] operand_out3M;
    
    wire [1026:0] operand_outB;
    wire [1026:0] operand_out2B;
    wire [1026:0] operand_out3B;
    
    wire prep_done_M;
    wire prep_done_B;
      
            //connecting shift_add with the registers
    assign regM_D = operand_outM;
    assign reg2M_D = operand_out2M;
    assign reg3M_D = operand_out3M;
    
    assign regB_D = operand_outB;
    assign reg2B_D = operand_out2B;
    assign reg3B_D = operand_out3B;
    
    reg shift_direction;
    //shift will start when start is put to 1'b1;            
    shift_add_123   shiftM(clk, in_m, start, resetn, prep_done_M, operand_outM, operand_out2M, operand_out3M); //initializes wires adder
    shift_add_123   shiftB(clk, in_b, start, resetn, prep_done_B, operand_outB, operand_out2B, operand_out3B); //initializes wires adder
    
    //reg initialization A and B for addition
    reg  [1026:0] operand_A;   // out
    reg  [1026:0] operand_B;   // out
    always @(posedge clk) begin
        if(~resetn) begin
            operand_A <= 1027'd0;
            operand_B <= 1027'd0;
        end
    end
  
    //adder initialization      
    reg subtract;
    wire adder_done;
    reg start_adder;
    mpadder adder(clk, resetn, start_adder, subtract, operand_A, operand_B, regoutadder_D, adder_done); //initializes wires adder

    //Shifter initialization 
    reg   shift;
    reg  [1026:0] out_shift;
    always @(posedge clk) begin
        if(~resetn) begin
            out_shift <= 1027'b0;
        end
    end
    wire   shift_done;
    reg   enable_shifter;
  

    shift_register shifter(clk, in_shift, shift, shift_direction, resetn, enable_shifter, output_shift, shift_done);

    
endmodule