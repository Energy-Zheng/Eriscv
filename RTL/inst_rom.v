/////////////////////////////////
// Module:  inst_rom
// File:    inst_rom.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 指令存储器
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module inst_rom(

	//input wire clk,
	input wire ce,
	input wire[`InstAddrBus]  addr,
	output reg[`InstBus]      inst
	
);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];

	initial $readmemh ( "sample.data", inst_mem );

	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end

endmodule