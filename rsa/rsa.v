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
    wire R2_N_en;
    wire [1023:0] save_input;
  
    // registers definition
    // N
    reg [1023:0] N_Q;
    always @(posedge clk) begin
        if(N_en)
            N_Q <= save_input;
    end
    
    // R2_N
    reg [1023:0] R2_N_Q;
    always @(posedge clk) begin
        if(R2_N_en)
            R2_N_Q <= save_input;
    end

    // control the enabled pin through loading command
    assign N_en    = (loading_data[2:0] == 3'b001 && state != STATE_DONE && state != STATE_SAVE);
    //assign R_N_en  = (loading_data[2:0] == 3'b010 && state != STATE_DONE && state != STATE_SAVE);
    assign R2_N_en = (loading_data[2:0] == 3'b011 && state != STATE_DONE && state != STATE_SAVE);
    
    // connect all registers to the dma rx data
    assign save_input = dma_rx_data;
    


      
  //// RSA PART
    wire start_montgomery;
    wire [1023:0] in_a;
    wire [1023:0] in_b;
    wire [1023:0] in_m;
    wire [1023:0] result;
    wire done_montgomery;
    montgomery mont(clk, resetn, start_montgomery, in_a, in_b, in_m, result, done_montgomery);

    // X_tilde
    wire X_tilde_en;
    reg [1023:0] X_tilde_Q;
    wire [1023:0] X_tilde_D;
    always @(posedge clk) begin
        if(X_tilde_en)
            X_tilde_Q <= X_tilde_D;
    end
    
    // A
    wire A_en;
    reg [1023:0] A_Q;
    wire [1023:0] A_D;
    always @(posedge clk) begin
        if(A_en)
            A_Q <= A_D;
    end
      
    /*
      CHANGE TO THE API
      COMMAND :
        0b0001 : 0x01 : MontMul(DMA, X_tilde, N)
        0b0011 : 0x03 : MontMul(DMA, DMA, N)
        0b0101 : 0x05 : MontMul(DMA, 1, N)
        Write to registers commands
        0b1001 : 0x09 : MontMul(DMA, R2N, N)
        0b1011 : 0x0B : MontMul(X_tilde, X_tilde, N)
        0b1101 : 0x0D : MontMUl(DMA, X_tilde, N)
     */
    // In this example we have only one computation command.
    // montMul wire
    // No writing to X_tilde
    wire isXtildeMM = (command == 32'h1);
    wire isDMAMM = (command == 32'h3);
    wire isOne = (command == 32'h5);
    // Writing to X_tilde
    wire isR_2NMM_SAVE = (command == 32'h9);
    wire isX_TildeMM_SAVE = (command == 32'hB);
    wire isDMA_SAVE = (command == 32'hD);
    
    wire isCmdComp = isXtildeMM || isDMAMM || isOne || isR_2NMM_SAVE || isX_TildeMM_SAVE || isDMA_SAVE;
    wire isCmdIdle = ~isCmdComp;
    wire saveXTilde = isR_2NMM_SAVE || isX_TildeMM_SAVE || isDMA_SAVE;
    wire saveA = isXtildeMM || isDMAMM || isOne;
    
    // When we need to update the X_tilde
    assign X_tilde_en = saveXTilde & dma_done;    
    assign X_tilde_D  = (state != STATE_TX_WAIT && state != STATE_TX && state != STATE_DONE) ? dma_rx_data : result;
    
    assign A_en = saveA & dma_done;
    assign A_D  = (state != STATE_TX_WAIT && state != STATE_TX && state != STATE_DONE) ? dma_rx_data : result;

    reg sent_signal;
    assign start_montgomery = ~sent_signal && state == STATE_COMPUTE;

    assign in_a = (isX_TildeMM_SAVE || isR_2NMM_SAVE) ? X_tilde_Q : A_Q;
    assign in_b = isDMAMM ? in_a : (isOne ? 1024'h1 : (isR_2NMM_SAVE ? R2_N_Q : X_tilde_Q)); 
    assign in_m = N_Q;
    assign dma_tx_data = result; // to avoid over writing
    // I MAY USE TOOOOOO MANY LUTS LOL
  
  // command to check if receiving save data
  wire isCmdSave = (loading_data != 32'd0);
  
      // DBG - Write the LSB to those output register
    assign rout1 = in_a[31:0];  
    assign rout2 = in_b[31:0]; 
    assign rout3 = in_m[31:0];  
    assign rout4 = result[31:0];  // not used
    assign rout5 = A_Q[31:0];  // not used
    assign rout6 = X_tilde_Q[31:0];  // not used
    assign rout7 = dma_rx_data[31:0];  // not used

    
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
      STATE_IDLE: sent_signal <= 1'b0;
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