/////////////////////////////////
// Module:  ex
// File:    ex.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: ex模块，根据传进来的数据进行运算
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module ex(

	input wire rst,
	
	//from id
	input wire[`AluOpBus]       aluop_i,
	input wire[`AluSelBus]      alusel_i,
	input wire[`RegBus]         s_op1_i,
	input wire[`RegBus]         s_op2_i,
	input wire[`RegAddrBus]     reg_waddr_i,
	input wire                  reg_we_i,
	input wire[`RegBus]         link_addr_i, //处于执行阶段的转移指令需要保持的返回地址
	input wire[`RegBus]         mem_offset,

	//the result of ex
	output reg[`RegAddrBus]     reg_waddr_o,
	output reg                  reg_we_o,
	output reg[`RegBus]         reg_wdata_o,
	
	//为加载存储指令准备的输出接口
	output wire[`AluOpBus]      aluop_o,
	output reg[`RegBus]         mem_addr_o,
	output wire[`RegBus]        rt_data_o
	
);

	reg[`RegBus] logic_out;
	reg[`RegBus] shift_out;
	reg[`RegBus] arith_out;
	reg[`RegBus] mem_out;

	//aluop_o传递到访存阶段，用于加载、存储指令
	assign aluop_o = aluop_i;
	
	//存储指令中s_op2_i保存要存储的数据，通过rt_data接口传递到访存阶段
	assign rt_data_o = s_op2_i;

	// EXE_RES_LOGIC
	always @ (*) begin
		if((rst == `RstEnable) || (alusel_i != `EXE_RES_LOGIC)) begin
			logic_out <= `ZeroWord;
		end 
		else begin
			case (aluop_i)
				`EXE_XOR_OP: begin
					logic_out <= s_op1_i ^ s_op2_i;
				end
				`EXE_OR_OP : begin
					logic_out <= s_op1_i | s_op2_i;
				end
				`EXE_AND_OP : begin
					logic_out <= s_op1_i & s_op2_i;
				end
				default: begin
					logic_out <= `ZeroWord;
				end
			endcase// aluop
		end    // else
	end // always


	// EXE_RES_SHIFT
	always @ (*) begin
		if((rst == `RstEnable) || (alusel_i != `EXE_RES_SHIFT)) begin
			shift_out = `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP : begin
					shift_out <= s_op1_i << s_op2_i[4:0];
				end
				`EXE_SRL_OP : begin
					shift_out <= s_op1_i >> s_op2_i[4:0];
				end
				`EXE_SRA_OP : begin  //32位的数算术右移X位，先将该数逻辑右移X位，再将32位全符号数逻辑左移（32-X）位，将两者按位或
					shift_out <= ({32{s_op1_i[31]}} << (6'd32 - {1'b0, s_op2_i[4:0]})) | (s_op1_i >> s_op2_i[4:0]);
					end
				default : begin
					shift_out <= `ZeroWord;
				end
			endcase // aluop
		end //  else
	end // always

	// EXE_RES_ARITH
	always @ (*) begin
		if((rst == `RstEnable) || (alusel_i != `EXE_RES_ARITH)) begin
			arith_out <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ADD_OP : begin
					arith_out <= s_op1_i + s_op2_i;
				end
				`EXE_SUB_OP : begin
					arith_out <= s_op1_i - s_op2_i;
				end
				`EXE_SLT_OP : begin
					arith_out <= $signed(s_op1_i) < $signed(s_op2_i);
				end
				`EXE_SLTU_OP : begin
					arith_out <= s_op1_i < s_op1_i;
				end
				default : begin
					arith_out <= `ZeroWord;
				end
			endcase // aluop
		end // else
	end // always 
	
	// EXE_RES_LOAD_STORE
	always @ (*) begin
		if((rst == `RstEnable) || (alusel_i != `EXE_RES_LOAD_STORE)) begin
			mem_out <= `ZeroWord;
		end else begin
			mem_out <= s_op1_i + mem_offset;
		end // end else
	end // always @ (*)



	//根据alusel_i选择最终的运算结果
	always @ (*) begin
		reg_waddr_o <= reg_waddr_i;	 	 	
		reg_we_o <= reg_we_i;
		mem_addr_o <= 0;
		case (alusel_i) 
			`EXE_RES_LOGIC:	begin
				//$display("EXE_RES_LOGIC");
				reg_wdata_o <= logic_out;
			end
			`EXE_RES_SHIFT : begin
				//$display("EXE_RES_SHIFT");
				reg_wdata_o <= shift_out;
			end
			`EXE_RES_ARITH : begin
				//$display("EXE_RES_ARITH");
				reg_wdata_o <= arith_out;
			end
			`EXE_RES_JUMP_BRANCH : begin
				reg_wdata_o <= link_addr_i;
			end
			`EXE_RES_LOAD_STORE : begin
				//$display("EXE_RES_LOAD_STORE");
				reg_wdata_o <= 0;
				mem_addr_o <= mem_out;
			end
			default: begin
				reg_wdata_o <= `ZeroWord;
			end
		endcase
	end	

endmodule