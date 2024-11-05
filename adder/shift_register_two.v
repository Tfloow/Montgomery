module shift_register_two(
    input           clk,
    input [1027:0]  in_number,
    input           shift,
    input           restn,
    input           enable,
    output reg [1027:0] out_shift,
    output wire        shift_done);
    
    reg [1027:0] current_number;
    reg regDone; reg delayRegDone;
    
    assign shift_done = regDone;
    
    // The brain of the shift register
    always @ (posedge clk) begin
    // Reset
        if(~restn) begin
            current_number <= 1028'b0;
            out_shift <= 1028'b0;
            regDone = 1'b0;
        end
        
        // writing to memory
        if(enable) begin
            current_number <= in_number;
            // already outputing 
            out_shift <= in_number;
            regDone <= 1'b0;
        end
        
        // shifting
        if(shift) begin
            out_shift <= (current_number >> 2);
            current_number <= (current_number >> 2);
            regDone <= 1'b1;
        end else 
            regDone <= 1'b0;

        // delay done
        //regDone <= delayRegDone;
    end
    
endmodule