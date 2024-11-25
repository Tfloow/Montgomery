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
    wire correct;

    // Test values
    reg [1027:0] expected_results;

    // Instantiate the mpadder module
    mpadder #(.ADDER_SIZE(514)) uut (  
        .clk(clk),
        .resetn(resetn),
        .start(start),
        .subtract(subtract),
        .in_a(in_a),
        .in_b(in_b),
        .result(result),
        .done(done)
    );

    assign correct = (result == expected_results);

    // Generate clock signal with a period of 10 time units (100 MHz frequency)
    always #5 clk = ~clk;

        reg [4:0] test;


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

        test = 5'b10101;

        $display("%d", $bits(expected_results[1027:64]));
        $display("%b", test[4:2]);

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
        #100
        #10;

        // Test Case 2: Simple subtraction of two numbers
        #10 start = 1;
            in_a = 1027'd3000;
            in_b = 1027'd1500;
            subtract = 1; // Subtraction
            expected_results = 1028'd1500;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        $display("Diff =%x", expected_results-result);

        #10;

        // Test Case 3: Edge case - large numbers addition
        #10 start = 1;
            in_a = 1027'h5037a57ca996db568fd681b0eee5660d8b1bac3f26d4c7d4bfd7569cea79a145a1e92496b29b0ef27b1f1138ef99808032375ae31820c93afee07f59b71f0e9205b2df5de5917242015ab0523b77d8245cab5c51b0ecfd3a04343fefd3da2e2f847a2628d9042682c37ea70249c53f1044691d3d8640223354bab205a3d87c0c5; // Maximum 1026-bit value
            in_b = 1027'h57094adfb92250358e5b00f6b91f711ce3d00dcd6651b2d9e99f080272a4067278e091cd48a8afc8c898f3a6c438ad9c940c8783c45054fde3c9926381f52222525b425eab03e92e43ef615df37a8b6cde00524ff913662ac768b37a8361c968d9304f920b7f1f278daabc7fa237c56112df9aeab7534a3f5fd7163600e67b0a9; // Slightly smaller max value
            expected_results = 1028'ha740f05c62b92b8c1e3182a7a804d72a6eebba0c8d267aaea9765e9f5d1da7b81ac9b663fb43bebb43b804dfb3d22e1cc643e266dc711e38e2aa11bd391430b4580e21bc90955b70454a11b02ef263913aabaea1aa006364cb9cf36a573bf7985daa75bae48345aa51296381ebfd04715748b8283d936c72b491c83ba4bef716e;
            subtract = 0; // Addition
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        #10;

        // Test Case 4: Edge case - large numbers subtraction
        #10 start = 1;
            in_a = 1027'h6a26b6195145db76f720b63f19f8844a6a3e6801ff7bd0d62949563cce5ea2f66e14a3c862d706bd44db1b6ea65e84b5ea9f958955a8a2fcb397a1a11f2ac168eb388d8ab437bcca0fce5d8a5e16cb726bfe06c35ec0631672102a495598b6a803d04a2d67351297accdbdec0e46d3c4784d46f3d20832d050d5b65d5cb0474e4; // Maximum 1026-bit value
            in_b = 1027'h4e5d2a0b6da45e13044a6596d0b5200547e40e18abb2eff5d07226cb694813af04d61b44d0e18de8220298844f81a262378d23c4c1849106db5fb6ffd82a90622b33f832a740c3929f2cc8eb7aef7de89c6f982179ef0d1d28338d61e056df1f51cb4e811c6e6a5b90e7078e5e89aade568659c2d327c79488b57eb53575398a8; // Slightly smaller max value
            subtract = 1; // Subtraction
            expected_results = 1028'h1bc98c0de3a17d63f2d650a849436445225a59e953c8e0e058d72f7165168f47693e888391f578d522d882ea56dce253b31271c4942411f5d837eaa147003106c00495580cf6f93770a1949ee3274d89cf8e6ea1e4d155f949dc9ce77541d788b204fbac4ac6a83c1be6b65dafbd28e621c6ed30fee06b3bc82037a8273b0dc3c;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        $display("Diff =%x", expected_results-result);

        #10;
        // Test Case 5: Edge case - large numbers subtraction
        #10 start = 1;
            in_a = 1027'h0; // Maximum 1026-bit value
            in_b = 1027'h33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517; // Slightly smaller max value
            subtract = 0; // Subtraction
            expected_results = 1028'h33c211b567e0c0ce6610393b49e77a5fb33183f2ef3bd0c34e15369f3537c592b927242339b723be6c59d907c2cbef8d6afee9803ed39bc4fe2f7773546ed91771322659fdd65ad3402f62be5f34bbdf7ca9aa874d678a9decb13abe8b9c3badbdb709dfee20ec628be2748831cac28e1e027e33eeb69ff23499dc429d74a517;
        #10 start = 0; // Deassert start signal

        // Wait for 'done' signal to go high
        #100
        $display("Diff =%x", expected_results-result);

        #10;

        // Finish simulation
        $finish;
    end

endmodule
