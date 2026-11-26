

module PipelinedProcessor(clk, reset, enable);
input clk, reset, enable; 
wire [31:0] pcOutF,SEout, inst, PCP4, pcIn, writedata, readdata, readdata1, readdata2, ALUresultEX, ALUinEX, ShiftOUT, JALaddress, out1, out0, outfinal, instF, PCP4F ,PCP4EX,readdata1EX,readdata2EX,SEoutEX,muxOut0,rs1out,rs2out;
wire [31:0] PCP4MEM,addressMEM,writedataMEM,PCP4WB,readdataWB,addressWB,pcOutD, sllout, ALUSLLEX;
wire [2:0] aluop,aluopEX;
wire [1:0] regdst,memtoreg,pcsrc,memtoregEX,memtoregMEM,memtoregWB,ForwardA,ForwardB;
wire [4:0] writereg, rs1,rs2,writeregEX,writeregMEM,writeregWB;
wire  Flash1,Flash2,alusrc, regwrite ,memread, memwrite, branch, Iformat, LW, SW, BEQ, JAL, JALR, equalB, beqsign,pcsrcEX,regwriteEX,memwriteEX,memreadEX,alusrcEX,orOut,regwriteMEM,memwriteMEM,memreadMEM,regwriteWB, SLL, SLLEX;

 //ProgramCounter (Q, D, clk, reset, enable);
   ProgramCounter ProgramCounter1 (pcOutF, pcIn, clk, reset, enable);  

 //Instruction_Memory(PC, instruction);
   Instruction_Memory IM (pcOutF, instF); 

 //Adder32bit (out, a, b);  for PC + 4
   Adder32bit A32B (PCP4F, pcOutF, 32'b0100);

 //OR (out, in1, in2 ,in3);
   OR3 flash1(Flash1, reset, pcsrcEX, orOut);
 //IFID (Q, D, clk, reset, enable);
   IFID IFID1 ({PCP4,pcOutD,inst}, {PCP4F,pcOutF,instF}, clk, Flash1, enable);

 //ControlUnit(aluop, …, JALR, opcode, func3, func7); 
   ControlUnit CU (aluop, alusrc, pcsrc, memtoreg, regwrite ,memread, memwrite, branch, Iformat, LW, SW, BEQ, JAL, JALR, SLL, inst[6:0], inst[14:12],inst[31:25]); 
                                                                                                                                   
 //SignExtend (SEout, in, Iformat, LW, SW, BEQ, JAL, JALR);
   SignExtend SE (SEout, inst, Iformat, LW, SW, BEQ, JAL, JALR);

 //RegFile(readdata1 ,readdata2, ………, clk, reset);
   RegFile RF (readdata1 ,readdata2, inst[19:15], inst[24:20], writedata,writeregWB, regwriteWB, clk, reset);

 //ShiftLeft32_by1(out, in);
   ShiftLeft32_by1 shift1 (ShiftOUT, SEout);

 //Comparator32bit (equal, a, b);
   Comparator32bit CP (equalB, readdata1, readdata2);

 //Adder32bit (out, a, b); to calculate branch/jal target Address
   Adder32bit JALadd (JALaddress, pcOutD, ShiftOUT); 

 //AND (out, in1, in2);
   AND andbeq (beqsign, BEQ, equalB);
  
 //OR (out, in1, in2);
   OR orbeq(orOut, beqsign, pcsrc[0]);

 //Mux_2_to_1_32bit(out, s, i1, i0); branch/jal address or PC + 4
   Mux_2_to_1_32bit mux2321 (muxOut0, orOut, JALaddress, PCP4F);

 //Mux_2_to_1_32bit(out, s, i1, i0); branch/jal address or PC + 4 or ALUex
   Mux_2_to_1_32bit mux2321 (pcIn, pcsrcEX, ALUresultEX, muxOut0);

 //OR (out, in1, in2);
   OR flash2(Flash2, reset, pcsrcEX);
 //IDEX (Q, D, clk, reset, enable);
   IDEX IDEX1({PCP4EX,pcsrcEX, SLLEX, regwriteEX,memtoregEX,memwriteEX,memreadEX,aluopEX,alusrcEX,readdata1EX,readdata2EX,SEoutEX,rs2,rs1,writeregEX}, {PCP4,pcsrc[1], SLL,regwrite,memtoreg,memwrite,memread,aluop,alusrc,readdata1,readdata2,SEout,inst[24:20],inst[19:15],inst[11:7]}, clk, Flash2, enable);

 //ForwardingUnit(ForwardA, ForwardB, EXMEM_Rd, MEMWB_Rd, IDEX_Rs1, IDEX_Rs2, EXMEM_RegWrite, MEMWB_RegWrite);
   ForwardingUnit FU(ForwardA, ForwardB, writeregMEM,writeregWB, rs1,rs2, regwriteMEM, regwriteWB);

 //Mux_3_to_1_32bit(out, s, i2, i1, i0);rs1
   Mux_3_to_1_32bit muxrs1(rs1out,ForwardA, writedata, addressMEM,readdata1EX);

 //Mux_3_to_1_32bit(out, s, i2, i1, i0);rs2
   Mux_3_to_1_32bit muxrs2(rs2out,ForwardB, writedata, addressMEM,readdata2EX);

 //Mux_3_to_1_32bit(out, s, i2, i1, i0); for the input b of the ALU
   Mux_2_to_1_32bit mux232 (ALUinEX, alusrcEX, SEoutEX,rs2out); 

 //ALU_32(result, a, b, m);
   ALU_32 ALu (ALUresultEX , rs1out , ALUinEX , aluopEX);
  
  //SLL(sllout,readdata1,rs2);
  SLL sll (sllout,rs1out,rs2out[4:0]);

  //Mux_2_to_1_32bit(out, s, i1, i0); 
  Mux_2_to_1_32bit ALUSLL (ALUSLLEX, SLLEX, sllout, ALUresultEX); 

 //EXMEM (Q, D, clk, reset, enable);
   EXMEM EXMEM1 ({PCP4MEM,regwriteMEM,memtoregMEM,memwriteMEM,memreadMEM,addressMEM,writedataMEM,writeregMEM}, {PCP4EX,regwriteEX,memtoregEX,memwriteEX,memreadEX,ALUSLLEX,rs2out,writeregEX}, clk, reset, enable);

 //Data_Memory(readdata , address, ……., clk );
   Data_Memory DM(readdata , addressMEM, writedataMEM, memwriteMEM , memreadMEM , clk);

 //MEMWB (Q, D, clk, reset, enable);
   MEMWB MEMWB1 ({PCP4WB,regwriteWB,memtoregWB,readdataWB,addressWB,writeregWB}, {PCP4MEM,regwriteMEM,memtoregMEM,readdata,addressMEM,writeregMEM}, clk, reset, enable);

 //Mux_3_to_1_32bit(out, s, i2, i1, i0);
   Mux_3_to_1_32bit mux3321 (writedata, memtoregWB, PCP4WB, readdataWB, addressWB);


 
endmodule


