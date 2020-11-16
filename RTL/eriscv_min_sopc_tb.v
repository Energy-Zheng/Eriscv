/////////////////////////////////
// Module:  eriscv_min_sopc_tb
// File:    eriscv_min_sopc_tb.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: eriscv_min_sopc的testbench，给出时钟和复位信号
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"
`timescale 1ns/1ps

module eriscv_min_sopc_tb();

	reg CLOCK_50;
	reg rst;
      
initial begin
	CLOCK_50 = 1'b0;
	forever #10 CLOCK_50 = ~CLOCK_50;
end
      
initial begin
    rst = `RstEnable;
    #195 rst= `RstDisable;
    #1000 $stop;
end
       
eriscv_min_sopc eriscv_min_sopc0(
	.clk(CLOCK_50),
	.rst(rst)	
);

endmodule