/////////////////////////////////
// Module:  mem_wb
// File:    mem_wb.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: mem_wb模块，将访存阶段的运算结果，
// 在下一个时钟周期传递到回写阶段
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module mem_wb(

	input wire clk,
	input wire rst,
	
	
	//from mem	
	input wire[`RegAddrBus]    mem_reg_waddr,
	input wire                 mem_reg_we,
	input wire[`RegBus]        mem_reg_wdata, 	
	
	//to wb
	output reg[`RegAddrBus]    wb_reg_waddr,
	output reg                 wb_reg_we,
	output reg[`RegBus]        wb_reg_wdata
	
	
);


always @ (posedge clk) begin
	if(rst == `RstEnable) begin
		wb_reg_waddr <= `NOPRegAddr;
		wb_reg_we    <= `WriteDisable;
		wb_reg_wdata <= `ZeroWord;	
	end else begin
		wb_reg_waddr <= mem_reg_waddr;
		wb_reg_we    <= mem_reg_we;
		wb_reg_wdata <= mem_reg_wdata;			
	end
end  //always
			

endmodule