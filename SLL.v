module SLL(sllout,readdata1,rs2);
input[31:0] readdata1;
input[4:0] rs2; 
output[31:0] sllout;
reg [31:0] sllout;
always @(readdata1 or rs2) begin
   #3
   sllout = readdata1 << rs2[4:0]; 

end

endmodule 
