`timescale 1ns / 1ps
`include "seven_multiplexer.v"

module tb_seven_multiplexer;

    // Testbench signals
    reg clk;
    reg resetn;
    reg [1026:0] in_M;
    reg [1026:0] in_2M;
    reg [1026:0] in_3M;
    reg [1026:0] in_B;
    reg [1026:0] in_2B;
    reg [1026:0] in_3B;
    reg [2:0] select;
    wire [1026:0] out;

    // Instantiate the design under test (DUT)
    seven_multiplexer uut (
        .clk(clk),
        .resetn(resetn),
        .in_M(in_M),
        .in_2M(in_2M),
        .in_3M(in_3M),
        .in_B(in_B),
        .in_2B(in_2B),
        .in_3B(in_3B),
        .select(select),
        .out(out)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock period

    initial begin
        $dumpfile("tb_multi.vcd");
        $dumpvars(1, uut);

        // Initialize signals
        clk = 0;
        resetn = 0;
        select = 3'b000;
        in_M = 1027'd1;
        in_2M = 1027'd2;
        in_3M = 1027'd3;
        in_B = 1027'd4;
        in_2B = 1027'd5;
        in_3B = 1027'd6;

        // Apply reset
        #10 resetn = 1;  // Release reset after 10ns

        // Test different select values
        #10 select = 3'b001;  // Test in_M
        #10 select = 3'b010;  // Test in_2M
        #10 select = 3'b011;  // Test in_3M
        #10 select = 3'b100;  // Test in_B
        #10 select = 3'b101;  // Test in_2B
        #10 select = 3'b110;  // Test in_3B

        // Test default case
        #10 select = 3'b000;  // Expect out to be 0

        // End the simulation
        #20 $finish;
    end

    // Monitor output changes
    initial begin
        $monitor("Time=%0dns, select=%b, out=%d", $time, select, out);
    end

endmodule
