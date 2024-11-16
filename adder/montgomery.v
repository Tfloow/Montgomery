`timescale 1ns / 1ps
`include "adder.v"

module seven_multiplexer(
    input           clk,
    input [1026:0]  in_M,
    input [1026:0]  in_2M,
    input [1026:0]  in_3M,
    input [1026:0]  in_B,
    input [1026:0]  in_2B,
    input [1026:0]  in_3B,
    input [2:0]     select,
    output[1026:0] out
    );

    assign out = (select == 3'b001) ? in_B : ((select == 3'b010) ? in_2B : ((select == 3'b011) ? in_3B : (select == 3'b100) ? in_M : ((select == 3'b101) ? in_2M : ((select == 3'b110) ? in_3M : 1027'b0))));

endmodule

module seven_multiplexer_reg(
    input           clk,
    input [1026:0]  in_M,
    input [1026:0]  in_2M,
    input [1026:0]  in_3M,
    input [1026:0]  in_B,
    input [1026:0]  in_2B,
    input [1026:0]  in_3B,
    input [2:0]     select,
    output reg [1026:0] out
    );
    // I don't mind having more FF used than LUTs as FF are cheaper on the xilinx than LUTs

    always @(select) begin
        case(select)
            3'b001:
                out = in_B;
            3'b010:
                out = in_2B;
            3'b011:
                out = in_3B;
            3'b100:
                out = in_M;
            3'b101:
                out = in_2M;
            3'b110:
                out = in_3M;
            default:
                out = 1028'b0;
        endcase
    end

endmodule

module shift_register_two(
    input           clk,
    input [1027:0]  in_number,
    input           shift,
    input           restn,
    input           enable,
    output reg [1027:0] out_shift,
    output wire        shift_done);
    
    reg [1027:0] current_number;
    reg regDone; reg delayRegDone;
    
    assign shift_done = regDone;
    
    // The brain of the shift register
    always @ (posedge clk) begin
    // Reset
        if(~restn) begin
            current_number <= 1028'b0;
            out_shift <= 1028'b0;
            regDone = 1'b0;
        end
        // writing to memory
        else if(enable) begin
            current_number <= in_number;
            // already outputing 
            out_shift <= in_number;
            regDone <= 1'b0;
        end
        
        // shifting
        if(shift) begin
            out_shift <= (current_number >> 2);
            current_number <= (current_number >> 2);
            regDone <= 1'b1;
        end else 
            regDone <= 1'b0;

        // delay done
        //regDone <= delayRegDone;
    end
    
endmodule

module shift_register(
    input           clk,
    input [1023:0]  in_number,
    input           shift,
    input           restn,
    input           enable,
    output reg [1024:0] out_shift,
    output wire        shift_done);
    
    reg [1024:0] current_number;
    reg regDone; reg delayRegDone;
    
    assign shift_done = regDone;
    
    // The brain of the shift register
    always @ (posedge clk) begin
    // Reset
        if(~restn) begin
            current_number <= 1025'b0;
            out_shift <= 1025'b0;
            regDone = 1'b0;
        end
        
        // writing to memory
        if(enable) begin
            current_number <= in_number;
            regDone <= 1'b0;
        end
        
        // shifting
        if(shift) begin
            out_shift <= (current_number << 1);
            regDone <= 1'b1;
        end

        if(regDone)
            regDone <= 1'b0;
    end
    
endmodule



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

    // Definition register 2B 
    wire  [1026:0] reg2B_Q;   // out
    assign reg2B_Q = in_b << 1;

  
    // Definition register 3B 
    reg          reg3B_en;   
    wire [1026:0] reg3B_D;   // in
    reg  [1026:0] reg3B_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg3B_Q = 1027'd0;
        else if (reg3B_en)   reg3B_Q <= reg3B_D;
    end    
    
    // Definition register 2M
    wire  [1026:0] reg2M_Q;   // out
    assign reg2M_Q = in_m << 1;

    
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
    wire [1027:0] regoutadder_D;   // in

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
    assign reg3M_D = operand_out3M;
    assign reg3B_D = operand_out3B;

    // Create the Mux_M_B
    wire [1026:0] out_mux_m_b;
    reg mux_m_b_sel;
    assign out_mux_m_b = (mux_m_b_sel) ? in_b : in_m;

    assign operand_outB = out_1MB;
    assign operand_outM = out_1MB;

    assign operand_out2B = out_2MB;
    assign operand_out2M = out_2MB;

    assign operand_out3B = out_3MB;
    assign operand_out3M = out_3MB;
    
    reg start_123data;
    wire prep_done;
    //shift will start when start is put to 1'b1;            
    //shift_add_123   shiftMB(clk, out_mux_m_b, start_123data, resetn, prep_done, out_1MB, out_2MB, out_3MB); //initializes wires adder
    // rewrite to only use 1 adder
    assign out_1MB =out_mux_m_b;
    assign out_2MB = out_1MB << 1;
    
    // design the multiplexer
    reg [2:0] select_multi;
    wire [1026:0] out_multi;
    seven_multiplexer_reg multi(clk, {3'b0, in_m}, reg2M_Q, reg3M_Q, {3'b0, in_b}, reg2B_Q, reg3B_Q, select_multi, out_multi);

    //reg initialization A and B for addition
    wire  [1026:0] operand_A;   // out
    wire  [1026:0] operand_B;   // out
    reg loop_sel;
    assign operand_B = (loop_sel) ? out_multi : out_2MB;
    
  
    //adder initialization      
    reg subtract;
    wire adder_done;
    reg start_adder;
    wire [1027:0] output_adder;
    reg reset_adder;
    mpadder adder(clk, resetn && reset_adder, start_adder, subtract, operand_A, operand_B, output_adder, adder_done); //initializes wires adder

    //Shifter initialization 
    reg   shift;
    wire  [1027:0] out_shift;
    reg   enable_shifter;
  
    assign operand_A = (loop_sel) ? out_shift : out_1MB;
    // Demux
    assign {out_3MB, regoutadder_D} = (loop_sel) ? {1028'b0, output_adder} : {output_adder, 1028'b0};

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

    reg [3:0] state;
    reg [3:0] nextstate;

    always @(posedge clk) begin
        if(~resetn)	state <= 4'd0;
        else        state <= nextstate;
    end


    reg [1:0] DBG_cond; // to be REMOVED

    //FSM
    always @(*) begin
        case (state)
            4'd0: begin
                reset_adder     <= 1'b1;
                // reg stop
                reg3M_en        <= 1'b0;

                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'd0;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b0;
                shift_A         <= 1'b0;
            end 
            4'd1: begin
                reset_adder     <= 1'b1;
                // saving the new data for M
                reg3M_en        <= 1'b1;

                reg3B_en        <= 1'b0;

                enable_A        <= 1'b1;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'd0;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b0;
                shift_A         <= 1'b0;
            end 
            4'd2: begin
                reset_adder     <= 1'b1;
                // Saving the data for B
                reg3M_en        <= 1'b0;

                reg3B_en        <= 1'b1;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'd0;
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b1;
                shift           <= 1'b0;
                loop_sel        <= 1'b0;
                shift_A         <= 1'b0;
            end 
            4'd11: begin
                reset_adder     <= 1'b0;
                // New data saved stop saving
                reg3M_en        <= 1'b0;

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
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end
            4'd3: begin
                reset_adder     <= 1'b1;
                // New data saved stop saving
                reg3M_en        <= 1'b0;

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
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end 
            4'd4: begin // First addition C = C + out_shifted_A[1:0] * B
                reset_adder     <= 1'b1;
                // New data saved stop saving
                reg3M_en        <= 1'b0;

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
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
            end  
            4'd5: begin
                reset_adder     <= 1'b1;
                // New data saved stop saving
                reg3M_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO
                enable_shifter  <= 1'b1;

                regresult_en    <= 1'b1;

                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b1;
                shift_A         <= 1'b1;

                // multiplexer stop
                if((operand_A[1:0] == 2'b01 && in_m[1:0] == 2'b01) || (operand_A[1:0] == 2'b11 && in_m[1:0] == 2'b11)) begin
                    select_multi <= 3'b110;
                    DBG_cond <= 2'd1;
                    end 
                else begin 
                    if((operand_A[1:0] == 2'b10 && in_m[1:0] == 2'b01) || (operand_A[1:0] == 2'b10 && in_m[1:0] == 2'b11)) begin
                        select_multi <= 3'b101;
                        DBG_cond <= 2'd2;
                        end
                    else begin 
                        if((operand_A[1:0] == 2'b11 && in_m[1:0] == 2'b01) || (operand_A[1:0] == 2'b01 && in_m[1:0] == 2'b11)) begin
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
            4'd6: begin 
                reset_adder     <= 1'b1;
                // New data saved stop saving
                reg3M_en        <= 1'b0;
                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;
                // everything above shouldn't be changed IMO
                enable_shifter  <= 1'b1;

                regresult_en    <= 1'b1;

                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;

                // multiplexer stop
                if((operand_A[1:0] == 2'b01 && in_m[1:0] == 2'b01) || (operand_A[1:0] == 2'b11 && in_m[1:0] == 2'b11)) begin
                    select_multi <= 3'b110;
                    DBG_cond <= 2'd1;
                    end 
                else begin 
                    if((operand_A[1:0] == 2'b10 && in_m[1:0] == 2'b01) || (operand_A[1:0] == 2'b10 && in_m[1:0] == 2'b11)) begin
                        select_multi <= 3'b101;
                        DBG_cond <= 2'd2;
                        end
                    else begin 
                        if((operand_A[1:0] == 2'b11 && in_m[1:0] == 2'b01) || (operand_A[1:0] == 2'b01 && in_m[1:0] == 2'b11)) begin
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
            4'd7: begin
                reset_adder     <= 1'b1;
                                // New data saved stop saving
                reg3M_en        <= 1'b0;

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
                shift           <= 1'b1;
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end 
            4'd8: begin
                reset_adder     <= 1'b1;
                // New data saved stop saving
                reg3M_en        <= 1'b0;

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
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
                // I redesign the seven_multiplexer to make the select_multi more handy ;))
            end 
            4'd9: begin // re add to the result
                reset_adder     <= 1'b1;
                reg3M_en        <= 1'b0;

                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'b100; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
            end 
            4'd10: begin // finish
                reset_adder     <= 1'b1;
                reg3M_en        <= 1'b0;

                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b1;


                // multiplexer stop
                select_multi    <= 3'b0; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
            end 
            default: begin
                reset_adder     <= 1'b1;
                reg3M_en        <= 1'b0;

                reg3B_en        <= 1'b0;

                enable_A        <= 1'b0;

                enable_shifter  <= 1'b0;

                regresult_en    <= 1'b0;


                // multiplexer stop
                select_multi    <= 3'b0; 
                subtract        <= 1'b0;
                mux_m_b_sel     <= 1'b0;
                shift           <= 1'b0;
                loop_sel        <= 1'b1;
                shift_A         <= 1'b0;
            end 
        endcase
    end

    reg bigger;
    reg [2:0] state4_counter;
    reg [2:0] state6_counter;

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
                if(adder_done)
                    nextstate <= 4'd2;
                else 
                    nextstate <= 4'd1;
            end
            4'd2: begin
            bigger <= 1'b0;
                if(adder_done)
                    nextstate <= 4'd11;
                else 
                    nextstate <= 4'd2;
            end
            4'd11: begin
                bigger <= 1'b0;
                nextstate <= 4'd3;
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
                if(state4_counter >= 3'd1)
                    nextstate <= 4'd5;
                else
                    nextstate <= 4'd4;
            end
            4'd5: begin
                bigger <= 1'b0;
                nextstate <= 4'd6;
            end
            4'd6: begin
                bigger <= 1'b0;
                if(state6_counter >= 3'd1)
                    nextstate <= 4'd3;
                else
                    nextstate <= 4'd6;

            end
            4'd7: begin
                if(adder_done) begin
                    if(regoutadder_D[1027]) begin // negative so smaller than M
                        nextstate <= 4'd9;
                        bigger <= 1'b0;
                        end
                    else begin
                        nextstate <= 4'd8;
                        bigger <= 1'b1;
                    end
                end
                else begin
                    nextstate <= 4'd7;
                    bigger <= 1'b0;
                end
            end
            4'd8: begin
                if(adder_done) begin
                    if(regoutadder_D[1027]) begin // negative so smaller than M
                        nextstate <= 4'd9;
                        bigger <= 1'b0;
                        end
                    else begin
                        nextstate <= 4'd8;
                        bigger <= 1'b1;
                    end 
                end else begin
                    nextstate <= 4'd8;
                    bigger <= 1'b0;
                end
            end
            4'd9: begin
                bigger <= 1'b0;
                if(adder_done)
                    nextstate <= 4'd10;
                else 
                    nextstate <= 4'd9;
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
                start_adder <= 1'b0;
            end
            4'd1: begin
                if(~M_sent) begin
                    start_adder <= 1'b1;
                    M_sent <= 1'b1;
                end else 
                    start_adder <= 1'b0;
            end
            4'd2: begin
                if(~B_sent) begin
                    start_adder <= 1'b1;
                    B_sent <= 1'b1;
                end else begin
                    start_123data <= 1'b0;
                    start_adder <= 1'b0;
                end
            end
            4'd11: begin 
                start_adder <= 1'b0;
            end
            4'd3: begin 
                start_adder <= 1'b1;
                i <= i + 2;
                state4_counter <= 3'b0;
                state6_counter <= 3'b0;
            end
            4'd4: begin
                start_adder <= 1'b0;
                state4_counter <= state4_counter + 1;
            end
            4'd5: begin
                start_adder <= 1'b1;
            end
            4'd6: begin
                start_adder <= 1'b0;
                state6_counter <= state6_counter + 1;
            end

            4'd7: begin 
                start_adder  <= 1'b0;
                sub_sent <= 1'b0;
            end
            4'd8: begin 
                if(~sub_sent || bigger) begin
                    start_adder <= 1'b1;
                    sub_sent <= 1'b1;
                end else begin
                    start_adder <= 1'b0;
                end
            end
            4'd9: begin 
                if(~first_add) begin 
                    start_adder <= 1'b1;
                    first_add <= 1'b1;
                end else
                    start_adder <= 1'b0;
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
        else        regDone <= (state==4'd10) ? 1'b1 : 1'b0;
    end

    assign done = regDone;


endmodule