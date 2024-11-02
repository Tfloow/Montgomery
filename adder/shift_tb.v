`timescale 1ns / 1ps
`include "shift_add_123.v"

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2024 03:23:09 PM
// Design Name: 
// Module Name: tb_shift_123
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


module tb_shift_123(

    );
    
        
    reg          clk;
    reg          resetn;
    reg          start;
    reg  [1023:0] in_a;
    wire  [1023:0] out;
    wire  [1024:0] out2;
    wire [1027:0] out3;
    wire         done;

    
    //Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    //Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    shift_add_123 shifter(clk, in_a, start, restn, done, out,out2,out3);

        // Test data
    initial begin

        // Dump waveforms for analysis
        $dumpfile("shift_tb.vcd");
        $dumpvars(1, tb_shift_123);
        $dumpvars(1, shifter);
        $dumpvars(1, shifter.shifter);
        $dumpvars(1, shifter.adder);

        #`RESET_TIME
        in_a <= 1024'h993a45a7ccc9834b9775fbbf1be8566199cf3883f29a2846a7357f314b1b6a719edf9b543addb902a023885c72b83d21d6bc2a14ed8adef3566f0da4c541f83c882bc4a1c21cb045d17eb1f773535af04b82a90c5823ac4f3076dbbd37c7019cb84e7b2e21849abd2860ef93d144c8564492ec8036b3d1a51bd98c94c145d8c3;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        
        wait (done==1);
        
        $display("result out=%x", out);
        $display("result out=%x", in_a);
        
        $display("result out=%x", out2);
        $display("result out=%x", out<<1);
        
        $display("result out=%x", out3);
        $display("result out=%x", 3*in_a);

        $display("diff=%x", out3 - 3*in_a);
        
        #`CLK_PERIOD $finish;
    end
    
    
endmodule

