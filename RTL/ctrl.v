/////////////////////////////////
// Module:  ctrl
// File:    ctrl.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 控制模块，接收各阶段传递过来的流水线暂停请求信号，
//              从而控制流水线各阶段的刷新、暂停等
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module ctrl(
	
	input wire       rst,
	//input wire       stallreq_from_if,  //来自取指阶段的暂停请求
	input wire       stallreq_from_id,  //来自译码阶段的暂停请求
	input wire       stallreq_from_ex,  //来自执行阶段的暂停请求
	//input wire       stallreq_from_mem, //来自访存阶段的暂停请求
	output reg[5:0]  stall       
	
);

	//stall[0] PC
	//stall[1] IF
	//stall[2] ID
	//stall[3] EX
	//stall[4] MEM
	//stall[5] WB
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			stall <= 6'b000000;
		//end else if(stallreq_from_mem == `Stop) begin
			//stall <= 6'b011111;
		end else if(stallreq_from_ex == `Stop) begin
			stall <= 6'b001111;
		end else if(stallreq_from_id == `Stop) begin
			stall <= 6'b000111;	
		//end else if(stallreq_from_if == `Stop) begin
			//stall <= 6'b000011;			
		end else begin
			stall <= 6'b000000;
		end    //if
	end      //always
			

endmodule