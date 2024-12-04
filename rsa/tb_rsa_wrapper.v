`timescale 1ns / 1ps

`define HUGE_WAIT   300
`define LONG_WAIT   100
`define RESET_TIME   25
`define CLK_PERIOD   10
`define CLK_HALF      5

module tb_rsa_wrapper();
    
  reg           clk         ;
  reg           resetn      ;
  wire          leds        ;

  reg  [16:0]   mem_addr    = 'b0 ;
  reg  [1023:0] mem_din     = 'b0 ;
  wire [1023:0] mem_dout    ;
  reg  [127:0]  mem_we      = 'b0 ;

  reg  [ 11:0] axil_araddr  ;
  wire         axil_arready ;
  reg          axil_arvalid ;
  reg  [ 11:0] axil_awaddr  ;
  wire         axil_awready ;
  reg          axil_awvalid ;
  reg          axil_bready  ;
  wire [  1:0] axil_bresp   ;
  wire         axil_bvalid  ;
  wire [ 31:0] axil_rdata   ;
  reg          axil_rready  ;
  wire [  1:0] axil_rresp   ;
  wire         axil_rvalid  ;
  reg  [ 31:0] axil_wdata   ;
  wire         axil_wready  ;
  reg  [  3:0] axil_wstrb   ;
  reg          axil_wvalid  ;
  
  // PERSONAL DEBUG
  reg [15:0] i;
  reg [15:0] E;
  wire condition_DBG;
  
  assign condition_DBG = E >> (15-i);
      
  tb_rsa_project_wrapper dut (
    .clk                 ( clk           ),
    .leds                ( leds          ),
    .resetn              ( resetn        ),
    .s_axi_csrs_araddr   ( axil_araddr   ),
    .s_axi_csrs_arready  ( axil_arready  ),
    .s_axi_csrs_arvalid  ( axil_arvalid  ),
    .s_axi_csrs_awaddr   ( axil_awaddr   ),
    .s_axi_csrs_awready  ( axil_awready  ),
    .s_axi_csrs_awvalid  ( axil_awvalid  ),
    .s_axi_csrs_bready   ( axil_bready   ),
    .s_axi_csrs_bresp    ( axil_bresp    ),
    .s_axi_csrs_bvalid   ( axil_bvalid   ),
    .s_axi_csrs_rdata    ( axil_rdata    ),
    .s_axi_csrs_rready   ( axil_rready   ),
    .s_axi_csrs_rresp    ( axil_rresp    ),
    .s_axi_csrs_rvalid   ( axil_rvalid   ),
    .s_axi_csrs_wdata    ( axil_wdata    ),
    .s_axi_csrs_wready   ( axil_wready   ),
    .s_axi_csrs_wstrb    ( axil_wstrb    ),
    .s_axi_csrs_wvalid   ( axil_wvalid   ),
    .mem_clk             ( clk           ), 
    .mem_addr            ( mem_addr      ),     
    .mem_din             ( mem_din       ), 
    .mem_dout            ( mem_dout      ), 
    .mem_en              ( 1'b1          ), 
    .mem_rst             (~resetn        ), 
    .mem_we              ( mem_we        ));
      
  // Generate Clock
  initial begin
      clk = 0;
      forever #`CLK_HALF clk = ~clk;
  end

  // Initialize signals to zero
  initial begin
    axil_araddr  <= 'b0;
    axil_arvalid <= 'b0;
    axil_awaddr  <= 'b0;
    axil_awvalid <= 'b0;
    axil_bready  <= 'b0;
    axil_rready  <= 'b0;
    axil_wdata   <= 'b0;
    axil_wstrb   <= 'b0;
    axil_wvalid  <= 'b0;
  end

  // Reset the circuit
  initial begin
      resetn = 0;
      #`RESET_TIME
      resetn = 1;
  end

  // Read from specified register
  task reg_read;
    input [11:0] reg_address;
    output [31:0] reg_data;
    begin
      // Channel AR
      axil_araddr  <= reg_address;
      axil_arvalid <= 1'b1;
      wait (axil_arready);
      #`CLK_PERIOD;
      axil_arvalid <= 1'b0;
      // Channel R
      axil_rready  <= 1'b1;
      wait (axil_rvalid);
      reg_data <= axil_rdata;
      #`CLK_PERIOD;
      axil_rready  <= 1'b0;
      // Commented to avoid spamming lol
      //$display("reg[%x] <= %x", reg_address, reg_data);
      #`CLK_PERIOD;
      #`RESET_TIME;
    end
  endtask

  // Write to specified register
  task reg_write;
    input [11:0] reg_address;
    input [31:0] reg_data;
    begin
      // Channel AW
      axil_awaddr <= reg_address;
      axil_awvalid <= 1'b1;
      // Channel W
      axil_wdata  <= reg_data;
      axil_wstrb  <= 4'b1111;
      axil_wvalid <= 1'b1;
      // Channel AW
      wait (axil_awready);
      #`CLK_PERIOD;
      axil_awvalid <= 1'b0;
      // Channel W
      wait (axil_wready);
      #`CLK_PERIOD;
      axil_wvalid <= 1'b0;
      // Channel B
      axil_bready <= 1'b1;
      wait (axil_bvalid);
      #`CLK_PERIOD;
      axil_bready <= 1'b0;
      $display("reg[%x] <= %x", reg_address, reg_data);
      #`CLK_PERIOD;
      #`RESET_TIME;
    end
  endtask

  // Read at given address in memory
  task mem_write;
    input [  16:0] address;
    input [1024:0] data;
    begin
      mem_addr <= address;
      mem_din  <= data;
      mem_we   <= {128{1'b1}};
      #`CLK_PERIOD;
      mem_we   <= {128{1'b0}};
      $display("mem[%x] <= %x", address, data);
      #`CLK_PERIOD;
    end
  endtask

  // Write to given address in memory
  task mem_read;
    input [  16:0] address;
    begin
      mem_addr <= address;
      #`CLK_PERIOD;
      $display("mem[%x] => %x", address, mem_dout);
    end
  endtask

  // Byte Addresses of 32-bit registers
  localparam  COMMAND = 0, // r0
              RXADDR  = 4, // r1
              TXADDR  = 8, // r2
              T       = 12,
              T_LEN   = 16,
              LOADING = 20,
              STATUS  = 0,
              LSB_N   = 4,
              LSB_R_N = 8,
              LSB_R2_N= 12;

  // Byte Addresses of 1024-bit distant memory locations
  // here we talk with byte watch out
  localparam  MEM0_ADDR  = 16'h00,
              MEM1_ADDR  = 16'h80, // personal test of Thomas
              N1_ADDR    = 16'h100,
              M1_ADDR    = 16'h180,
              R_N1_ADDR  = 16'h200,
              R2_N1_ADDR = 16'h280,
              A_ADDR     = 16'h300,
              X_TILDE_ADDR = 16'h380;
  

  reg [31:0] reg_status;

  initial begin

    #`LONG_WAIT

    mem_write(MEM0_ADDR, 1024'd1);
    mem_write(MEM1_ADDR, 1024'd2);
    
    // writing the data like C
    mem_write(N1_ADDR, 1024'hccd61077400aba4c98a62f433339650adcf9069c6bb24dd60bba4028f693324978055a3d08714b05015e270b7556d71488695fd12f8272f1d520ac979d96440401d3de7ddddab60b458971b6e683fc3c3de09b8cdef188efe99045ab59000e06e5345506bc860be0a1fd8b703b3a20de58e314bf47a5e8142d275cd928c9249d);
    mem_write(M1_ADDR, 1024'h8eb60bf5e833600adfdd8a07dad62ff16d598dc59c7dbc9832ece3c7b055e0b0d54dfc4fa8d0087b73b23009adb1e6f246d0fccbefb98465b8de04119df17a8179638497c4cef4e3f9c9c2efa40fef1eb20079da4deda86fcfeee16be329c697d3d7226b11a9378db6c466fd671397f0ad8a0fd6fe6a62b65d058af9433b2afe);
    mem_write(R_N1_ADDR, 1024'h3329ef88bff545b36759d0bcccc69af52306f963944db229f445bfd7096ccdb687faa5c2f78eb4fafea1d8f48aa928eb7796a02ed07d8d0e2adf53686269bbfbfe2c2182222549f4ba768e49197c03c3c21f6473210e7710166fba54a6fff1f91acbaaf94379f41f5e02748fc4c5df21a71ceb40b85a17ebd2d8a326d736db63);
    mem_write(A_ADDR, 1024'h3329ef88bff545b36759d0bcccc69af52306f963944db229f445bfd7096ccdb687faa5c2f78eb4fafea1d8f48aa928eb7796a02ed07d8d0e2adf53686269bbfbfe2c2182222549f4ba768e49197c03c3c21f6473210e7710166fba54a6fff1f91acbaaf94379f41f5e02748fc4c5df21a71ceb40b85a17ebd2d8a326d736db63);
    mem_write(R2_N1_ADDR, 1024'h1f15c169ccf6db0eadb669fed1b94a0d175805506c347e19ec2d0339a336a065444da79191abfe40fb8ad4936c9a19f2f13f8be9d043fc804e96c23dfdd351a33f92cef0520c79b577949f4f03ee50789bca8d50d5258da93f787503b62440a8baf662063f74e61837198dd81202d618114f8acdad9bd3f5847a5bd11247ae04);
    mem_write(X_TILDE_ADDR, 1024'h0);
    E <= 32'h00009985;
    i <= 0;
    // do the data loading part
    
    // first write WATCH OUT THE ORDER IS IMPORTANT
    reg_write(RXADDR, N1_ADDR);
    reg_write(LOADING, 32'b1001);
    
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0) 
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    $display("Sent N");
    reg_write(LOADING, 32'b0);
    
    /*reg_write(RXADDR, R_N1_ADDR);
    reg_write(LOADING, 32'b1010);
    
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0) 
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    $display("Sent R_N");
    reg_write(LOADING, 32'b0);*/
    
    reg_write(RXADDR, R2_N1_ADDR);
    reg_write(LOADING, 32'b1011);
    
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0)
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    $display("Sent R2_N");
    
    /// loading finished
    reg_write(LOADING, 32'b0);
    
    // preparing the rest of the data
    //reg_write(T_LEN, 32'd16);
    // ALWAYS LOAD DATA BEFORE SENDING ANY COMMAND OR MAY CAUSE BUGS

    // Starting RSA
    // Prepare the DMA with A
    reg_write(RXADDR, M1_ADDR);
    reg_write(TXADDR, X_TILDE_ADDR);
    
    reg_write(COMMAND, 32'h00000009);
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0) // check LSB status
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    reg_write(COMMAND, 32'h00000000); // stop everything
    
    for (; i < 16 ;) begin
      if(condition_DBG) begin 
        i<=i+1; // Executed here to avoid race condition
        $display("First Condition");
        
        // Prepare the DMA with A
        reg_write(RXADDR, A_ADDR);
        reg_write(TXADDR, A_ADDR);
        
        reg_write(COMMAND, 32'h00000001);
        // Poll Done Signal
        reg_read(COMMAND, reg_status);
        while (reg_status[0]==1'b0) // check LSB status
        begin
          #`LONG_WAIT;
          reg_read(COMMAND, reg_status);
        end
        reg_write(COMMAND, 32'h00000000); // stop everything
        
        // Prepare the DMA with X_tilde
        reg_write(RXADDR, X_TILDE_ADDR);
        reg_write(TXADDR, X_TILDE_ADDR);

        reg_write(COMMAND, 32'h0000000B);
        // Poll Done Signal
        reg_read(COMMAND, reg_status);
        while (reg_status[0]==1'b0) // check LSB status
        begin
          #`LONG_WAIT;
          reg_read(COMMAND, reg_status);
        end
        reg_write(COMMAND, 32'h00000000); // stop everything
      end else begin
        i<=i+1; // Executed here to avoid race condition
        $display("Second Condition");
        
        // Prepare the DMA with X_tilde
        reg_write(RXADDR, X_TILDE_ADDR);
        reg_write(TXADDR, X_TILDE_ADDR);
        
        reg_write(COMMAND, 32'h0000000D);
        // Poll Done Signal
        reg_read(COMMAND, reg_status);
        while (reg_status[0]==1'b0) // check LSB status
        begin
          #`LONG_WAIT;
          reg_read(COMMAND, reg_status);
        end
        reg_write(COMMAND, 32'h00000000); // stop everything
        
        // Prepare the DMA with A
        reg_write(RXADDR, A_ADDR);
        reg_write(TXADDR, A_ADDR);

        reg_write(COMMAND, 32'h00000003);        
        // Poll Done Signal
        reg_read(COMMAND, reg_status);
        while (reg_status[0]==1'b0) // check LSB status
        begin
          #`LONG_WAIT;
          reg_read(COMMAND, reg_status);
        end
        reg_write(COMMAND, 32'h00000000); // stop everything
      end
    end
    
    // Prepare the DMA with A
    reg_write(RXADDR, A_ADDR);
    reg_write(TXADDR, A_ADDR);
    
    // Starting RSA
    reg_write(COMMAND, 32'h00000005);
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0) // check LSB status
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    reg_write(COMMAND, 32'h00000000); // stop everything

    mem_read(R_N1_ADDR); // read from memory

    $finish;

  end
endmodule