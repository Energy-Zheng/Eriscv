/////////////////////////////////
// Module:  multiplier
// File:    multiplier.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 进行乘法计算
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module multiplier(

	input wire signed[`DATA_LEN-1:0] src1,
	input wire signed[`DATA_LEN-1:0] src2,
	input wire 			             src1_signed,
	input wire 			             src2_signed,
	input wire[`MD_OUT_SEL_WIDTH-1:0]	 md_out_sel,
	output wire[`DATA_LEN-1:0] 	     result
	
);

	wire signed[`DATA_LEN:0]         src1_unsign = {1'b0, src1};
	wire signed[`DATA_LEN:0]         src2_unsign = {1'b0, src2};

	wire signed[2*`DATA_LEN-1:0]     res_ss = src1 * src2;
	wire signed[2*`DATA_LEN-1:0]     res_su = src1 * src2_unsign;
	wire signed[2*`DATA_LEN-1:0]     res_us = src1_unsign * src2;
	wire signed[2*`DATA_LEN-1:0]     res_uu = src1_unsign * src2_unsign;

	wire[2*`DATA_LEN-1:0]            res;
	wire                             sel_lohi = md_out_sel[0];

	mux_4x1 mxres(
		.sel({src1_signed, src2_signed}),
		.data0(res_uu),
		.data1(res_us),
		.data2(res_su),
		.data3(res_ss),
		.out(res)
	);
   
	assign result = sel_lohi ? res[`DATA_LEN+:`DATA_LEN] : res[`DATA_LEN-1:0];
   
endmodule // multiplier


module mux_4x1(

	input wire [1:0] 	    sel,
	input wire [2*`DATA_LEN-1:0] data0,
	input wire [2*`DATA_LEN-1:0] data1,
	input wire [2*`DATA_LEN-1:0] data2,
	input wire [2*`DATA_LEN-1:0] data3,
	output reg [2*`DATA_LEN-1:0] out
	
);

	always @(*) begin
		case(sel)
			0: out = data0;
			1: out = data1;
			2: out = data2;
			3: out = data3;
		endcase
	end
	
endmodule // mux_4x1
