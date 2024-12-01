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
  reg [31:0] counter_clk = 32'b0;
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

  assign rout4 = dma_rx_address;  // not used
  assign rout5 = loading_data;  // not used
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
    wire X_tilde_en;
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
    
    // DBG - Write the LSB to those output register
    assign rout1 = N_Q;  
    assign rout2 = R_N_Q; 
    assign rout3 = R2_N_Q;  
    assign rout6 = state;  // not used

      
  //// RSA PART
    wire start_montgomery;
    wire [1023:0] in_a;
    wire [1023:0] in_b;
    wire [1023:0] in_m;
    wire [1024:0] result;
    wire done_montgomery;
    montgomery mont(clk, resetn, start_montgomery, in_a, in_b, in_m, result, done_montgomery);

    // X_tilde
    reg [1023:0] X_tilde_Q;
    always @(posedge clk) begin
        if(X_tilde_en)
            X_tilde_Q <= result;
    end
      
    
    // In this example we have only one computation command.
    wire isCmdComp = (command == 32'd1);
    wire isCmdIdle = (command == 32'd0);
    // montMul wire
    wire isOneMM = isCmdComp;
    wire isX_TildeMM = (command == 32'h3);
    wire isDMAMM = (command == 32'h5);
    wire isR_2NMM_SAVE = (command == 32'h7);
    wire isX_TildeMM_SAVE = (command == 32'h9);

    assign X_tilde_en = isR_2NMM_SAVE || isX_TildeMM_SAVE;

    reg sent_signal;
    assign start_montgomery = ~sent_signal && state == STATE_COMPUTE;

    assign in_a = dma_rx_data;
    assign in_b = (isOneMM) ? 1024'h1 : ((isX_TildeMM || isX_TildeMM_SAVE) ? X_tilde_Q : ((isR_2NMM_SAVE) ? R2_N_Q : dma_rx_address));
    assign in_m = N_Q;
    assign dma_tx_data = result;
  
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
        next_state <= (done_montgomery) ? STATE_TX : STATE_COMPUTE; // won't stop until montgomery is good
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
    counter_clk <= counter_clk + 1;
    dma_rx_start <= 1'b0;
    dma_tx_start <= 1'b0;
    sent_signal <= sent_signal;
    case (state)
      IDLE: sent_signal <= 1'b0;
      STATE_RX: dma_rx_start <= 1'b1;
      STATE_COMPUTE : sent_signal <= 1'b1;
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
