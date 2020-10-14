/////////////////////////////////
// Module:  pc_reg
// File:    pc_reg.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 指令指针寄存器PC，给出指令地址
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

// PC寄存器模块
module pc_reg(

    input wire clk,
    input wire rst,

    output reg[`InstAddrBus] pc,  // PC指针
	output reg ce

    );
	
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;   //复位的时候指令存储器禁用
		end else begin
			ce <= `ChipEnable;    //复位结束后，指令存储器使能
		end
	end

    always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;   //指令存储器禁用的时候，pc为0
		end else begin
		  	pc <= pc + 4'h4;      //指令存储器使能的时候，pc的值每时钟周期加4
		end
	end

endmodule