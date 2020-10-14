/////////////////////////////////
// Module:  id_ex
// File:    id_ex.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: id_ex模块，暂时保存译码阶段取得的运算类型、源操作数、要写的目的寄存器地址等结果，
// 在下一个时钟周期传递到执行阶段
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module id_ex(

	input wire clk,
	input wire rst,

	
	//from id
	input wire[`InstBus]          id_inst,
	//input wire[`AluOpBus]         id_aluop,
	//input wire[`AluSelBus]        id_alusel,
	input wire[`RegBus]           id_s_op1,
	input wire[`RegBus]           id_s_op2,
	input wire[`RegAddrBus]       id_reg_waddr,
	input wire                    id_reg_we,	
	
	//to ex
	output reg[`InstBus]         ex_inst,
	//output reg[`AluOpBus]         ex_aluop,
	//output reg[`AluSelBus]        ex_alusel,
	output reg[`RegBus]           ex_s_op1,
	output reg[`RegBus]           ex_s_op2,
	output reg[`RegAddrBus]       ex_reg_waddr,
	output reg                    ex_reg_we
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_inst <= `ZeroWord;
			//ex_aluop <= `EXE_NOP_OP;
			//ex_alusel <= `EXE_RES_NOP;
			ex_s_op1 <= `ZeroWord;
			ex_s_op2 <= `ZeroWord;
			ex_reg_waddr <= `NOPRegAddr;
			ex_reg_we <= `WriteDisable;
		end 
		else begin	
			ex_inst <= id_inst;
			//ex_aluop <= id_aluop;
			//ex_alusel <= id_alusel;
			ex_s_op1 <= id_s_op1;
			ex_s_op2 <= id_s_op2;
			ex_reg_waddr <= id_reg_waddr;
			ex_reg_we <= id_reg_we;		
		end
	end
	
endmodule