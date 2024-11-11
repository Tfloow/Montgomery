`timescale 1ns / 1ps

module mpadder #(parameter ADDER_SIZE = 257)(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire          subtract,
    input  wire [1026:0] in_a,
    input  wire [1026:0] in_b,
    output wire  [1027:0] result,
    output wire          done    
    );
    // Flexible design
    //parameter ADDER_SIZE = 256;
    parameter CYCLE = (1027 + ADDER_SIZE - 1) / ADDER_SIZE;
    parameter ADDER_RES_WIDTH = CYCLE * ADDER_SIZE;
    initial begin
        $display("Adder Size : %d   Amount of Cycle : %d", ADDER_SIZE, CYCLE);
    end


    // Design for the Upper branch
    // register A
    wire [1026:0]   regA_D;
    reg  [1026:0]   regA_Q;
    reg             regA_en;
    always @(posedge clk) begin
        if(~resetn)
            regA_Q <= 1027'd0;
        else if(regA_en)
            regA_Q <= regA_D;
    end

    // muxA
    reg muxAsel;
    wire [1026:0] muxAout;
    assign muxAout = (muxAsel) ? {{ADDER_SIZE{1'b0}}, regA_Q[1026:ADDER_SIZE]} : in_a;
    assign regA_D = muxAout;

    wire [ADDER_SIZE-1:0] operandA;
    assign operandA = regA_Q; // Will be automatically trimmed because we are forcing it to be 257 bits

    // Design for the Lower branch
    // register A
    wire [1026:0]   regB_D;
    reg  [1026:0]   regB_Q;
    reg             regB_en;
    always @(posedge clk) begin
        if(~resetn)
            regB_Q <= 1027'd0;
        else if(regB_en)
            regB_Q <= regB_D;
    end

    // muxA
    reg muxBsel;
    wire [1026:0] muxBout;
    assign muxBout = (muxBsel) ? {{ADDER_SIZE{1'b0}}, regB_Q[1026:ADDER_SIZE]} : in_b;
    assign regB_D = muxBout;

    wire [ADDER_SIZE-1:0] B_lsb;
    assign B_lsb = regB_Q; // Will be automatically trimmed because we are forcing it to be 257 bits

    // muxSubtraction
    wire [ADDER_SIZE-1:0] operandB;
    assign operandB = (subtract) ? ~B_lsb : B_lsb; // inverse the number to do a subtraction

    //adder
    wire [ADDER_SIZE-1:0]    result_add;
    wire            carry_in;
    wire            carry_out;
    assign {carry_out, result_add} = operandA + operandB + carry_in;

    // regResult register
    //wire [1026:0]   regResult_D;
    reg  [ADDER_RES_WIDTH-1:0]   regResult_Q;
    reg             regResult_en;
    always @(posedge clk) begin
        if(~resetn)
            regResult_Q <= {ADDER_RES_WIDTH{1'd0}};
        else if(regResult_en)
            regResult_Q <= {result_add, regResult_Q[ADDER_RES_WIDTH-1:ADDER_SIZE]}; // concatenation
    end

    // regCarry register
    wire    regCarry_D;
    reg     regCarry_Q;
    reg     regCarry_en;
    always @(posedge clk) begin
        if(~resetn)
            regCarry_Q <= 1'd0;
        else if(regCarry_en)
            regCarry_Q <= regCarry_D;
    end
    assign regCarry_D = carry_out;

    // multiplexer for the carry_in
    reg muxcarry_sel;
    assign carry_in = (muxcarry_sel) ? regCarry_Q : subtract;


    // result
    assign result = {regCarry_Q, regResult_Q};

    // FSM
    reg [1:0] state, nextstate;
    always @(posedge clk) begin
        if(~resetn) state <= 2'b0;
        else        state <= nextstate;
    end

    always @(*) begin
        case (state)
            2'd0: begin
                // IDLE
                muxAsel <= 1'b0;
                muxBsel <= 1'b0;
                muxcarry_sel <= 1'b0;

                regA_en <= 1'b1;
                regB_en <= 1'b1;
                regResult_en <= 1'b0;
                regCarry_en <= 1'b0;
            end
            2'd1: begin
                // First Addition (avoid carry issue)
                muxAsel <= 1'b1;
                muxBsel <= 1'b1;
                muxcarry_sel <= 1'b0;

                regA_en <= 1'b1;
                regB_en <= 1'b1;
                regResult_en <= 1'b1;
                regCarry_en <= 1'b1;
            end
            2'd2: begin
                // Addition Loop
                muxAsel <= 1'b1;
                muxBsel <= 1'b1;
                muxcarry_sel <= 1'b1;

                regA_en <= 1'b1;
                regB_en <= 1'b1;
                regResult_en <= 1'b1;
                regCarry_en <= 1'b1;
            end
            2'd3: begin
                // Finish
                muxAsel <= 1'b0;
                muxBsel <= 1'b0;
                muxcarry_sel <= 1'b0;

                regA_en <= 1'b1;
                regB_en <= 1'b1;
                regResult_en <= 1'b0;
                regCarry_en <= 1'b0;
            end
                // Finish
            default: begin
                // IDLE
                muxAsel <= 1'b0;
                muxBsel <= 1'b0;
                muxcarry_sel <= 1'b0;

                regA_en <= 1'b1;
                regB_en <= 1'b1;
                regResult_en <= 1'b0;
                regCarry_en <= 1'b0;
            end
        endcase
    end

    reg [$clog2(CYCLE):0] i; // enough bits to store

    // State switch
    always @(*) begin
        case (state)
            2'd0 : begin
                if(start) 
                    nextstate <= 2'd1;
                else
                    nextstate <= 2'd0;
            end
            2'd1 : begin 
                nextstate <= 2'd2;
            end
            2'd2 : begin 
                if(i + 1 >= CYCLE) begin
                    nextstate <= 2'd3;
                end else 
                    nextstate <= 2'd2;
            end
            2'd3 : begin
                if(start)
                    nextstate <= 2'd1;
                else
                    nextstate <= 2'd0;
            end
            default: 
                nextstate <= 2'd0;
        endcase
    end

    always @(posedge clk) begin
        if(state == 2'd1 || state == 2'd2)
            i <= i+1;
        else
            i <= {$clog2(CYCLE){1'b0}};
    end

    reg regDone;
    always @(posedge clk)
    begin
        if(~resetn) regDone <= 1'd0;
        else        regDone <= (state==2'd2 && i+1 >= CYCLE) ? 1'b1 : 1'b0;
    end

    assign done = regDone;


endmodule