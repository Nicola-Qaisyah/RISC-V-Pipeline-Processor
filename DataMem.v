
module Data_Memory(readdata , address, writedata , memwrite , memread , clk); 
input [31:0] address , writedata ; 
input memwrite , memread , clk; 
output [31:0] readdata; 
integer i;
reg [31:0] Dm [255:0];
reg [31:0] readdata;

initial begin 
for (i=0; i<256; i=i+1)
Dm[i]=i;
end

always@(address or memread)
begin 
#15;
if (memread==1)
readdata=Dm[address>>2];
end
always@(posedge clk)
begin 
#10;
if (memwrite==1)
Dm[address>>2]=writedata;
end

endmodule 
