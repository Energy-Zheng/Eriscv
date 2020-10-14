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
	
	//to mem
	output reg[`RegAddrBus]    mem_reg_waddr,
	output reg                 mem_reg_we,
	output reg[`RegBus]        mem_reg_wdata
	
	
);


always @ (posedge clk) begin
	if(rst == `RstEnable) begin
		mem_reg_waddr <= `NOPRegAddr;
		mem_reg_we    <= `WriteDisable;
		mem_reg_wdata <= `ZeroWord;	
	end else begin
		mem_reg_waddr <= ex_reg_waddr;
		mem_reg_we    <= ex_reg_we;
		mem_reg_wdata <= ex_reg_wdata;			
	end
end  //always
			

endmodule