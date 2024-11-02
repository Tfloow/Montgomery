`timescale 1ns / 1ps
`include "adder.v"

module montgomery(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1024:0] result,
  output          done
    );

  // Student tasks:
  // 1. Instantiate an Adder
  // 2. Use the Adder to implement the Montgomery multiplier in hardware.
  // 3. Use tb_montgomery.v to simulate your design.
                                                                //Definition A and to be multiplexed registers
  // Definition register A
    reg          regA_en;
    wire [1026:0] regA_D;// in
    reg  [1026:0] regA_Q;// out
    
    always @(posedge clk)
    begin
        if(~resetn)         regA_Q = 1027'd0;
        else if (regA_en)   regA_Q <= regA_D; //If not reset, paste input for a to register a
    end
    
    assign regA_D = in_a;
    
    // Definition register B 
    reg          regB_en;   
    wire [1026:0] regB_D;   // in
    reg  [1026:0] regB_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         regB_Q = 1027'd0;
        else if (regB_en)   regB_Q <= regB_D; //If not reset, paste input for b to register b
    end
  
      // Definition register 2B 
    reg          reg2B_en;   
    wire [1026:0] reg2B_D;   // in
    reg  [1026:0] reg2B_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg2B_Q = 1027'd0;
        else if (reg2B_en)   reg2B_Q <= reg2B_D;
    end
  
      // Definition register 3B 
    reg          reg3B_en;   
    wire [1026:0] reg3B_D;   // in
    reg  [1026:0] reg3B_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg3B_Q = 1027'd0;
        else if (reg3B_en)   reg3B_Q <= reg3B_D;
    end
    
        // Definition register M
    reg          regM_en;   
    wire [1026:0] regM_D;   // in
    reg  [1026:0] regM_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         regM_Q = 1027'd0;
        else if (regM_en)   regM_Q <= regM_D; //If not reset, paste input for m to register b
    end
    
            // Definition register 2M
    reg          reg2M_en;   
    wire [1026:0] reg2M_D;   // in
    reg  [1026:0] reg2M_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg2M_Q = 1027'd0;
        else if (reg2M_en)   reg2M_Q <= reg2M_D;
    end
    
            // Definition register 3M
    reg          reg3M_en;   
    wire [1026:0] reg3M_D;   // in
    reg  [1026:0] reg3M_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)         reg3M_Q = 1027'd0;
        else if (reg3M_en)   reg3M_Q <= reg3M_D;
    end
    
                // Definition register C
    reg          regC_en;   
    wire [1026:0] regC_D;   // in
    reg  [1026:0] regC_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn || start)         regC_Q = 1027'd0;
        else if (regC_en)   regC_Q <= regC_D;
    end
                
    // Definition register regoutadder
    reg          regoutadder_en;   
    wire [1027:0] regoutadder_D;   // in
    reg  [1027:0] regoutadder_Q;   // out
    always @(posedge clk)
    begin
        if(~resetn)                regoutadder_Q = 1028'd0;
        else if (regoutadder_en)   regoutadder_Q <= regoutadder_D;
    end
          
    //shifting preparation stage
    wire [1023:0] operand_outM;
    wire [1024:0] operand_out2M;
    wire [1025:0] operand_out3M;
    
    wire [1023:0] operand_outB;
    wire [1024:0] operand_out2B;
    wire [1025:0] operand_out3B;
    
    wire prep_done_M;
    wire prep_done_B;
      
            //connecting shift_add with the registers
    assign regM_D = operand_outM;
    assign reg2M_D = operand_out2M;
    assign reg3M_D = operand_out3M;
    
    assign regB_D = operand_outB;
    assign reg2B_D = operand_out2B;
    assign reg3B_D = operand_out3B;
    
    reg shift_direction;
    //shift will start when start is put to 1'b1;            
    shift_add_123   shiftM(clk, in_m, start, resetn, prep_done_M, operand_outM, operand_out2M, operand_out3M); //initializes wires adder
    shift_add_123   shiftB(clk, in_b, start, resetn, prep_done_B, operand_outB, operand_out2B, operand_out3B); //initializes wires adder
    
    //reg initialization A and B for addition
    reg  [1026:0] operand_A;   // out
    reg  [1026:0] operand_B;   // out
    always @(posedge clk) begin
        if(~resetn) begin
            operand_A <= 1027'd0;
            operand_B <= 1027'd0;
        end
    end
  
  //adder initialization      
  reg subtract;
  wire adder_done;
  reg start_adder;
 // mpadder adder(clk, resetn, start_adder, subtract, operand_A, operand_B, regoutadder_D, adder_done); //initializes wires adder
 
     mpadder adder (
        .clk(clk),
        .resetn(resetn),
        .start(start_adder),
        .subtract(subtract),
        .in_a(operand_A),
        .in_b(operand_B),
        .result(regoutadder_D),
        .done(adder_done)
    );

  //Shifter initialization 
  reg   shift;
  reg  [1026:0] out_shift;
  always @(posedge clk) begin
        if(~resetn) begin
            out_shift <= 10'b0;
        end
    end
      wire   shift_done;
      reg   enable_shifter;
  

  shift_register shifter(clk, in_shift, shift, shift_direction, resetn, enable_shifter, output_shift, shift_done);

    //this counter thing works, wow
    reg [9:0] i; // Counter for d512 for loop
    reg incrementi;
    always @(posedge clk) begin
        if (~resetn) begin
            i <= 9'b0; // Reset the counter when resetn is low
        end if(incrementi == 1'b1) begin
            i <= i + 2; // Increment the counter on clock edge
        end
    end

    reg start_firstadd;
  // State multiplexing, doing the first addition, another addition based on A and M bits and shift    
    always @(posedge clk) begin
        if (start_firstadd) begin //first addition stage
            // Continuous assignment logic for operand_A
            operand_A <= regC_Q; // Assign regC_Q when state is 2

            // Logic for operand_B based on regA_Q bits
            case ({regA_Q[i + 1], regA_Q[i]})
                2'b01: operand_B <= regB_Q;  // Assign regB_Q if condition matches
                2'b10: operand_B <= reg2B_Q; // Assign reg2B_Q if condition matches
                2'b11: operand_B <= reg3B_Q; // Assign reg3B_Q if condition matches
                default: operand_B <= 10'b0;  // Default case for operand_B
            endcase
        end
    
        start_adder <= start_firstadd; //wait a cycle for regC_Q and RegB to load into adder
        
        if(adder_done)begin
            regC_Q <= regoutadder_D;       //assign output adder to regC
        end
    end



    reg start_secondadd;
    // doing the second addition
    always @(posedge clk) begin
        if (start_secondadd) begin

            if ((regC_Q[1:0] == 2'd1 && regM_Q[1:0] == 2'd1) || 
                (regC_Q[1:0] == 2'd3 && regM_Q[1:0] == 2'd3)) begin
                // Add regC_Q and reg3M_Q
                operand_B <= reg3M_Q; 
                operand_A <= regC_Q;  
            end
            else if ((regC_Q[1:0] == 2'd2 && regM_Q[1:0] == 2'd1) ||
                    (regC_Q[1:0] == 2'd2 && regM_Q[1:0] == 2'd3)) begin
                // Add regC_Q and reg2M_Q
                operand_B <= reg2M_Q; 
                operand_A <= regC_Q;  
            end
            else if ((regC_Q[1:0] == 2'd3 && regM_Q[1:0] == 2'd1) || 
                    (regC_Q[1:0] == 2'd1 && regM_Q[1:0] == 2'd3)) begin
                // Add regC_Q and regM_Q
                operand_B <= regM_Q; 
                operand_A <= regC_Q; 
            end
            else begin
                operand_B <= 10'b0; 
                operand_A <= regC_Q; 
            end 
        end
        start_adder <= start_secondadd; //wait a cycle for regC_Q and RegB to load into adder before addition
            
        regC_Q <= out_shift;
    end
        assign in_shift = regoutadder_Q;

        
        reg start_modulo;
        reg  [1023:0] regComp;   // out 
        reg done_comp;
        
        //Finite state machine should set substract to enabled here
    always @(posedge clk) begin
        if(start_modulo) begin
            operand_A <= regC_Q;
            operand_B <= regM_Q;
            regComp <= regoutadder_Q;
                if(adder_done && ~regComp[1023]) begin
                    regC_Q <= regComp;
                    end else begin
                    done_comp <= 1'b1;
                    end
        end else regComp <= 10'b0;
    end

    assign result = (done_comp) ? regC_Q : 1024'b0;

        //State Machine shifting
        reg [2:0] state, nextstate;   
            always @(posedge clk)
        begin
            if(~resetn)	state <= 3'd0;
            else        state <= nextstate;
        end
        reg regDone;
        
        always @(*) begin //state descriptions
            case(state)
            
            // waiting stage
                3'd0: begin
                    regA_en        <= 1'b1;
                    regB_en        <= 1'b1;
                    reg2B_en       <= 1'b1; 
                    reg3B_en       <= 1'b1;
                    regM_en        <= 1'b1;
                    reg2M_en       <= 1'b1;
                    reg3M_en       <= 1'b1;
                    regC_en        <= 1'b1;
                    
                    subtract       <= 1'b0;
                    i              <= 9'b0;
                    start_secondadd<= 1'b0;
                    start_firstadd <= 1'b0;
                    start_adder    <= 1'b0;
                    shift          <= 1'b0;
                    done_comp      <= 1'b0;
                    //adder_done     <= 1'b0;
                    //shift_done     <= 1'b0;
                    enable_shifter <= 1'b1;
                    regDone        <= 1'b0;
                    shift_direction   <= 1'b1;
                end
                
                // preparation stage;
                3'd1: begin
                    subtract       <= 1'b0;
                    i              <= 9'b0;
                    incrementi     <= 1'b0;
                    start_adder    <= 1'b0;
                    //shift          <= 1'b1;
                    done_comp      <= 1'b0;
                    //adder_done     <= 1'b0;
                    //shift_done     <= 1'b0;
                    enable_shifter <= 1'b1;
                    shift_direction   <= 1'b1;
                end
                
                // First addition stage
                3'd2: begin
                    start_firstadd <= 1'b1;
                    start_secondadd<= 1'b0;
                    subtract       <= 1'b0;
                    start_adder    <= 1'b1; //start the adder for 
                    //shift          <= 1'b0;
                    done_comp      <= 1'b0;
                    enable_shifter <= 1'b0;
                end
                
                //second addition plus shift stage
                3'd3: begin
                    start_firstadd <= 1'b0;
                    start_secondadd<= 1'b1;
                    subtract       <= 1'b0;
                    incrementi     <= 1'b0;
                    start_firstadd <= 1'b0;
                    start_adder    <= 1'b0;
                    //shift          <= 1'b0;
                    done_comp      <= 1'b0;
                    //shift_done     <= 1'b0;
                    enable_shifter <= 1'b0;
                    shift_direction    <= 1'b0;
                end
                
                //subtracting stage
                3'd4: begin
                    start_modulo   <= 1'b1;
                    subtract       <= 1'b1;
                    i              <= 9'b0;
                    incrementi     <= 1'b0;
                    start_adder    <= 1'b1;
                    //shift          <= 1'b0;
                    done_comp      <= 1'b0;
                    //shift_done     <= 1'b0;
                    enable_shifter <= 1'b0;
                end
                //end stage
                3'd5: begin
                    subtract       <= 1'b0;
                    i              <= 9'b0;
                    incrementi     <= 1'b0;
                    start_adder    <= 1'b0;
                    //shift          <= 1'b0;
                    done_comp      <= 1'b0;
                    //shift_done     <= 1'b0;
                    enable_shifter <= 1'b0;
                    regDone        <= 1'b1;
                end
                
                default: begin
                    regA_en        <= 1'b1;
                    regB_en        <= 1'b1;
                    reg2B_en       <= 1'b1; 
                    reg3B_en       <= 1'b1;
                    regM_en        <= 1'b1;
                    reg2M_en       <= 1'b1;
                    reg3M_en       <= 1'b1;
                    regC_en        <= 1'b0;
                    start_secondadd<= 1'b0;
                    start_firstadd <= 1'b0;
                    i              <= 9'b0;
                    incrementi     <= 1'b0;
                    start_adder    <= 1'b0;
                    shift          <= 1'b0;
                    done_comp      <= 1'b0;
                    //shift_done     <= 1'b0;
                    enable_shifter <= 1'b0;
                    regDone        <= 1'b0;
                    shift_direction   <= 1'b0;
                end
            endcase
        end    
        
    //finite state machine
        
        
        always @(posedge clk) begin
            case(state)
                // waiting stage
                3'd0: begin
                    if(start) begin
                        nextstate <= 3'd1;
                        end
                end
                
                //Preparation stage
                3'd1: begin
                    if(prep_done_M && prep_done_B) begin
                        nextstate <= 3'd2;
                    end
                end
                
                //For loop stage(multiplexing, 1st addition
                3'd2: begin
                    if(adder_done == 1'b1) begin
                        nextstate <= 3'd3;
                        incrementi<= 1'b1; //one clock cycle incrementi is high(between switch from st2 to st3
                    end else begin
                        incrementi<= 1'b0;
                    end
                end
                
                //2nd addition, shift)
                3'd3: begin
                    if(i == 10'd512) begin
                        nextstate <= 3'd4;
                    end if(shift_done == 1'b1) begin
                        nextstate <= 3'd2;
                    end
                end
                
                //While loop stage
                3'd4: begin
                    if(done_comp) begin
                        nextstate <= 3'd5;
                    end
                end
                
                //RegC_Q contains answer
                3'd5: begin
                nextstate <= 3'd0;
                end
                
                default: begin
                nextstate <= 3'd0;
                incrementi<= 1'b0;
                end
                endcase
    end
    
    assign done = regDone;
    endmodule

