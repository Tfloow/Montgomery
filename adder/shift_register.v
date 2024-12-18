module shift_register(
    input           clk,
    input [1023:0]  in_number,
    input           shift,
    input           restn,
    input           enable,
    output reg [1024:0] out_shift,
    output wire        shift_done);
    
    reg [1024:0] current_number;
    reg regDone; reg delayRegDone;
    
    assign shift_done = regDone;
    
    // The brain of the shift register
    always @ (posedge clk) begin
    // Reset
        if(~restn) begin
            current_number <= 1025'b0;
            out_shift <= 1025'b0;
            regDone = 1'b0;
        end
        
        // writing to memory
        if(enable) begin
            current_number <= in_number;
            regDone <= 1'b0;
        end
        
        // shifting
        if(shift) begin
            out_shift <= (current_number << 1);
            regDone <= 1'b1;
        end

        if(regDone)
            regDone <= 1'b0;
    end
    
endmodule