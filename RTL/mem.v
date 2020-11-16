/////////////////////////////////
// Module:  mem
// File:    mem.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: mem模块，若是加载存储指令则对数据存储器进行操作，
// 否则将执行阶段取得的运算结果向回写阶段传递
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module mem(

	input wire rst,
	
	//from ex	
	input wire[`RegAddrBus]   reg_waddr_i,
	input wire                reg_we_i,
	input wire[`RegBus]       reg_wdata_i,
	
	//to wb
	output reg[`RegAddrBus]   reg_waddr_o,
	output reg                reg_we_o,
	output reg[`RegBus]       reg_wdata_o
	
);

	
always @ (*) begin
	if(rst == `RstEnable) begin
		reg_waddr_o = `NOPRegAddr;
		reg_we_o = `WriteDisable;
		reg_wdata_o = `ZeroWord;
	end else begin
		reg_waddr_o = reg_waddr_i;
		reg_we_o = reg_we_i;
		reg_wdata_o = reg_wdata_i;
	end  
end  //always
			

endmodule