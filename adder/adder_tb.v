`timescale 1ns / 1ps
`include "adder.v"

module tb_mpadder;

    // Inputs
    reg clk;
    reg resetn;
    reg start;
    reg subtract;
    reg [1026:0] in_a;
    reg [1026:0] in_b;

    // Outputs
    wire [1027:0] result;
    wire done;

    // Test values
    reg [1027:0] expected_results;

    // Instantiate the mpadder module
    mpadder uut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .subtract(subtract),
        .in_a(in_a),
        .in_b(in_b),
        .result(result),
        .done(done)
    );

    // Generate clock signal with a period of 10 time units (100 MHz frequency)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        resetn = 0;
        start = 0;
        subtract = 0;
        in_a = 0;
        in_b = 0;

        // Dump waveforms for analysis
        $dumpfile("mpadder.vcd");
        $dumpvars(0, tb_mpadder);

        // Apply reset
        #10 resetn = 1;

        // Test Case 1: Simple addition of two numbers
        #10 start = 1;
            in_a = 1027'd1000;
            in_b = 1027'd2000;
            subtract = 0; // Addition
            expected_results = 1028'd3000;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        wait (done);
        #10;

        // Test Case 2: Simple subtraction of two numbers
        #10 start = 1;
            in_a = 1027'd3000;
            in_b = 1027'd1500;
            subtract = 1; // Subtraction
            expected_results = 1028'd1500;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        wait (done);
        #10;

        // Test Case 3: Edge case - large numbers addition
        #10 start = 1;
            in_a = 1027'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Maximum 1026-bit value
            in_b = 1027'h2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Slightly smaller max value
            subtract = 0; // Addition
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        wait (done);
        #10;

        // Test Case 4: Edge case - large numbers subtraction
        #10 start = 1;
            in_a = 1027'h3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Maximum 1026-bit value
            in_b = 1027'h2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // Slightly smaller max value
            subtract = 1; // Subtraction
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        wait (done);
        #10;

        // Finish simulation
        $finish;
    end

endmodule
