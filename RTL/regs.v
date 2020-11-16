/////////////////////////////////
// Module:  regs
// File:    regs.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: regs模块，实现了32个32位通用整数寄存器，
// 可以同时进行两个寄存器的读操作和一个寄存器的写操作
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module regs(

	input wire clk,
	input wire rst,
	
	//写端口
	input wire               we,     //写使能信号
	input wire[`RegAddrBus]  waddr,  //要写入的寄存器地址
	input wire[`RegBus]      wdata,  //要写入的数据
	
	//读端口1
	input wire               re1,    //读使能信号
	input wire[`RegAddrBus]  raddr1, //要读取的寄存器地址
	output reg[`RegBus]      rdata1, //读取的值
	
	//读端口2
	input wire               re2,    //读使能信号
	input wire[`RegAddrBus]	 raddr2, //要读取的寄存器地址
	output reg[`RegBus]      rdata2  //读取的值
	
);

//定义32个32位寄存器
reg[`RegBus]  regs[0:`RegNum-1];

//寄存器写操作
always @ (posedge clk) begin
	if (rst == `RstDisable) begin
		if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
			regs[waddr] <= wdata;
		end
	end
end
	
//读端口1的读操作
always @ (*) begin
	if(rst == `RstEnable) begin
		rdata1 = `ZeroWord;
	end else if(raddr1 == `RegNumLog2'h0) begin  
	  	rdata1 = `ZeroWord;   //如果读取的是$0，那么直接给出0
	end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
		rdata1 = wdata;   //如果要读取的目标寄存器与要写入的目标寄存器是同一个
		                   //那么直接将要写入的值作为读寄存器端口的输出
	end else if(re1 == `ReadEnable) begin
	    rdata1 = regs[raddr1];
	end else begin
	    rdata1 = `ZeroWord;
	end
end

//读端口2的读操作（与上面类似）
always @ (*) begin
	if(rst == `RstEnable) begin
		rdata2 = `ZeroWord;
	end else if(raddr2 == `RegNumLog2'h0) begin
	  	rdata2 = `ZeroWord;
	end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
	  	rdata2 = wdata;
	end else if(re2 == `ReadEnable) begin
	    rdata2 = regs[raddr2];
	end else begin
	    rdata2 = `ZeroWord;
	end
end

endmodule