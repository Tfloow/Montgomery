`timescale 1ns / 1ps

module mpadder(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire          subtract,
    input  wire [1026:0] in_a,
    input  wire [1026:0] in_b,
    output reg  [1027:0] result,
    output wire          done    
    );
        reg [1:0] state, nextstate;

    // Definition register A
    reg          regA_en;
    wire [1026:0] regA_D;// in
    reg  [1026:0] regA_Q;// out
    always @(posedge clk)
    begin
        if(~resetn || state == 1'd0)         regA_Q = 1027'd0;
        else if (regA_en)   regA_Q <= regA_D;
    end
    // Definition register B 
    reg          regB_en;   
    wire [1026:0] regB_D;   // in
    reg  [1026:0] regB_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn || state == 1'd0)         regB_Q = 1027'd0;
        else if (regB_en) begin
           regB_Q <= regB_D;
           
        end
    end
    
    //Multiplexer for A
    reg          muxA_sel;
    reg  [1026:0] muxA_Out;
    always@(posedge clk) begin
        if (muxA_sel==1'b0) muxA_Out <= in_a;
        else                muxA_Out <= muxA_Out >> 64;
    end

    assign regA_D = muxA_Out;
    
    
    //Multiplexer for B
    reg          muxB_sel;
    reg  [1026:0] muxB_Out;
    always@(posedge clk) begin
        if (muxB_sel==1'b0) muxB_Out <= in_b;
        else                muxB_Out <= muxB_Out >> 64;
    end

    assign regB_D = muxB_Out;
    
    //64-bit adder
    wire [63:0] operandA;
    wire [63:0] operandB;
    wire        carry_in;
    wire [63:0] resultadd;
    wire        carry_out;
     reg [4:0] count;
    
    // keeps running maybe not the wisest thing to do
    assign {carry_out,resultadd} = operandA + operandB + carry_in;
    
    //storing result adder in 1027-bit register
    
    reg          regResult_en;
    reg  [1087:0] regResult;
    always @(posedge clk)
    begin
        if(~resetn)             regResult <= 1088'b0;
        else if (regResult_en) begin  
                        regResult = regResult >> 64;
                        regResult = {resultadd, regResult[1023:0]};
                        //regResult <= {resultadd, regResult[1023:0] >> 64};
                        // when ran as a non blocking statement we observe unexpected behavior
        end
    end
    
    //DBG
    //wire [63:0] dbg;
    //assign dbg = result[63:0];
    //    wire [63:0] dbg_2;
    //assign dbg_2 = result[127:64];
    //    wire [63:0] dbg_a;
    //assign dbg_a = in_a[63:0];
    //    wire [63:0] dbg_b;
    //assign dbg_b = in_b[63:0];
    
    //Storing carry in 1-bit register
    
    reg  regCout_en;
    reg  regCout;
    reg state_start;
    reg state_compute;


    
        always @(posedge clk)
            begin
                if(~resetn || (state==2'd2))          
                    regCout <= 1'b0;
                else if (regCout_en)  //
                    regCout <= carry_out;
                else
                    regCout <= 1'b0; // to clean ? 
                 
        end
                
     //Multiplexer that supplies the carry after each addition
     reg  muxCarryIn_sel;
     wire muxCarryIn;
    
     assign muxCarryIn = (muxCarryIn_sel == 0) ? 1'b0 : (subtract ? regCout : regCout);
     
     // Connecting outputs first registers to adder inputs
     assign operandA = regA_Q;
     assign operandB = subtract ? (count == 5'd1 ? ~regB_Q[63:0] + 64'd1 : ~regB_Q[63:0] ) : regB_Q[63:0]; // disgusting but works (???)
     assign carry_in = muxCarryIn;
     
     // Connecting output registers to one output
     always@(*)
     begin
        result <= regResult[1027:0];
     end
     
     //State Machine shifting

    always @(posedge clk)
    begin
        if(~resetn)	state <= 2'd0;
        else        state <= nextstate;
    end
     //Output of carry_out + result assigned to
    //     assign  = 
    always @(*) begin
         case(state)
         
         // waiting stage
            2'd0: begin
                regA_en          <= 1'b1;
                regB_en          <= 1'b1;
                regResult_en     <= 1'b0;
                regCout_en       <= 1'b0;
                muxCarryIn_sel   <= 1'b0;
                muxA_sel         <= 1'b0;  // Select in_a for shifting
                muxB_sel         <= 1'b0;  // Select in_b for shifting
            end
            
            // shifting stage;
            2'd1: begin
                regA_en        <= 1'b1;
                regB_en        <= 1'b1;
                regResult_en   <= 1'b1;
                regCout_en     <= 1'b1;
                muxCarryIn_sel <= 1'b1;
                muxA_sel       <= 1'b1;  // Select in_a for shifting
                muxB_sel       <= 1'b1;  // Select in_b for shifting
            end
            
            2'd2: begin
                regA_en        <= 1'b0;
                regB_en        <= 1'b0;
                regResult_en   <= 1'b0;
                regCout_en     <= 1'b0;
                muxCarryIn_sel <= 1'b1;
                muxA_sel        <= 1'b0;  // Select in_a for shifting
                muxB_sel        <= 1'b0;  // Select in_b for shifting
            end

            default: begin
                regA_en        <= 1'b0;
                regB_en        <= 1'b0;
                regResult_en   <= 1'b1;
                regCout_en     <= 1'b0;
                muxCarryIn_sel <= 1'b0;
                muxA_sel       <= 1'b0;  // Select in_a for shifting
                muxB_sel       <= 1'b0;  // Select in_b for shifting
            end
        endcase
    end
    
    always @(posedge clk)
    begin
        if(state==2'd1) begin
        count <= count + 1;
        end else begin
        count <= 5'd0;
        end
    end
        
    always @(*)
    begin
        case(state)
            2'd0   : begin
                if(start) begin
                    nextstate <= 2'd1;
                    
                end else begin
                    nextstate <= 2'd0;
                    end
            end

            2'd1   : begin
            
                if(count >= 5'd17) begin // will repeat 16 times in the loop state 1 and last one in state 2
                    nextstate <= 2'd2;
                 end else begin
                    nextstate <= 2'd1;
                 end
         end
         
            2'd2   : begin
               nextstate <= 2'd0;
            end
            
            default: begin
            nextstate <= 2'd0; 
            end
        endcase
    end
    
    reg delayRegDone;
    reg regDone;
    always @(posedge clk)
    begin
        if(~resetn) delayRegDone <= 1'b0;
        else        delayRegDone <= (state==2'd2) ? 1'b1 : 1'b0;
    end

    always @(posedge clk)
    begin 
        if(~resetn) regDone <= 1'b0;
        else        regDone <= delayRegDone;
    end

    assign done = regDone;

endmodule