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
                // You can generate your own with test vector generator python script
        in_a     <= 1024'he47c3cc1944a0f56b9b6a84ed643221ba8fd33b447746f3d142c5dac1ece86984180efcddeb2e2f6b5712742cc0cba90b9c3dee8ebd49a1fb20c3a12b8aed0c93e077936a177a29af5d97d0406e029a0c8190a88d9c59fd28e932c8f502af843c8cb9d28f29436e9d3e255fe6a5d6e7054c55698660e04373b8c002fbbe7b046;
        in_b     <= 1024'ha43736d213b9148ce75ee249c012cf2c052962f322f1be636c7faed922b23e4bd338c07662dbfd0bd6240f463accec6ef21ff466cc29c05a93c9bd177d6f9dc4da2ca2f3da7b66359cbe6b84cabec8ec2c09bd80b5616a6930f45bb2706c98001a813a1acff4c673a728c203b3a2bd8d68188e9e7c2bf822d31a13b784cdd7ef;
        in_m     <= 1024'hef059fff1ffeebaaf4027030afc37e35794da72fa064675aa975b53e647e3b02e6e793c8f8413ec9a994180db86227338828ba9fff6ec9dc1b00f74da80647cfb319d35ae277b903278155476ada0ea1cf8d07caee5e7ad727b2067c97a59f6070168052a3a4335daeda44642d34937001331fe2766a337b4aafacdceeb7e5b7;
        expected_results <= 1024'hd0904e20fb8fcdf388840a218c4edfd8a9d101e5084ed1cda137ac242785b8c4119dc93c79ea548914f4334f15688a71346f56c5a45bf4cf2a95cf680d3d99999263ccefc07c05ececf3a24a49282306f2f8a2456011d2c7df1a0ca836739d9f7baf30aeef622856ac1f279d5c9548fccbb511a906675bc895e32712dc6bf815;
        
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
