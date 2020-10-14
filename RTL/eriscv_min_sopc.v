/////////////////////////////////
// Module:  最小SOPC
// File:    eriscv_min_sopc.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 为了验证处理器，需要建立一个SOPC，其中仅包含Eriscv和指令存储器ROM
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module eriscv_min_sopc(

	input wire clk,
	input wire rst
	
);

	//连接指令存储器
	wire[`InstAddrBus] inst_addr;
	wire[`InstBus] inst;
	wire rom_ce;
 

	eriscv eriscv0(
		.clk(clk),
		.rst(rst),
	
		.rom_data_i(inst),
		.rom_addr_o(inst_addr),	
		.rom_ce_o(rom_ce)
	
	);
	
	inst_rom inst_rom0(
		.addr(inst_addr),
		.inst(inst),
		.ce(rom_ce)	
	);


endmodule