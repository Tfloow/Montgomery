module seven_multiplexer(
    input           clk,
    input           resetn,
    input [1026:0]  in_M,
    input [1026:0]  in_2M,
    input [1026:0]  in_3M,
    input [1026:0]  in_B,
    input [1026:0]  in_2B,
    input [1026:0]  in_3B,
    input [2:0]     select,
    output reg[1026:0] out
    );

    always @(*) begin
        if(~resetn)
            out <= 1027'd0;
        else begin
            case (select)
                3'b001 : out <= in_B;  
                3'b010 : out <= in_2B; 
                3'b011 : out <= in_3B; 
                3'b100 : out <= in_M;
                3'b101 : out <= in_2M;
                3'b110 : out <= in_3M;
                default: out <= 1027'd0;
            endcase
        end
    end

endmodule