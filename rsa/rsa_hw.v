`timescale 1ns / 1ps


module five_multiplexer(
    input           clk,
    input [1023:0]  x,
    input [1023:0]  r2modm,
    input [1023:0]  A,
    input [1023:0]  x_tilde,
    input [2:0]     sele,
    input [2:0]     state,
    output reg [1023:0] out1,
    output reg [1023:0] out2,
    output reg [1023:0] out3,
    output reg [1023:0] out4
    );
    reg [1023:0] one;

    // I don't mind having more FF used than LUTs as FF are cheaper on the xilinx than LUTs
    always @(posedge clk) begin
        one <= 1023'd1;
        
  
    if (state == 3'd0 || state == 3'd1) begin
        out3 <= x;
        out4 <= r2modm;
    end else if (state == 3'd4) begin
        out3 <= A;
        out4 <= 1;
    end else begin
        if (~sele) begin //sele == 1'b0
            out1 <= A;
            out2 <= A;
            out3 <= A;
            out4 <= x_tilde;
        end else if (sele) begin //sele == 1'b1
            out1 <= x_tilde;
            out2 <= x_tilde;
            out3 <= A;
            out4 <= x_tilde;
        end else begin
            out1 <= 1024'b0;
            out2 <= 1024'b0;
            out3 <= 1024'b0;
            out4 <= 1024'b0;
        end
    end
end
endmodule

module monts_done_pulse (
    input  wire clk,               
    input  wire resetn,            
    input  wire montsq_done,      
    input  wire montmult_done,     
    output reg  monts_done         // Output signal
);

    // Internal registers to track states of montsq_done and montmult_done
    reg montsq_done_flag;
    reg montmult_done_flag;

    always @(posedge clk) begin
            // Latch the signals once they go high
            if (montsq_done) begin
                montsq_done_flag <= 1'b1;
                end
                
            if (montmult_done) begin
                montmult_done_flag <= 1'b1;
                end
            // Check if both signals have been high
            if (montsq_done_flag && montmult_done_flag) begin
                monts_done <= 1'b1;  // Set monts_done high

                // Reset the flags
                montsq_done_flag  <= 1'b0;
                montmult_done_flag <= 1'b0;
            end else begin
                monts_done <= 1'b0; // Reset monts_done if conditions are not met
            end
    end

endmodule


module rsa_hw (
    input clk,
    input resetn,
    input wire [1023:0] N_Q,
    input wire [1023:0] R_N_Q,
    input wire [1023:0] R2_N_Q,
    input wire [1023:0] M,
    input wire [31:0]   t,
    input wire [31:0]   t_len,
    input wire [31:0]   command,
    output wire [1023:0] dma_tx_address,
    output wire [31:0] rout0
);
    
//counter  
  reg [31:0] i; // enough bits to store
  reg i_int;
  always@(*)begin
  
    if(monts_done) begin //first stage only montmult is used, after that also montsq. done simultaneously however
        i = i + 1;
    end else if (i_int) begin
        i <= 32'b0; //starting at minus one to compensate for the first preparation cycle
    end
  end
  
  //selector
    wire sele;
    assign sele = t[t_len - i];
    
    reg [2:0] state_mont, nextstate_mont;

  // A register
    reg A_en;
    reg A_int;
    reg [1023:0] A_Q;
    wire [1023:0] A_D;
    always @(posedge clk) begin
        if(A_en) begin
            if(A_int) begin
                A_Q <= R_N_Q; //initialize with R_N_Q
            end
            
            if(state_mont != 3'd1) begin //no reset in the prep stage
                if(state_mont == 3'd4) begin
                    if(montmult_done) begin
                        A_Q <= A_D;
                    end
                end
                if(~(state_mont == 3'd4)) begin
                    if(sele) begin
                        if(montmult_done) begin
                            A_Q <= A_D;
                        end
                    end
                    else if(~sele) begin
                        if(montsq_done) begin
                            A_Q <= A_D;
                        end
                    end
                end
            end
        end
    end
    
    
    reg x_tilde_en;
    reg [1023:0] x_tilde_Q;
    wire [1023:0] x_tilde_D;
    always @(posedge clk) begin
        if(x_tilde_en) begin
            if(state_mont == 3'd0 || state_mont == 3'd1) begin //no reset in the prep stage
                    if(montmult_done) begin
                        x_tilde_Q <= x_tilde_D;
                    end
            end
            if(~(state_mont == 3'd0 || state_mont == 3'd1)) begin //no reset in the prep stage
                if(sele) begin
                    if(montsq_done) begin
                        x_tilde_Q <= x_tilde_D;
                    end
                end
                else if(~sele) begin
                    if(montmult_done) begin
                        x_tilde_Q <= x_tilde_D;
                    end
                end
            end
        end
    end
  
  wire [1023:0] operand_A1;
  wire [1023:0] operand_B1;
  wire [1023:0] operand_A2;
  wire [1023:0] operand_B2;
  five_multiplexer multiplexer(clk, M, R2_N_Q, A_Q, x_tilde_Q, sele, nextstate_mont, operand_A1, operand_B1, operand_A2, operand_B2);
  
  //Montgomery blocks//
  monts_done_pulse monts_done_flag(clk, resetn, montsq_done, montmult_done, monts_done); //flag generator for montgomeries to start simultaneously
  
  reg reg_monts_start;
  assign monts_start = reg_monts_start;

  wire [1023:0] montsq_out;
  wire [1023:0] montmult_out;
  
// Instantiating montgomery module
montgomery montsquare (
    .clk      (clk          ), // Clock signal
    .resetn   (resetn       ), // Active low reset
    .start    (monts_start  ), // Start signal for Montgomery operation
    .in_a     (operand_A1   ), // Operand A input
    .in_b     (operand_B1   ), // Operand B input
    .in_m     (N_Q          ), // Modulus input
    .result   (montsq_out   ), // Result output
    .done     (montsq_done  )  // Done signal output
);
  
montgomery montmult (
    .clk      (clk          ), // Clock signal
    .resetn   (resetn       ), // Active low reset
    .start    (monts_start  ), // Start signal for Montgomery operation
    .in_a     (operand_A2   ), // Operand A input
    .in_b     (operand_B2   ), // Operand B input
    .in_m     (N_Q          ), // Modulus input
    .result   (montmult_out ), // Result output
    .done     (montmult_done)  // Done signal output
);

  
  //Multiplexers x_tilde & A//
assign x_tilde_D = (state_mont == 3'd0 || state_mont == 3'd1) ? montmult_out : (sele) ?  montsq_out : montmult_out; //State_mont condition for initializing x_tilde
assign A_D = (state_mont == 3'd4) ? montmult_out : (sele) ?  montmult_out : montsq_out;  //State_mont condition for translating A
  //                        //
  

  
     // FSM
    always @(posedge clk) begin
        if(~resetn) state_mont <= 3'd0;
        else        state_mont <= nextstate_mont;
    end
 // State switch
    always @(*) begin
        case (state_mont)
            3'd0 : begin
                if(command) begin
                    nextstate_mont <= 3'd1;
                end else begin
                    nextstate_mont <= 3'd0;
                end
            end
            3'd1 : begin
            if(monts_done) begin
                    nextstate_mont <= 3'd2;
                end else begin
                    nextstate_mont <= 3'd1;
                end
            end
            3'd2 : begin 
                if(monts_done) begin
                nextstate_mont <= 3'd3;
                end else begin
                nextstate_mont <= 3'd2;
                end
            end
            3'd3 : begin
                if(i-1 >= t_len) begin
                    nextstate_mont <= 3'd4;// we should still add something with that the result is stored in memory here
                end else begin
                    nextstate_mont <= 3'd2;
                end
            end
            3'd4 : begin
                if(montmult_done) begin 
                    nextstate_mont <= 3'd5;
                end else begin
                    nextstate_mont <= 3'd4;
                end
            end
            3'd5 : begin
                 nextstate_mont <= 3'd0;
            end
            default: 
                nextstate_mont <= 3'd0;
        endcase
    end
 
    //(de-)enabling
     always @(*) begin
        case (state_mont)
            3'd0: begin
            A_int <= 1'b1;
            i_int <= 1'b1;
            x_tilde_en <= 1'b0;
            A_en <= 1'b1;
            end
            3'd1: begin
            A_int <= 1'b0;
            x_tilde_en <= 1'b1;
            i_int <= 1'b0;
            A_en <= 1'b1;
            end
            3'd2: begin
            A_int <= 1'b0;
            x_tilde_en <= 1'b1;
            A_en <= 1'b1;
            end
            3'd3: begin
            end
            3'd4: begin
            end
            3'd5: begin
            end
            default: begin
            end
        endcase
    end

//pulse generator for montgomery multiplication
    reg command_d;    // Delayed version of STATE_COMPUTE

    always @(posedge clk) begin
        // Store the previous states of STATE_COMPUTE and montmult_done
        command_d <= command;

        // Generate reg_mont_start pulse on rising edge of STATE_COMPUTE or montmult_done
        if(state_mont != 3'd4) begin
            reg_monts_start <= (command & ~command_d) | (monts_done);
        end
    end

    reg regDone;
    always @(posedge clk)
    begin
        if(~resetn) regDone <= 1'd0;
        else        regDone <= (state_mont==3'd5) ? 1'd1 : 1'b0;
    end

assign dma_tx_address = montmult_out;
assign rout0 = regDone;

/*

    // Here is a register for the computation. Sample the dma data input in
  // STATE_RX_WAIT. Update the data with a dummy operation in STATE_COMP.
  // In this example, the dummy operation sets most-significant 32-bit to zeros.
  // Use this register also for the data output.
  reg [1023:0] r_data = 1024'h0;
  always@(posedge clk)
    case (state)
      STATE_RX_WAIT : r_data <= (dma_done) ? dma_rx_data : r_data;
      STATE_COMPUTE : r_data <= {32'h0BADCAFE, r_data[991:0]};
    endcase
  assign dma_tx_data = r_data;

  
  
  // In this example we have only one computation command.
  wire isCmdComp = (command == 32'd1);
  wire isCmdIdle = (command == 32'd0);
  
  // command to check if receiving save data
  wire isCmdSave = (loading_data != 32'd0);

    
  always@(*) begin
    // defaults
    next_state   <= STATE_IDLE;

    // state defined logic
    case (state)
      // Wait in IDLE state till a compute command
      STATE_IDLE: begin
        next_state <= (isCmdComp || isCmdSave) ? STATE_RX : state;
      end

      // Wait, if dma is not idle. Otherwise, start dma operation and go to
      // next state to wait its completion.
      STATE_RX: begin
        next_state <= (~dma_idle) ? STATE_RX_WAIT : state;
      end

      // Wait the completion of dma.
      STATE_RX_WAIT : begin
        next_state <= (dma_done) ? (isCmdComp) ? STATE_COMPUTE : STATE_SAVE : state;
      end
      
      // Saving the dma data in various registers
      STATE_SAVE : begin
        next_state <= STATE_DONE;           
      end

      // A state for dummy computation for this example. Because this
      // computation takes only single cycle, go to TX state immediately
      STATE_COMPUTE : begin
        next_state <= STATE_TX;
      end

      // Wait, if dma is not idle. Otherwise, start dma operation and go to
      // next state to wait its completion.
      STATE_TX : begin
        next_state <= (~dma_idle) ? STATE_TX_WAIT : state;
      end

      // Wait the completion of dma.
      STATE_TX_WAIT : begin
        next_state <= (dma_done) ? STATE_DONE : state;
      end

      // The command register might still be set to compute state. Hence, if
      // we go back immediately to the IDLE state, another computation will
      // start. We might go into a deadlock. So stay in this state, till CPU
      // sets the command to idle. While FPGA is in this state, it will
      // indicate the state with the status register, so that the CPU will know
      // FPGA is done with computation and waiting for the idle command.
      STATE_DONE : begin
        next_state <= (isCmdIdle && ~isCmdSave) ? STATE_IDLE : state;
      end

    endcase
  end
  
  always@(posedge clk) begin
    dma_rx_start <= 1'b0;
    dma_tx_start <= 1'b0;
    case (state)
      STATE_RX: dma_rx_start <= 1'b1;
      STATE_TX: dma_tx_start <= 1'b1;
    endcase
  end

  // Synchronous state transitions
  always@(posedge clk)
    state <= (~resetn) ? STATE_IDLE : next_state;

  
  wire isStateIdle = (state == STATE_IDLE);
  wire isStateDone = (state == STATE_DONE);
  assign status = {26'b0, loading_data[3:0], dma_error, isStateIdle, isStateDone};
  */
  
endmodule

