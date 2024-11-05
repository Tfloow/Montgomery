`timescale 1ns / 1ps
`include "seven_multiplexer.v"
`include "shift_register_two.v"
`include "shift_add_123.v"
`include "adder.v"
`include "shift_register.v"

module montgomery(
    input           clk,
    input           resetn,
    input           start,
    input  [1023:0] in_a,
    input  [1023:0] in_b,
    input  [1023:0] in_m,
    output [1024:0] result,
    output   reg       done
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
        if(~resetn)             reg3M_Q = 1027'd0;
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

    // Definition of the regresult 
    reg regresult_en;
    wire [1027:0] regresult_D;
    reg [1023:0] regresult_Q;
    always @(posedge clk) begin
        if(~resetn)                regresult_Q = 1028'd0;
        else if (regresult_en)   regresult_Q <= regresult_D;
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
    reg [2:0] select_multi;
    wire [1026:0] out_multi;
    seven_multiplexer multi(clk, resetn, regM_Q, reg2M_Q, reg3M_Q, regB_Q, reg2B_Q, reg3B_Q, select_multi, out_multi);

    //reg initialization A and B for addition
    wire  [1026:0] operand_A;   // out
    wire  [1026:0] operand_B;   // out
    assign operand_B = out_multi;
  
    //adder initialization      
    reg subtract;
    wire adder_done;
    reg start_adder;
    mpadder adder(clk, resetn, start_adder, subtract, operand_B, operand_A, regoutadder_D, adder_done); //initializes wires adder

    //Shifter initialization 
    reg   shift;
    wire  [1027:0] out_shift;
    wire   shift_done;
    reg   enable_shifter;
    reg [1027:0] in_shift;
  
    shift_register_two shifter(clk, regoutadder_Q, shift, resetn, enable_shifter, out_shift, shift_done);
    assign regC_D = out_shift;
    assign operand_A = regC_Q;
    assign regresult_D = out_shift;
    assign result = regresult_Q;

    // creating another shift_register_two for the A number
    reg shift_A;
    reg enable_A;
    wire [1027:0] out_shifted_A;
    wire shift_done_A;
    shift_register_two shiftA(clk,{4'b0, regA_Q}, shift_A, resetn, enable_A, out_shifted_A, shift_done_A);
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
        if(~resetn) begin
            loopState <= 2'd0;
            nextloopState <= 2'd0;
        end
        else
            loopState <= nextloopState;
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
                    // resetting
                   done <= 1'b0;
                   select_multi <= 3'd0;
                   i <= 10'd0;
                    
                   // always read input
                   regA_en <= 1'd1;
                   regB_en <= 1'd1;
                   regM_en <= 1'd1;
                    
                   // trash rn so no writing
                   reg2B_en <= 1'd0;
                   reg3B_en <= 1'd0;
                   reg2M_en <= 1'd0;
                   reg3M_en <= 1'd0; 
                   regC_en <= 1'd0;
                   regoutadder_en <= 1'd0;
                   regresult_en <= 1'd0;

                   // reset the 2 shifter of A
                   shift_A <= 1'd0; 
                   enable_A <= 1'd0;
                   shift <= 1'd0;
                   enable_shifter <= 1'd0;
                end
            // Preparing the 6 multiplexer
            3'd1:
                begin
                    
                    
                   // to be in write mode
                   reg2B_en <= 1'd1;
                   reg3B_en <= 1'd1;
                   reg2M_en <= 1'd1;
                   reg3M_en <= 1'd1; 

                   enable_A <= 1'd1;
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

                   // stop saving the A
                   enable_A <= 1'd0;

                   // output the adder
                   regoutadder_en <= 1'b1;
                end
            // Conditional Subtraction
            3'd3:
                begin
                    regresult_en <= 1'd1;
                end
            // Finish state
            3'd4:
                begin
                    regresult_en <= 1'd0;
                    done <= 1'b1;
                end
            default: 
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
        endcase
    end

    reg incremented;
    reg subtraction_happening;

    // State switching
    always @(posedge clk) begin
        // When start signal sent we start
        case (state)
            3'd0: 
                begin 
                    incremented <= 1'b0;
                    if(start == 1'd1) begin
                        nextstate <= 3'd1;
                        state <= 3'd1;
                    end 
                end
            3'd1:
                begin
                    if(prep_done_B && prep_done_M) begin
                        nextstate <= 3'd2;
                        state <= 3'd2;
                    end
                end
            3'd2:
                begin
                    if(i >= 10'd1022) begin 
                        nextstate <= 3'd3;
                        
                    end
                    else if(loopState == 2'd0) begin
                        nextloopState <= 2'd1;
                        incremented <= 1'b0;
                    end
                    else if(loopState == 2'd3 && ~incremented) begin // finished one loop
                        i <= i + 2; // something goes wrong
                        incremented <= 1'b1;
                    end
                end
            3'd3:
                begin
                    // stop saving the result
                    if(adder_done) begin
                        // we finished 1 sub
                        if(regoutadder_D[1027] == 1'b1) // smaller no need to update
                            nextstate <= 3'd4;
                        else begin 
                            enable_shifter <= 1'b1; // save the newly calculated diff
                            subtraction_happening <= 1'b0;
                        end
                    end else begin
                        if(~subtraction_happening) begin
                            // run if no subtraction is actually going
                            select_multi <= 3'b001; // select M
                            // operand_A should also already be C
                            subtraction_happening <= 1'b1;
                            enable_shifter <= 1'b0; // to freeze the result
                            subtract <= 1'b0;       // used just for a dummy register for a one pulse start_adder
                        end else begin 
                            subtract <= 1'b1; // activate the subtract mode
                            // delay by one to make sure the right value is fed
                            if(subtract <= 1'b0)
                                start_adder <= 1'b1;
                            else
                                start_adder <= 1'b0;
                        end
                    end
                end
            3'd4: 
                nextstate <= 3'd0;
            default: 
                nextstate <= 3'd0;
        endcase
 
    end

    reg[1:0] sent; // check if signal to start already sent
    reg ready_second ; // to delay by one the start
    reg skip_second; // to skip in the last case
    reg shifted;    // save if i shifted

    // FSM of the loop
    always @(posedge clk) begin
        case(loopState)
            2'd0:
                begin
                    shift_A <= 1'd0; // stop the shift
                    shift <= 1'd0;
                    ready_second <= 1'b0;
                    sent <= 2'd0;
                    skip_second <= 1'b0;
                    shifted <= 1'b0;
                    
                    // data preparation
                    if(lsb_A == 2'd1)
                        select_multi <= 3'b100;
                    else if(lsb_A == 2'd2)
                        select_multi <= 3'b101;
                    else if(lsb_A == 2'd3)
                        select_multi <= 3'b110;
                    else
                        select_multi <= 3'b000;
                end
            2'd1:
                begin
                    subtract <= 1'b0;
                    regC_en <= 1'b1;
                    // one pulse to do the addition
                    if(sent == 2'd0) begin
                        start_adder <= 1'b1;
                        sent <= 2'd1;
                    end
                    else begin
                        start_adder <= 1'b0;
                        enable_shifter <= 1'b1; //to write into memory
                    end
                end
            2'd2:
                begin
                    if(sent == 2'd1 && ready_second == 1'b0) begin // if the second operation didn't start yet
                        if((operand_A[1:0] == 2'b01 && regM_Q[1:0] == 2'b01) || (operand_A[1:0] == 2'b11 && regM_Q[1:0] == 2'b11))
                            select_multi <= 3'b011;
                        else if((operand_A[1:0] == 2'b10 && regM_Q[1:0] == 2'b01) || (operand_A[1:0] == 2'b10 && regM_Q[1:0] == 2'b11))
                            select_multi <= 3'b010;
                        else if((operand_A[1:0] == 2'b10 && regM_Q[1:0] == 2'b01) || (operand_A[1:0] == 2'b10 && regM_Q[1:0] == 2'b11))
                            select_multi <= 3'b001;
                        else
                            select_multi <= 3'b000; // DUMMY OPERATION TO BE REMOVED FOR BETTER PERF

                        ready_second <= 1'b1;
                    end else if(sent == 2'd1 && ready_second == 1'b1) begin
                        start_adder <= 1'b1;
                        sent <= 2'd2;
                    end else 
                        start_adder <= 1'b0;
                    
                end
            2'd3:
                begin
                    enable_shifter <= 1'd0; // stop wirting to the shifter
                    if(shifted) begin
                        shift_A <= 1'd0; // do one shift
                        shift <= 1'd0;   // do the 2 shift for the C
                    end else begin
                        shift_A <= 1'd1; // do one shift
                        shift <= 1'd1;   // do the 2 shift for the C
                        shifted <= 1'b1;
                    end
                end
        endcase
    end

    // State switching
    always @(posedge clk) begin
        if(state == 3'd2) begin
            case (loopState)
                2'd0: nextloopState <= 2'd1;
                2'd1: begin
                    if(adder_done)
                        nextloopState <= 2'd2;
                end
                2'd2: begin
                    if(adder_done || skip_second)
                        nextloopState <= 2'd3;
                end
                2'd3: begin 
                    if(shift_done) begin
                        loopState <= 2'd0;
                        nextloopState <= 2'd0; // change quicker idk if I am allowed to ?
                    end
                end
                default: nextloopState <= 2'd0;
            endcase
        end
    end

    
endmodule