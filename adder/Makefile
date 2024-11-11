montgomery_thomas_tb.v:
	iverilog -o montgomery_thomas_tb.vvp montgomery_thomas_tb.v 
	vvp montgomery_thomas_tb.vvp 
	gtkwave tb_montgomery.vcd

montgomery:
	iverilog -o montgomery_tb.vvp montgomery_tb.v 
	vvp montgomery_tb.vvp 
	gtkwave tb_montgomery.vcd

multiplexer:
	iverilog -o seven_multiplexer_tb.vvp seven_multiplexer_tb.v 
	vvp seven_multiplexer_tb.vvp
	gtkwave tb_multi.vcd

adder:
	iverilog -o adder_tb.vvp adder_tb.v 
	vvp adder_tb.vvp
	gtkwave mpadder.vcd

clean:
	rm *.vvp 
	rm *.vcd

.PHONY: montgomery_thomas_tb.v