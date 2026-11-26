module Instruction_Memory(PC, instruction);
	input [31:0] PC; 
	output [31:0] instruction; 
	reg [31:0] instruction; 
	reg [31:0] IM [255:0]; 
	initial begin 
		 IM[0] = 32'h00812083;

		 IM[1] = 32'h01012103;

		 IM[2] = 32'h00402183;

		 IM[3] = 32'h02C02303;

		 IM[4] = 32'h00208233;

               IM[5] = 32'h002212B3;

		 IM[6] = 32'h0FE37093;

		 IM[7] = 32'h00309133;

		 IM[8] = 32'h001080B3;

		 IM[9] = 32'h00802583;

               IM[10]= 32'h00202233;

               IM[11]= 32'hFE208AE3;

               IM[12]= 32'h00802083;



               
	end 
	always @ (PC ) 
		#15 instruction = IM[PC>>2]; 
endmodule 
