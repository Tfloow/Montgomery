FLAGS=-Wextra -Wall -Wfloat-equal -Wundef -Wshadow -Wpointer-arith -Wcast-align -Wstrict-prototypes -Wstrict-overflow=5 -Wwrite-strings -Waggregate-return -Wcast-qual -Wswitch-default -Wswitch-enum -Wconversion -Wunreachable-code

bit: bit_finder.c
	gcc $? -o main $(FLAGS)
	./main

main: main.c
	gcc $? -o main $(FLAGS)
	./main.exe

convert: convert_to_verilog.c
	gcc $? -o convert $(FLAGS)
	./convert

txt: txt_to_int.c
	@ gcc $? -o main $(FLAGS)
	@ ./main.exe "Hello World ! This is a test text for the RSA algorithm. This text is longer than 128 characters to check the splitting of message. Does it work ?"