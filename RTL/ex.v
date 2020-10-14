/////////////////////////////////
// Module:  ex
// File:    ex.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: ex模块，根据传进来的数据进行运算
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module ex(

	input wire rst,
	
	//from id
	input wire[`InstBus]        ex_inst,
	//input wire[`AluOpBus]       aluop_i,
	//input wire[`AluSelBus]      alusel_i,
	input wire[`RegBus]         s_op1_i,
	input wire[`RegBus]         s_op2_i,
	input wire[`RegAddrBus]     reg_waddr_i,
	input wire                  reg_we_i,

	//the result of ex
	output reg[`RegAddrBus]     reg_waddr_o,
	output reg                  reg_we_o,
	output reg[`RegBus]         reg_wdata_o
	
);

wire[6:0] opcode = ex_inst[6 : 0];
wire[2:0] funct3 = ex_inst[14:12];
//wire[6:0] funct7 = ex_inst[31:25];
//wire[4:0] rd     = ex_inst[11: 7];
//wire[4:0] rs1    = ex_inst[19:15];
//wire[4:0] rs2    = ex_inst[24:20];

reg[`RegBus] logicout;

always @ (*) begin
	if(rst == `RstEnable) begin
		logicout <= `ZeroWord;
	end 
	else begin
		case (opcode)
			`INST_TYPE_I: begin
				case (funct3)
					`INST_ORI: begin
						logicout <= s_op1_i | s_op2_i;
					end
					default: begin
						logicout <= `ZeroWord;
					end
				endcase
			end
			default: begin
				logicout <= `ZeroWord;
			end
		endcase
	end    //if
end      //always


always @ (*) begin
	reg_waddr_o <= reg_waddr_i;	 	 	
	reg_we_o <= reg_we_i;
	//case (alusel_i) 
	 	//`EXE_RES_LOGIC:	begin
	 		reg_wdata_o <= logicout;
	 	//end
	 	//default: begin
	 		//reg_wdata_o <= `ZeroWord;
	 	//end
	//endcase
end	

endmodule