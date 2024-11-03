`timescale 1ns / 1ps
`include "montgomery_thomas.v"

module tb_montgomery();

    reg clk;
    reg resetn;
    reg start;
    reg [1023:0] in_a;
    reg [1023:0] in_b;
    reg [1023:0] in_m;
    wire [1024:0] result;
    wire done;

    // Instantiate the montgomery module
    montgomery uut (
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .in_a(in_a),
        .in_b(in_b),
        .in_m(in_m),
        .result(result),
        .done(done)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Apply reset and input stimulus
    initial begin
        // Initialize signals
        resetn = 0;
        start = 0;
        in_a = 1024'd0;
        in_b = 1024'd0;
        in_m = 1024'd0;

        // Dump waveform data
        $dumpfile("tb_montgomery.vcd");
        $dumpvars(1, uut);
        $dumpvars(1, uut.shiftM);
        $dumpvars(1, uut.shiftB);
        $dumpvars(1, uut.shiftB.adder);
        $dumpvars(1, uut.adder);
        $dumpvars(1, uut.shifter);

        // Apply reset
        #10 resetn = 1;  // Release reset after 10ns

        // Test case 1: Basic input values
        in_a = 1024'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5;
        in_b = 1024'h5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5;
        in_m = 1024'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle

        // Wait for computation to complete
        //wait(done);
        #10000; // 1 billion time units at a 1ns timescale

        // Display results
        $display("Result: %h", result);

        // Additional test cases can be added here as needed

        // End simulation
        #50 $finish;
    end
endmodule
