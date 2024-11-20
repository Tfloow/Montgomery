`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 06:20:31 PM
// Design Name: 
// Module Name: data_preparation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_preparation(
    input  wire          clk,
    input  wire          resetn,
    
    // my signals
    input  wire [31:0]   loading_state,
    output wire [1023:0] N,
    output wire [1023:0] e,
    output wire [1023:0] R_N,
    output wire [1023:0] R2_N,
    
    output reg  [31:0]   loading_out_state,

    // dma signals
    input  wire [1023:0] dma_rx_data,     
    output reg           dma_rx_start,     
    input  wire          dma_done,
    input  wire          dma_idle,
    input  wire          dma_error
    );
    
    reg N_en;
    reg e_en;
    reg R_N_en;
    reg R2_N_en;
    
    // registers definition
    // N
    wire [1023:0] N_D;
    reg [1023:0] N_Q;
    always @(posedge clk) begin
        if(N_en)
            N_Q <= N_D;
    end
    
    // e
    wire [1023:0] e_D;
    reg [1023:0] e_Q;
    always @(posedge clk) begin
        if(e_en)
            e_Q <= e_D;
    end
    
    // R_N
    wire [1023:0] R_N_D;
    reg [1023:0] R_N_Q;
    always @(posedge clk) begin
        if(R_N_en)
            R_N_Q <= R_N_D;
    end
    
    // R2_N
    wire [1023:0] R2_N_D;
    reg [1023:0] R2_N_Q;
    always @(posedge clk) begin
        if(R2_N_en)
            R2_N_Q <= R2_N_D;
    end
    
    assign N_D    = dma_rx_data;
    assign e_D    = dma_rx_data;
    assign R_N_D  = dma_rx_data;
    assign R2_N_D = dma_rx_data;
    
    // FSM based on the loading state
    always @(*) begin
        if(dma_done) begin // done so the data is loaded in dma_rx_data
            case(loading_state)
                8'b00001001 : begin
                    N_en <= 1'b1;
                    e_en <= 1'b0;
                    R_N_en <= 1'b0;
                    R2_N_en <= 1'b0;
                end
                8'b00001010 : begin
                    N_en <= 1'b0;
                    e_en <= 1'b1;
                    R_N_en <= 1'b0;
                    R2_N_en <= 1'b0;
                end
                8'b00001011 : begin
                    N_en <= 1'b0;
                    e_en <= 1'b0;
                    R_N_en <= 1'b1;
                    R2_N_en <= 1'b0;
                end 
                8'b00001100 : begin
                    N_en <= 1'b0;
                    e_en <= 1'b0;
                    R_N_en <= 1'b0;
                    R2_N_en <= 1'b1;
                end
                default : begin
                    N_en <= 1'b0;
                    e_en <= 1'b0;
                    R_N_en <= 1'b0;
                    R2_N_en <= 1'b0;                
                end   
            endcase
        end else begin
            N_en <= 1'b0;
            e_en <= 1'b0;
            R_N_en <= 1'b0;
            R2_N_en <= 1'b0;
        end
    end
    
endmodule
