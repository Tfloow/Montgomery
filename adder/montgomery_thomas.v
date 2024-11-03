`timescale 1ns / 1ps
`include "adder.v"
`include "shift_add_123.v"
`include "shift_register_two.v"

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
    wire [1023:0] operand_outM;
    wire [1024:0] operand_out2M;
    wire [1027:0] operand_out3M;
    
    wire [1023:0] operand_outB;
    wire [1024:0] operand_out2B;
    wire [1027:0] operand_out3B;
    
    wire prep_done_M;
    wire prep_done_B;
      
            //connecting shift_add with the registers
    assign regM_D = {3'b0, operand_outM};
    assign reg2M_D = {2'b0, operand_out2M};
    assign reg3M_D = operand_out3M;
    
    assign regB_D = {3'b0, operand_outB};
    assign reg2B_D = {2'b0, operand_out2B};
    assign reg3B_D = operand_out3B;
    
    reg shift_direction;
    //shift will start when start is put to 1'b1;            
    shift_add_123   shiftM(clk, in_m, start, resetn, prep_done_M, operand_outM, operand_out2M, operand_out3M); //initializes wires adder
    shift_add_123   shiftB(clk, in_b, start, resetn, prep_done_B, operand_outB, operand_out2B, operand_out3B); //initializes wires adder
    
    // design the multiplexer

    //reg initialization A and B for addition
    wire  [1026:0] operand_A;   // out
    wire  [1026:0] operand_B;   // out
  
    //adder initialization      
    reg subtract;
    wire adder_done;
    reg start_adder;
    mpadder adder(clk, resetn, start_adder, subtract, operand_A, operand_B, regoutadder_D, adder_done); //initializes wires adder

    //Shifter initialization 
    reg   shift;
    wire  [1025:0] out_shift;
    wire   shift_done;
    reg   enable_shifter;
    reg [1027:0] in_shift;
  
    shift_register_two shifter(clk, regoutadder_D, shift, resetn, enable_shifter, out_shift, shift_done);
    assign regC_D = out_shift;
    assign operand_A = regC_Q;

    // creating another shift_register_two for the A number
    reg shift_A;
    reg enable_A;
    wire [1025:0] out_shifted_A;
    wire shift_done_A;
    shift_register_two shiftA(clk,{4'b0, in_a}, shift_A, resetn, enable_A, out_shifted_A, shift_done_A);
    wire [1:0] lsb_A;
    assign lsb_A = out_shifted_A;

    reg [9:0] i;
    always @(posedge clk) begin
        if(~resetn)
            i <= 10'd0;
    end

    reg [1:0] loopState;
    reg [1:0] nextloopState;
    always @(posedge clk) begin
        if(~resetn)
            loopState <= 2'd0;
        else
            state <= nextloopState;
    end

    reg [3:0] state;
    reg [3:0] nextstate;

    always @(posedge clk) begin
        if(~resetn)	state <= 3'd0;
        else        state <= nextstate;
    end

    // ~~~~ FSM ~~~~
    // Enable pin
    always @(posedge clk) begin
        case (state)
            // IDLE state
            3'd0:   
                begin
                   regA_en <= 1'd0;
                   regB_en <= 1'd0;
                   regM_en <= 1'd0;

                   reg2B_en <= 1'd0;
                   reg3B_en <= 1'd0;

                   reg2M_en <= 1'd0;
                   reg3M_en <= 1'd0; 

                   regC_en <= 1'd0;
                   regoutadder_en <= 1'd0;
                end
            // Preparing the 6 multiplexer
            3'd1:
                begin
                   regA_en <= 1'd1;
                   regB_en <= 1'd1;
                   regM_en <= 1'd1;

                   reg2B_en <= 1'd1;
                   reg3B_en <= 1'd1;

                   reg2M_en <= 1'd1;
                   reg3M_en <= 1'd1; 
                end
            // Do the loop
            3'd2:
                begin
                    // Fix the registers
                   regA_en <= 1'd0;
                   regB_en <= 1'd0;
                   regM_en <= 1'd0;

                   reg2B_en <= 1'd0;
                   reg3B_en <= 1'd0;

                   reg2M_en <= 1'd0;
                   reg3M_en <= 1'd0; 
                end
            // Conditional Subtraction
            3'd3:
                begin
                    reg2B_en <= 1'd1; //DUMMY TO BE REMOVED
                end
            // Finish state
            3'd4:
                begin
                    reg2B_en <= 1'd1; //DUMMY TO BE REMOVED
                end
            default: 
                begin
                   regA_en <= 0'd0;
                   regB_en <= 0'd0;
                   regM_en <= 0'd0;

                   reg2B_en <= 0'd0;
                   reg3B_en <= 0'd0;

                   reg2M_en <= 0'd0;
                   reg3M_en <= 0'd0; 

                   regC_en <= 0'd0;
                   regoutadder_en <= 0'd0;
                end
        endcase
    end

    // State switching
    always @(posedge clk) begin
        // When start signal sent we start
        case (state)
            3'd0: 
                begin 
                    if(start == 1'd1)
                        nextstate <= 3'd1;
                end
            3'd1:
                begin
                    if(prep_done_B && prep_done_M)
                        nextstate <= 3'd2;
                end
            3'd2:
                begin
                    if(i >= 10'd1022)
                        nextstate <= 3'd3;
                    else if(loopState == 2'd3) // finished one loop
                        i <= i + 2;
                end
            3'd3:
                begin
                    // IDK if this comparision is correct
                    //if(out_shift < in_M)
                        nextstate <= 3'd0;
                end
            default: 
                nextstate <= 3'd0;
        endcase
 
    end

    // FSM of the loop
    always @(posedge clk) begin
        case(loopState)
            1'd0:
                begin
                    if(lsb_A == 2'd1)
                        operand_A <= regB_D;
                    else if(lsb_A == 2'd2)
                        operand_A <= reg2B_D;
                    else if(lsb_A == 2'd3)
                        operand_A <= reg3B_D;
                    else
                        operand_A <= 1026'b0;
                end
        endcase
    end

    
endmodule