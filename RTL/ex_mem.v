/////////////////////////////////
// Module:  ex_mem
// File:    ex_mem.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: ex_mem模块，将执行阶段取得的运算结果，
// 在下一个时钟周期传递到访存阶段
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module ex_mem(

	input wire clk,
	input wire rst,
	
	
	//from ex	
	input wire[`RegAddrBus]    ex_reg_waddr,
	input wire                 ex_reg_we,
	input wire[`RegBus]        ex_reg_wdata,
	
	input wire[`AluOpBus]      ex_aluop, 
	input wire[`RegBus]        ex_mem_addr,
	input wire[`RegBus]        ex_rt_data,
	
	//to mem
	output reg[`RegAddrBus]    mem_reg_waddr,
	output reg                 mem_reg_we,
	output reg[`RegBus]        mem_reg_wdata,
	
	output reg[`AluOpBus]      mem_aluop, 
	output reg[`RegBus]        mem_mem_addr,
	output reg[`RegBus]        mem_rt_data
	
	
);


	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			mem_reg_waddr <= `NOPRegAddr;
			mem_reg_we    <= `WriteDisable;
			mem_reg_wdata <= `ZeroWord;	
			mem_aluop     <= `EXE_NOP_OP;
			mem_mem_addr  <= `ZeroWord;
			mem_rt_data   <= `ZeroWord;
		end else begin
			mem_reg_waddr <= ex_reg_waddr;
			mem_reg_we    <= ex_reg_we;
			mem_reg_wdata <= ex_reg_wdata;	
			mem_aluop     <= ex_aluop;
			mem_mem_addr  <= ex_mem_addr;
			mem_rt_data   <= ex_rt_data;
		end
	end  //always
			

endmodule