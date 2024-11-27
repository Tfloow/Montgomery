`include "montgomery.v"

module rsa (
    input  wire          clk,
    input  wire          resetn,
    output wire   [ 3:0] leds,

    // input registers                     // output registers
    input  wire   [31:0] rin0,             output wire   [31:0] rout0,
    input  wire   [31:0] rin1,             output wire   [31:0] rout1,
    input  wire   [31:0] rin2,             output wire   [31:0] rout2,
    input  wire   [31:0] rin3,             output wire   [31:0] rout3,
    input  wire   [31:0] rin4,             output wire   [31:0] rout4,
    input  wire   [31:0] rin5,             output wire   [31:0] rout5,
    input  wire   [31:0] rin6,             output wire   [31:0] rout6,
    input  wire   [31:0] rin7,             output wire   [31:0] rout7,

    // dma signals
    input  wire [1023:0] dma_rx_data,      output wire [1023:0] dma_tx_data,
    output wire [  31:0] dma_rx_address,   output wire [  31:0] dma_tx_address,
    output reg           dma_rx_start,     output reg           dma_tx_start,
    input  wire          dma_done,
    input  wire          dma_idle,
    input  wire          dma_error
  );

  // In this example three input registers are used.
  // The first one is used for giving a command to FPGA.
  // The others are for setting DMA input and output data addresses.
  wire [31:0] command;
  wire [31:0] t;
  wire [31:0] t_len;
  wire [31:0] loading_data;
  assign command        = rin0; // use rin0 as command
  assign dma_rx_address = rin1; // use rin1 as input  data address
  assign dma_tx_address = rin2; // use rin2 as output data address
  assign t = rin3;
  assign t_len = rin4;
  assign loading_data = rin5;

  // Only one output register is used. It will the status of FPGA's execution.
  wire [31:0] status;
  assign rout0 = status; // use rout0 as status
  assign rout1 = 32'b0;  // not used
  assign rout2 = 32'b0;  // not used
  assign rout3 = 32'b0;  // not used
  assign rout4 = 32'b0;  // not used
  assign rout5 = 32'b0;  // not used
  assign rout6 = 32'b0;  // not used
  assign rout7 = 32'b0;  // not used
  
    // define status
  localparam
    STATE_IDLE     = 4'd0,
    STATE_RX       = 4'd1,
    STATE_RX_WAIT  = 4'd2,
    STATE_SAVE     = 4'd7,
    STATE_COMPUTE  = 4'd3,
    STATE_TX       = 4'd4,
    STATE_TX_WAIT  = 4'd5,
    STATE_DONE     = 4'd6;
    
  // The state machine
  reg [2:0] state = STATE_IDLE;
  reg [2:0] next_state;
  
  //// LOADING PART
  
    wire N_en;
    wire R_N_en;
    wire R2_N_en;
    wire [1023:0] save_input;
  
    // registers definition
    // N
    reg [1023:0] N_Q;
    always @(posedge clk) begin
        if(N_en)
            N_Q <= save_input;
    end
    
    // R_N
    reg [1023:0] R_N_Q;
    always @(posedge clk) begin
        if(R_N_en)
            R_N_Q <= save_input;
    end
    
    // R2_N
    reg [1023:0] R2_N_Q;
    always @(posedge clk) begin
        if(R2_N_en)
            R2_N_Q <= save_input;
    end
    
    // control the enabled pin through loading command
    assign N_en    = (loading_data[2:0] == 3'b001 && state != STATE_DONE && state != STATE_SAVE);
    assign R_N_en  = (loading_data[2:0] == 3'b010 && state != STATE_DONE && state != STATE_SAVE);
    assign R2_N_en = (loading_data[2:0] == 3'b011 && state != STATE_DONE && state != STATE_SAVE);
    
    // connect all registers to the dma rx data
    assign save_input = dma_rx_data;
      
  //// RSA PART
  
  //counter  
  reg [31:0] i; // enough bits to store
  always@(*)begin
  
    if(montsq_done || montmult_done) begin //first stage only montmult is used, after that also montsq. done simultaneously however
        i = i + 1;
    end else begin
        i <= 32'b0;
    end
  end
  
  //selector
    wire sele;
    assign sele = t[t_len - i];
    
  // A register
    reg A_en;
    reg A_int;
    reg [1023:0] A_Q;
    wire [1023:0] A_D;
    always @(posedge clk) begin
        if(A_en)
            if(A_int) begin
                A_Q <= R_N_Q;
            end else begin
            A_Q <= A_D;
            end
    end
    
  // x_tilde register
    reg x_tilde_en;
    reg [1023:0] x_tilde_Q;
    wire [1023:0] x_tilde_D;
    always @(posedge clk) begin
        if(x_tilde_en)
            x_tilde_Q <= x_tilde_D;
    end
  
  five_multiplexer multiplexer (clk, x, R2_N_Q, A_Q, x_tilde_Q, sele, state, out1, out2, out3, out4);
  
  reg reg_mont_start;
  assign mont_start = reg_mont_start;
  
  assign operand_A1 = out1;
  assign operand_B1 = out2;
  assign operand_A2 = out3;
  assign operand_B2 = out4;
  assign in_N = N_Q;
  montgomery montsquare(clk, resetn, mont_start, operand_A1, operand_B1, in_N, montsq_out, montsq_done);
  montgomery montmult(clk, resetn, mont_start, operand_A2, operand_B2, in_N, montmult_out, montmult_done);

//choosing depending on state and exponent bit
assign x_tilde_d = (state == 2'd1) ? montmult_out : (sele == 1'b1 ? montsq_out : montmult_out);
assign A_d = (sele == 1'b1) ? montmult_out : montsq_out;  
    
 
     // FSM
    reg [1:0] state, nextstate;
    always @(posedge clk) begin
        if(~resetn) state <= 2'b0;
        else        state <= nextstate;
    end
 // State switch
    always @(*) begin
        case (state)
            2'd0 : begin
                if(STATE_COMPUTE) 
                    nextstate <= 2'd1;
                else
                    nextstate <= 2'd0;
            end
            2'd1 : begin 
                if(montmult_done) begin
                nextstate <= 2'd2;
                end else begin
                nextstate <= 2'd1;
                end
            end
            2'd2 : begin
                if(i >= t_len) begin
                    nextstate <= 2'd3;// we should still add something with that the result is stored in memory here
                end else begin
                    nextstate <= 2'd2;
                end
            end
            2'd3 : begin
                nextstate <= 2'd0;
            end
            default: 
                nextstate <= 2'd0;
        endcase
    end
 
    //(de-)enabling
     always @(*) begin
        case (state)
            2'd0: begin
            A_int <= 1'b1;
            x_tilde_en <= 1'b0;
            A_en <= 1'b1;
            end
            2'd1: begin
            x_tilde_en <= 1'b1;
            A_en <= 1'b1;
            end
            2'd2: begin
            A_int <= 1'b0;
            end
            2'd3: begin
            end
            default: begin
            end
        endcase
    end

//pulse generator for montgomery multiplication
    reg STATE_COMPUTE_d;    // Delayed version of STATE_COMPUTE
    reg montmult_done_d;    // Delayed version of montmult_done

    always @(posedge clk) begin
        // Store the previous states of STATE_COMPUTE and montmult_done
        STATE_COMPUTE_d <= STATE_COMPUTE;
        montmult_done_d <= montmult_done;

        // Generate reg_mont_start pulse on rising edge of STATE_COMPUTE or montmult_done
        reg_mont_start <= (STATE_COMPUTE & ~STATE_COMPUTE_d) | (montmult_done & ~montmult_done_d);
    end

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
  
  
endmodule

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
    // I don't mind having more FF used than LUTs as FF are cheaper on the xilinx than LUTs

    always @(posedge clk) begin
         if(state == 2'd1)begin
         out1 <= x;
         out2 <= r2modm;
         end
         else begin
        case(sele) 
            1'b1:begin
                out1 <= x_tilde;
                out2 <= x_tilde;
                out3 <= A;
                out4 <= x_tilde;
                end
            1'b0:begin
                out1 <= A;
                out2 <= A;
                out3 <= A;
                out4 <= x_tilde;
                end
            default:begin
                out1 <= 1024'b0;
                out2 <= 1024'b0;
                out3 <= 1024'b0;
                out4 <= 1024'b0;
                end
        endcase
    end

