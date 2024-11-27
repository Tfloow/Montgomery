`timescale 1ns / 1ps


module tb_rsa_hw(

    );
    
        // Define internal regs and wires
    reg clk,
    reg resetn,

    reg [1023:0] N_Q,
    reg [1023:0] R_N_Q,
    reg [1023:0] R2_N_Q,
    reg [1023:0] M,
    reg [31:0]   t,
    reg [31:0]   t_len,
    reg [31:0]   command,

    wire [1023:0] dma_tx_address
    wire [31:0] rout0

    // Instantiating adder
    rsa_hw dut (clk, resetn, N_Q, R_N_Q, R2_N_Q, M, t, t_len, command, dma_tx_address, rout0);

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        N_Q <= 1024'hccd61077400aba4c98a62f433339650adcf9069c6bb24dd60bba4028f693324978055a3d08714b05015e270b7556d71488695fd12f8272f1d520ac979d96440401d3de7ddddab60b458971b6e683fc3c3de09b8cdef188efe99045ab59000e06e5345506bc860be0a1fd8b703b3a20de58e314bf47a5e8142d275cd928c9249d;
        R_N_Q <= 1024'h3329ef88bff545b36759d0bcccc69af52306f963944db229f445bfd7096ccdb687faa5c2f78eb4fafea1d8f48aa928eb7796a02ed07d8d0e2adf53686269bbfbfe2c2182222549f4ba768e49197c03c3c21f6473210e7710166fba54a6fff1f91acbaaf94379f41f5e02748fc4c5df21a71ceb40b85a17ebd2d8a326d736db63;
        R2_N_Q <= 1024'h1f15c169ccf6db0eadb669fed1b94a0d175805506c347e19ec2d0339a336a065444da79191abfe40fb8ad4936c9a19f2f13f8be9d043fc804e96c23dfdd351a33f92cef0520c79b577949f4f03ee50789bca8d50d5258da93f787503b62440a8baf662063f74e61837198dd81202d618114f8acdad9bd3f5847a5bd11247ae04;
        M <= 1024'h8eb60bf5e833600adfdd8a07dad62ff16d598dc59c7dbc9832ece3c7b055e0b0d54dfc4fa8d0087b73b23009adb1e6f246d0fccbefb98465b8de04119df17a8179638497c4cef4e3f9c9c2efa40fef1eb20079da4deda86fcfeee16be329c697d3d7226b11a9378db6c466fd671397f0ad8a0fd6fe6a62b65d058af9433b2afe;
        t <= 32'h00009985;
        t_len <= 32'd16;
        command <= 32'd0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    initial begin

        #`RESET_TIME

        command <= 32'd1;
        wait(rout == 32'd1)

        $finish
        

    end

endmodule
