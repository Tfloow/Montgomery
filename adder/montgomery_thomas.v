`timescale 1ns / 1ps
`include "adder.v"
`include "seven_multiplexer.v"
`include "shift_add_123.v"
`include "shift_register.v"
`include "shift_register_two.v"

module montgomery(
    input           clk,
    input           resetn,
    input           start,
    input  [1023:0] in_a,
    input  [1023:0] in_b,
    input  [1023:0] in_m,
    output [1024:0] result,
    output   wire       done
        );

    // Student tasks:
    // 1. Instantiate an Adder
    // 2. Use the Adder to implement the Montgomery multiplier in hardware.
    // 3. Use tb_montgomery.v to simulate your design.
                                                                //Definition A and to be multiplexed registers
    
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
    

                
    // Definition register regoutadder
    reg          regoutadder_en;   
    wire [1027:0] regoutadder_D;   // in
    reg  [1027:0] regoutadder_Q;   // out
    //always @(posedge clk)
    //begin
    //    if(~resetn)                regoutadder_Q = 1028'd0;
    //    else if (regoutadder_en)   regoutadder_Q <= regoutadder_D;
    //end

    // Definition of the regresult 
    reg regresult_en;
    wire [1027:0] regresult_D;
    reg [1023:0] regresult_Q;
    always @(posedge clk) begin
        if(~resetn)                regresult_Q = 1028'd0;
        else if (regresult_en)   regresult_Q <= regresult_D;
    end 
          
    //shifting preparation stage
    wire [1023:0] out_1MB;
    wire [1024:0] out_2MB;
    wire [1027:0] out_3MB;

    wire [1023:0] operand_outM;
    wire [1024:0] operand_out2M;
    wire [1027:0] operand_out3M;

    wire [1023:0] operand_outB;
    wire [1024:0] operand_out2B;
    wire [1027:0] operand_out3B;
      
    //connecting shift_add with the registers
    assign regM_D = {3'b0, operand_outM};
    assign reg2M_D = {2'b0, operand_out2M};
    assign reg3M_D = operand_out3M;
    
    assign regB_D = {3'b0, operand_outB};
    assign reg2B_D = {2'b0, operand_out2B};
    assign reg3B_D = operand_out3B;

    // Create the Mux_M_B
    wire [1026:0] out_mux_m_b;
    reg mux_m_b_sel;
    assign out_mux_m_b = (mux_m_b_sel) ? in_b : in_m;

    // Create the 3 Demux
    assign {operand_outB, operand_outM}   = (mux_m_b_sel) ? {out_1MB, 1024'b0} : {1024'b0, out_1MB};
    assign {operand_out2B, operand_out2M} = (mux_m_b_sel) ? {out_2MB, 1025'b0} : {1025'b0, out_2MB};
    assign {operand_out3B, operand_out3M} = (mux_m_b_sel) ? {out_3MB, 1028'b0} : {1028'b0, out_3MB};
    
    reg start_123data;
    wire prep_done;
    //shift will start when start is put to 1'b1;            
    shift_add_123   shiftMB(clk, out_mux_m_b, start_123data, resetn, prep_done, out_1MB, out_2MB, out_3MB); //initializes wires adder
    //shift_add_123   shiftB(clk, in_b, start, resetn, prep_done_B, operand_outB, operand_out2B, operand_out3B); //initializes wires adder
    
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
    mpadder adder(clk, resetn, start_adder, subtract, operand_A, operand_B, regoutadder_D, adder_done); //initializes wires adder

    //Shifter initialization 
    reg   shift;
    wire  [1027:0] out_shift;
    wire   shift_done;
    reg   enable_shifter;
    reg [1027:0] in_shift;
  
    //shift_register_two shifter(clk, regoutadder_D, shift, resetn, enable_shifter, out_shift, shift_done);
    assign operand_A = out_shift;
    assign regresult_D = out_shift;
    assign result = regresult_Q;
    // Replace by a mux
    assign out_shift = (shift) ? {2'b0, regoutadder_D[1027:2]} : regoutadder_D;

    // creating another shift_register_two for the A number
    reg shift_A;
    reg enable_A;
    wire [1027:0] out_shifted_A;
    wire shift_done_A;
    shift_register_two shiftA(clk,{4'b0, in_a}, shift_A, resetn, enable_A, out_shifted_A, shift_done_A);
    wire [1:0] lsb_A;
    assign lsb_A = out_shifted_A;

    reg [10:0] i;


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
    reg finished_loopstate;
    reg subtraction_happening;

    always @(posedge clk) begin
        if(~resetn)	state <= 4'd0;
        else        state <= nextstate;
    end


    reg[1:0] sent; // check if signal to start already sent
    reg ready_second ; // to delay by one the start
    reg skip_second; // to skip in the last case
    reg shifted;    // save if i shifted
    reg [1:0] DBG_cond; // to be REMOVED
    reg [1:0] delay_state;

    //FSM
    always @(*) begin
        case (state)
            4'd0: begin
                // reg stop
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'd0;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
            end 
            4'd1: begin
                // saving the new data for M
                regM_en         <= 1'b1;
                reg2M_en        <= 1'b1;
                reg3M_en        <= 1'b1;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b1;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'd0;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
            end 
            4'd2: begin
                // Saving the data for B
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b1;
                reg2B_en        <= 1'b1;
                reg3B_en        <= 1'b1;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'd0;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b1;
                shift           <= 1'b0;
            end 
            4'd3: begin
                // New data saved stop saving
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO
                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b1;


                // multiplexer stop
                select_multi    <= out_shifted_A; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b1;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end 
            4'd4: begin // First addition C = C + out_shifted_A[1:0] * B
                // New data saved stop saving
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO
                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b1;


                // multiplexer stop
                select_multi    <= lsb_A; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b1;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end  
            4'd5: begin
                                // New data saved stop saving
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO
                enable_shifter  <= 1'b1;

                regresult_en    <= 1'b1;

                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;

                // multiplexer stop
                if((operand_A[1:0] == 2'b01 && regM_Q[1:0] == 2'b01) || (operand_A[1:0] == 2'b11 && regM_Q[1:0] == 2'b11)) begin
                    select_multi <= 3'b110;
                    DBG_cond <= 2'd1;
                    end 
                else begin 
                    if((operand_A[1:0] == 2'b10 && regM_Q[1:0] == 2'b01) || (operand_A[1:0] == 2'b10 && regM_Q[1:0] == 2'b11)) begin
                        select_multi <= 3'b101;
                        DBG_cond <= 2'd2;
                        end
                    else begin 
                        if((operand_A[1:0] == 2'b11 && regM_Q[1:0] == 2'b01) || (operand_A[1:0] == 2'b01 && regM_Q[1:0] == 2'b11)) begin
                            select_multi <= 3'b100;
                            DBG_cond <= 2'd3;
                            end
                        else begin  
                            select_multi <= 3'b000; // DUMMY OPERATION TO BE REMOVED FOR BETTER PERF
                            DBG_cond <= 2'd0;
                            end
                    end
                end 
            end 
            4'd6: begin // 2 bits shift
                // New data saved stop saving
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO
                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b1;


                // multiplexer stop
                select_multi    <= out_shifted_A;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b1;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end 
            4'd7: begin
                                // New data saved stop saving
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO

                // NEED TO IMPLEMENT LOGIC WITH THE LAST BIT CHECK
                enable_shifter  <= 1'b1;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'b100; 
                subtract        <= 1'b1;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end 
            4'd8: begin
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'b0; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
            end 
            default: begin
                regM_en         <= 1'b0;
                reg2M_en        <= 1'b0;
                reg3M_en        <= 1'b0;

                regB_en         <= 1'b0;
                reg2B_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'b0; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
            end 
        endcase
    end

    reg bigger;

    always @(*) begin
        case (state)
            4'd0: begin
            bigger <= 1'b0;
                if(start)
                    nextstate <= 4'd1;
                else
                    nextstate <= 4'd0;
            end
            4'd1: begin
            bigger <= 1'b0;
                if(prep_done)
                    nextstate <= 4'd2;
                else 
                    nextstate <= 4'd1;
            end
            4'd2: begin
            bigger <= 1'b0;
                if(prep_done)
                    nextstate <= 4'd3;
                else 
                    nextstate <= 4'd2;
            end
            4'd3: begin
            bigger <= 1'b0;
                if (i <= 1023) begin
                    
                    nextstate <= 4'd4;
                end else 
                    nextstate <= 4'd7;
            end
            4'd4: begin
            bigger <= 1'b0;
                if(adder_done)
                    nextstate <= 4'd5;
                else
                    nextstate <= 4'd4;
            end
            4'd5: begin
            bigger <= 1'b0;
                if(adder_done)
                    nextstate <= 4'd6;
                else
                    nextstate <= 4'd5;
            end
            4'd6: begin
                bigger <= 1'b0;
                nextstate <= 4'd3;

            end
            4'd7: begin
                if(adder_done) begin
                    if(regoutadder_D[1027]) begin // negative so smaller than M
                        nextstate <= 4'd8;
                        bigger <= 1'b0;
                        end
                    else begin
                        nextstate <= 4'd7;
                        bigger <= 1'b1;
                    end 
                end else begin
                    nextstate <= 4'd7;
                    bigger <= 1'b0;
                end
            end
            4'd8: begin
                bigger <= 1'b0;
                nextstate <= 4'd0;
            end
            default: begin
            bigger <= 1'b0;
                nextstate <= 4'd0;
            end
        endcase
    end

    reg first_add;
    reg second_add;
    reg shift_activate;
    reg sub_sent;
    reg M_sent;
    reg B_sent;

    // NEED TO EXTEND FSM WITH SOME CLOCKED SIGNAL FOR STARTING SOME ADDITION
    always @(posedge clk) begin
        case (state)
            4'd0: begin
                M_sent <= 1'b0;
                B_sent <= 1'b0;
            end
            4'd1: begin
                if(~M_sent) begin
                    start_123data <= 1'b1;
                    M_sent <= 1'b1;
                end else 
                    start_123data <= 1'b0;
            end
            4'd2: begin
                if(~B_sent) begin
                    start_123data <= 1'b1;
                    B_sent <= 1'b1;
                end else 
                    start_123data <= 1'b0;
            end
            4'd3: begin 
                //shift_A <= 1'b0;
                first_add <= 1'b0;
                second_add <= 1'b0;
                shift_activate <= 1'b0;
                start_adder <= 1'b1;
            end
            4'd4: begin 
                start_adder <= adder_done;
            end 
            4'd5: begin 
                if(~second_add) begin
                    shift_A <= 1'b1; // put here too cause lsb_a is just needed for 4'd4
                    start_adder <= 1'b0; // REMOVED
                    second_add <= 1'b1;
                end else begin
                    shift_A <= 1'b0;
                    start_adder <= 1'b0;
                end 
            end
            4'd6: begin 
                
                i <= i + 2;
            end
            4'd7: begin 
                if(~sub_sent || bigger) begin
                    start_adder <= 1'b1;
                    sub_sent <= 1'b1;
                end else begin
                    start_adder <= 1'b0;
                end
            end
            default: begin
                // Reset of the addition signals
                i <= 10'd0; // reset counter
                first_add <= 1'b0;
                second_add <= 1'b0;
                shift_activate <= 1'b0;
                sub_sent <= 1'b0;
            end
        endcase
    end

    reg regDone;
    always @(posedge clk)
    begin
        if(~resetn) regDone <= 1'd0;
        else        regDone <= (state==4'd8) ? 1'b1 : 1'b0;
    end

    assign done = regDone;


endmodule