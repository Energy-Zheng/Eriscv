/////////////////////////////////
// Module:  id
// File:    id.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: regs模块，对指令进行译码
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module id(

	input wire                  rst,
	
	//from if_id
	input wire[`InstAddrBus]	pc_i,   //指令地址
	input wire[`InstBus]        inst_i, //指令内容
	
	//from regs
	input wire[`RegBus]         reg1_rdata_i, //从regs得到的读通用寄存器1的数据
	input wire[`RegBus]         reg2_rdata_i, //从regs得到的读通用寄存器2的数据

	//to regs
	output reg                  reg1_re_o,    //读通用寄存器1的使能信号
	output reg                  reg2_re_o,    //读通用寄存器2的使能信号   
	output reg[`RegAddrBus]     reg1_raddr_o, //读通用寄存器1的地址
	output reg[`RegAddrBus]     reg2_raddr_o, //读通用寄存器2的地址	      
	
	//to ex
	//output reg[`InstBus]        inst_o,
	output reg[`AluOpBus]       aluop_o,      //指令的运算子类型
	output reg[`AluSelBus]      alusel_o,     //指令的运算子类型
	output reg[`RegBus]         s_op1_o,      //译码得到的源操作数1
	output reg[`RegBus]         s_op2_o,      //译码得到的源操作数2
	output reg[`RegAddrBus]     reg_waddr_o,  //写通用寄存器地址
	output reg                  reg_we_o      //写通用寄存器使能信号
	
);

	wire[6:0] opcode = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];
	wire[6:0] funct7 = inst_i[31:25];

	wire[4:0] rd     = inst_i[11:7];
	wire[4:0] rs1    = inst_i[19:15];
	wire[4:0] rs2    = inst_i[24:20];

	wire[11:0] I_imm = inst_i[31:20];
	wire[19:0] U_imm = inst_i[31:12];
	wire[11:0] S_imm = {inst_i[31:25], inst_i[11:7]};
	wire[11:0] B_imm = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
	wire[19:0] J_imm = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};

	reg[`RegBus] imm1;  //保存指令执行需要的立即数
	reg[`RegBus] imm2;
	reg[`RegBus] mem_offset;
	   
	reg inst_valid;     //指示指令是否有效

	//指令译码操作的宏函数
	`define SET_INST(i_alusel, i_aluop, i_inst_valid, i_reg1_re, i_reg1_raddr, i_reg2_re, i_reg2_raddr, i_reg_we, i_reg_waddr, i_imm1, i_imm2, i_mem_offset) \
			alusel_o = i_alusel; \
			aluop_o = i_aluop; \
			inst_valid = i_inst_valid; \
			reg1_re_o = i_reg1_re; \
			reg1_raddr_o = i_reg1_raddr; \
			reg2_re_o = i_reg2_re; \
			reg2_raddr_o = i_reg2_raddr; \
			reg_we_o = i_reg_we; \
			reg_waddr_o = i_reg_waddr; \
			imm1 = i_imm1; \
			imm2 = i_imm2; \
			mem_offset = i_mem_offset;

	//--------------  
	//对指令进行译码
	//--------------
	always @ (*) begin	
		if (rst == `RstEnable) begin
			`SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 0, `NOPRegAddr, 0, 0, 0)			
		end 
		else begin
			`SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, `InstValid, 0, rs1, 0, rs2, 0, rd, 0, 0, 0)
			case (opcode)
				`OP_LUI : begin
					`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 1, rd, ({U_imm, 12'b0}), 0, 0)
				end
				`OP_AUIPC : begin
					`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 1, rd, ({U_imm, 12'b0}), pc_i, 0)
				end
				`OP_ARITH_IMM: begin                        
					case (funct3)
						`FUNCT3_ADDI : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, 0, ({{20{I_imm[11]}}, I_imm}), 0)
						end
						`FUNCT3_SLTI : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, 0, ({{20{I_imm[11]}}, I_imm}), 0)
						end
						`FUNCT3_SLTIU : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, 0, ({{20{I_imm[11]}}, I_imm}), 0)
						end
						`FUNCT3_XORI : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, 0, ({20'h0, I_imm}), 0)
						end
						`FUNCT3_ORI: begin   //ORI指令
							`SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, 0, ({20'h0, I_imm}), 0)
						end
						`FUNCT3_ANDI : begin
								`SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, 1, 1, rs1, 0, 0, 1, rd, 0, ({20'h0, I_imm}), 0)
						end
						`FUNCT3_SLLI : begin
							`SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, 1, 1, rs1, 0, 0, 1, rd, 0, rs2, 0)
						end
						`FUNCT3_SRLI_SRAI : begin
							case (funct7)
								`FUNCT7_SRLI : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, 1, 1, rs1, 0, 0, 1, rd, 0, rs2, 0)
								end
								`FUNCT7_SRAI : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, 1, 1, rs1, 0, 0, 1, rd, 0, rs2, 0)
								end
								default : begin
								end
							endcase  //case funct7
						end
						default : begin
						end
					endcase // casefunct3
				end
				`OP_ARITH: begin
					case (funct3)
						`FUNCT3_ADD_SUB : begin
							case (funct7)
								`FUNCT7_ADD : begin
									`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
								end
								`FUNCT7_SUB : begin
									`SET_INST(`EXE_RES_ARITH, `EXE_SUB_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
								end
								default : begin
								end
							endcase // funct7
						end
						`FUNCT3_SLL : begin
							`SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
						end
						`FUNCT3_SLT : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
						end
						`FUNCT3_SLTU : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
						end
						`FUNCT3_XOR : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
						end
						`FUNCT3_SRL_SRA : begin
							case (funct7)
								`FUNCT7_SRL : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
								end
								`FUNCT7_SRA : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
								end
								default : begin
								end
							endcase // funct7
						end
						`FUNCT3_OR : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
						end
						`FUNCT3_AND : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, 1, 1, rs1, 1, rs2, 1, rd, 0, 0, 0)
						end
						default : begin
						end
					endcase // funct3
				end
				default : begin
				end
			endcase  //case opcode
		end  //else
	end  //always


	//确定进行运算的源操作数的宏函数
	`define SET_S_OP(s_op, re, reg_data, imm) \
		if(rst == `RstEnable) begin \
			s_op = `ZeroWord; \
		end \
		else if(re == 1'b1) begin \
			s_op = reg_data; \
		end \
		else if(re == 1'b0) begin \
			s_op = imm; \
		end \
		else begin \
			s_op = `ZeroWord; \
		end
		

	//确定进行运算的源操作数1
	always @ (*) begin
		`SET_S_OP(s_op1_o, reg1_re_o, reg1_rdata_i, imm1)
	end

	//确定进行运算的源操作数2
	always @ (*) begin
		`SET_S_OP(s_op2_o, reg2_re_o, reg2_rdata_i, imm2)
	end
		

endmodule