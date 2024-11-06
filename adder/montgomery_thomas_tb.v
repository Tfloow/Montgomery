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
    reg [1024:0] expected_results;
    wire done;

    wire correct;
    assign correct = (result == expected_results);

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
        $dumpvars(1, tb_montgomery);
        $dumpvars(1, uut);
        $dumpvars(1, uut.shiftM);
        $dumpvars(1, uut.shiftB);
        $dumpvars(1, uut.shiftB.adder);
        $dumpvars(1, uut.multi);
        $dumpvars(1, uut.shiftA);
        $dumpvars(1, uut.adder);
        $dumpvars(1, uut.shifter);

        // Apply reset
        #10 resetn = 1;  // Release reset after 10ns

        // Test case 1: Basic input values
        in_a = 1024'h2394a8c9e2c6abc0edb8734fb607d38620559f7220a7a45b60a298241a9888760f0aede90b9467975a6cf461e75242d6871a24d024f15ca6ab969a1617a5432363b4792838172caf1dec516490c43b22d592c9f84294af8bfe9ccd0e09cd5a683c84feec717eb638c74228f1393f8ebcf634845a3b1c51f893c2286ef76f49b1;
        in_b = 1024'h33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517;
        in_m = 1024'h83a6c5c93235f2f4905daaa92deddb7235d196d00c713a582030a113495b64c40d579c795c171370251a7651affcd685caeee9b4b7c1f7ed3c805f565c2ac5ed7e83e68b34ffba6bdeeb98894c6a406a4e6a2ea9d45e0285d4ad9250e6108b07150d513e834ae1d93ba570636737aaedf95d829f9bdb8ceeb0fefd5e1d47ef05;
        expected_results = 1024'h200c28fdb80e80addadb9c9371c523a8b9e22e324e2fc873895987577d6d0fabc8d874f2bbd21b07ea86058deb5732ad0c432e71ca752a7e0496e83215de9044ebc739a929a144e127325d63e7826201d17f26bc1dc8cf711796e8ea8ff2f306f96558ab88e696457cf2a15b85b3c7534b3136f48a3b05a037776ece854173bf;
        #10 start = 1;  // Start computation
        #10 start = 0;  // Deassert start signal after one clock cycle

        // Wait for computation to complete
        //wait(done);
        wait(done == 1) // 1 billion time units at a 1ns timescale
        
        //#1000

        // Display results
        $display("Result:   %h", result);
        $display("Expected: %h", expected_results);
        $display("Diff: %h", expected_results - result);

        // Additional test cases can be added here as needed

        // End simulation
        #50 $finish;
    end
endmodule
