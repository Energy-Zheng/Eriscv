/////////////////////////////////
// Module:  if_id
// File:    if_id.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: if_id模块，暂时保存取指阶段取得的指令，以及对应的指令地址
// 在下一个时钟周期传递到译码阶段
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module if_id(

	input wire clk,
	input wire rst,
	
	//from pc_reg
	input wire[`InstAddrBus]  if_pc,
	input wire[`InstBus]      if_inst,
	
	//to id
	output reg[`InstAddrBus]  id_pc,
	output reg[`InstBus]      id_inst  
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
	  end else begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
	end

endmodule