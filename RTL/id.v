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
	
	//from ex
	input wire                  ex_reg_we_i,     //处于执行阶段的指令是否要写目的寄存器
	input wire[`RegBus]         ex_reg_wdata_i,  //处于执行阶段的指令要写入目的寄存器的数据
	input wire[`RegAddrBus]     ex_reg_waddr_i,  //处于执行阶段的指令要写的目的寄存器地址
	
	//from mem
	input wire                  mem_reg_we_i,    //处于访存阶段的指令是否要写目的寄存器
	input wire [`RegBus]        mem_reg_wdata_i, //处于访存阶段的指令要写入目的寄存器的数据
	input wire [`RegAddrBus]    mem_reg_waddr_i, //处于访存阶段的指令要写的目的寄存器地址
	
	//to regs
	output reg                  reg1_re_o,    //读通用寄存器1的使能信号
	output reg                  reg2_re_o,    //读通用寄存器2的使能信号   
	output reg[`RegAddrBus]     reg1_raddr_o, //读通用寄存器1的地址
	output reg[`RegAddrBus]     reg2_raddr_o, //读通用寄存器2的地址	      
	
	//to ex
	output reg[`AluOpBus]       aluop_o,      //指令的运算子类型
	output reg[`AluSelBus]      alusel_o,     //指令的运算子类型
	output reg[`RegBus]         s_op1_o,      //译码得到的源操作数1
	output reg[`RegBus]         s_op2_o,      //译码得到的源操作数2
	output reg[`RegAddrBus]     reg_waddr_o,  //写通用寄存器地址
	output reg                  reg_we_o,     //写通用寄存器使能信号
	
	//output wire[`RegBus]        inst_o,       //当前处于译码阶段的指令（供加载存储指令使用）
	
	//转移指令需要用到的信息
	output reg                  branch_flag_o,  //是否发生转移
	output reg[`RegBus]         branch_addr_o,  //转移到的目标地址      
	output reg[`RegBus]         link_addr_o,    //转移指令要保存的返回地址
	
	output reg[`RegBus]         mem_offset
	
);

	//assign inst_o = inst_i；
	
	wire[6:0] opcode = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];
	wire[6:0] funct7 = inst_i[31:25];

	wire[4:0] rd     = inst_i[11:7];
	wire[4:0] rs1    = inst_i[19:15];
	wire[4:0] rs2    = inst_i[24:20];
	
	wire[4:0] shamt  = inst_i[24:20];

	wire[31:0] I_imm = {{21{inst_i[31]}},inst_i[31:20]};
	wire[31:0] U_imm = {inst_i[31],inst_i[30:12],12'b0};
	wire[31:0] S_imm = {{21{inst_i[31]}},inst_i[30:25], inst_i[11:7]};
	wire[31:0] B_imm = {{22{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8],1'b0};
	wire[31:0] J_imm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21],1'b0};

	reg[`RegBus] imm;  //保存指令执行需要的立即数
	//reg[`RegBus] imm2;
	//reg[`RegBus] mem_offset;
	   
	reg inst_valid;     //指示指令是否有效
	
	//转移指令中的地址计算
	wire[`InstAddrBus] pc_plus_4;
	wire[`InstAddrBus] reg1_plus_I_imm;
    wire[`InstAddrBus] pc_plus_J_imm;
    wire[`InstAddrBus] pc_plus_B_imm;
    
	assign pc_plus_4 = pc_i + 4;
    assign reg1_plus_I_imm = reg1_rdata_i + I_imm;
    assign pc_plus_J_imm = pc_i + J_imm;
   	assign pc_plus_B_imm = pc_i + B_imm;
    
	
	//条件转移指令需要用到的比较信息
	wire reg1_reg2_eq;
    wire reg1_reg2_ne;
    wire reg1_reg2_lt;
    wire reg1_reg2_ltu;
    wire reg1_reg2_ge;
    wire reg1_reg2_geu;
	
    assign reg1_reg2_eq  = (s_op1_o == s_op2_o);
    assign reg1_reg2_ne  = (s_op1_o != s_op2_o);
	assign reg1_reg2_lt  = ($signed(s_op1_o) < $signed(s_op2_o));
	assign reg1_reg2_ltu = (s_op1_o < s_op2_o);
	assign reg1_reg2_ge  = ($signed(s_op1_o) >= $signed(s_op2_o));
	assign reg1_reg2_geu = (s_op1_o >= s_op2_o);

	//指令译码操作的宏函数
	`define SET_INST(i_alusel, i_aluop, i_inst_valid, i_reg1_re, i_reg1_raddr, i_reg2_re, i_reg2_raddr, i_reg_we, i_reg_waddr, i_imm, i_mem_offset) \
			alusel_o <= i_alusel; \
			aluop_o <= i_aluop; \
			inst_valid <= i_inst_valid; \
			reg1_re_o <= i_reg1_re; \
			reg1_raddr_o <= i_reg1_raddr; \
			reg2_re_o <= i_reg2_re; \
			reg2_raddr_o <= i_reg2_raddr; \
			reg_we_o <= i_reg_we; \
			reg_waddr_o <= i_reg_waddr; \
			imm <= i_imm; \
			mem_offset <= i_mem_offset;
			
	`define SET_BRANCH(i_br, i_br_addr, i_link_addr) \
			branch_flag_o <= i_br; \
			branch_addr_o <= i_br_addr; \
			link_addr_o <= i_link_addr;

	//--------------  
	//对指令进行译码
	//--------------
	always @ (*) begin	
		if (rst == `RstEnable) begin
			`SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 0, `NOPRegAddr, 0, 0)
			`SET_BRANCH(0, 0, 0)
		end 
		else begin
			`SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, `InstValid, 0, rs1, 0, rs2, 0, rd, 0, 0)
			`SET_BRANCH(0, 0, 0)
			case (opcode)
				`OP_LUI : begin
					`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 1, rd, U_imm, 0)
				end
				`OP_AUIPC : begin
					`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 1, rd, U_imm, 0)
				end
				`OP_JAL : begin
					`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_JAL_OP, `InstValid, 0, `NOPRegAddr, 0, `NOPRegAddr, 1, rd, 0, 0)
					`SET_BRANCH(1, pc_plus_J_imm, pc_plus_4)
				end
				`OP_JALR : begin
					`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_JALR_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, 0, 0)
					`SET_BRANCH(1, (reg1_plus_I_imm & (~1)), pc_plus_4)
				end
				`OP_BRANCH : begin
					case (funct3)
						`FUNCT3_BEQ : begin
							`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_BEQ_OP, `InstValid, 1, rs1, 1, rs2, 0, `NOPRegAddr, 0, 0)
							if (reg1_reg2_eq) `SET_BRANCH(1, pc_plus_B_imm, 0)
						end
						`FUNCT3_BNE : begin
							`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_BNE_OP, `InstValid, 1, rs1, 1, rs2, 0, `NOPRegAddr, 0, 0)
							if (reg1_reg2_ne) `SET_BRANCH(1, pc_plus_B_imm, 0)
						end
						`FUNCT3_BLT : begin
							`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_BLT_OP, `InstValid, 1, rs1, 1, rs2, 0, `NOPRegAddr, 0, 0)
							if (reg1_reg2_lt) `SET_BRANCH(1, pc_plus_B_imm, 0)
						end
						`FUNCT3_BGE : begin
							`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_BGE_OP, `InstValid, 1, rs1, 1, rs2, 0, `NOPRegAddr, 0, 0)
							if (reg1_reg2_ge) `SET_BRANCH(1, pc_plus_B_imm, 0)
						end
						`FUNCT3_BLTU : begin
							`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_BLTU_OP, `InstValid, 1, rs1, 1, rs2, 0, `NOPRegAddr, 0, 0)
							if (reg1_reg2_ltu) `SET_BRANCH(1, pc_plus_B_imm, 0)
						end
						`FUNCT3_BGEU : begin
							`SET_INST(`EXE_RES_JUMP_BRANCH, `EXE_BGEU_OP, `InstValid, 1, rs1, 1, rs2, 0, `NOPRegAddr, 0, 0)
							if (reg1_reg2_geu) `SET_BRANCH(1, pc_plus_B_imm, 0)
						end
						default : begin
						end
					endcase // funct3
				end
				`OP_ARITH_IMM: begin                        
					case (funct3)
						`FUNCT3_ADDI : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, I_imm, 0)
						end
						`FUNCT3_SLTI : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, I_imm, 0)
						end
						`FUNCT3_SLTIU : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, I_imm, 0)
						end
						`FUNCT3_XORI : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, I_imm, 0)
						end
						`FUNCT3_ORI: begin   //ORI指令
							`SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, I_imm, 0)
						end
						`FUNCT3_ANDI : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, I_imm, 0)
						end
						`FUNCT3_SLLI : begin
							`SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, shamt, 0)
						end
						`FUNCT3_SRLI_SRAI : begin
							case (funct7)
								`FUNCT7_SRLI : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, shamt, 0)
								end
								`FUNCT7_SRAI : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, `InstValid, 1, rs1, 0, `NOPRegAddr, 1, rd, shamt, 0)
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
									`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
								end
								`FUNCT7_SUB : begin
									`SET_INST(`EXE_RES_ARITH, `EXE_SUB_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
								end
								default : begin
								end
							endcase // funct7
						end
						`FUNCT3_SLL : begin
							`SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
						end
						`FUNCT3_SLT : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
						end
						`FUNCT3_SLTU : begin
							`SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
						end
						`FUNCT3_XOR : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
						end
						`FUNCT3_SRL_SRA : begin
							case (funct7)
								`FUNCT7_SRL : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
								end
								`FUNCT7_SRA : begin
									`SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
								end
								default : begin
								end
							endcase // funct7
						end
						`FUNCT3_OR : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
						end
						`FUNCT3_AND : begin
							`SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, `InstValid, 1, rs1, 1, rs2, 1, rd, 0, 0)
						end
						default : begin
						end
					endcase // funct3
				end
				`OP_LOAD : begin
					case (funct3)
						`FUNCT3_LB : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_LB_OP, `InstValid, 1, rs1, 0, 0, 1, rd, 0, I_imm)
						end
						`FUNCT3_LH : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_LH_OP, `InstValid, 1, rs1, 0, 0, 1, rd, 0, I_imm)
						end
						`FUNCT3_LW : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_LW_OP, `InstValid, 1, rs1, 0, 0, 1, rd, 0, I_imm)
						end
						`FUNCT3_LBU : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_LBU_OP, `InstValid, 1, rs1, 0, 0, 1, rd, 0, I_imm)
						end
						`FUNCT3_LHU : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_LHU_OP, `InstValid, 1, rs1, 0, 0, 1, rd, 0, I_imm)
						end
						default : begin
						end
					endcase // funct3
				end
				`OP_STORE : begin
					case (funct3)
						`FUNCT3_SB : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_SB_OP, `InstValid, 1, rs1, 1, rs2, 0, 0, 0, S_imm)
						end
						`FUNCT3_SH : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_SH_OP, `InstValid, 1, rs1, 1, rs2, 0, 0, 0, S_imm)
						end
						`FUNCT3_SW : begin
							`SET_INST(`EXE_RES_LOAD_STORE, `EXE_SW_OP, `InstValid, 1, rs1, 1, rs2, 0, 0, 0, S_imm)
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


	//确定进行运算的源操作数1
	always @ (*) begin
		if(rst == `RstEnable) begin 
			s_op1_o <= `ZeroWord; 
		end 
		else if((reg1_re_o == 1'b1) && (ex_reg_we_i == 1'b1) && (ex_reg_waddr_i == reg1_raddr_o)) begin 
			s_op1_o <= ex_reg_wdata_i; 
		end 
		else if((reg1_re_o == 1'b1) && (mem_reg_we_i == 1'b1) && (mem_reg_waddr_i == reg1_raddr_o)) begin 
			s_op1_o <= mem_reg_wdata_i; 
		end 
		else if(reg1_re_o == 1'b1) begin 
			s_op1_o <= reg1_rdata_i; 
		end 
		else if((reg1_re_o == 1'b0) && (opcode == `OP_AUIPC)) begin 
			s_op1_o <= pc_i; 
		end 
		else begin 
			s_op1_o <= `ZeroWord; 
		end
	end

	//确定进行运算的源操作数2
	always @ (*) begin
		if(rst == `RstEnable) begin 
			s_op2_o <= `ZeroWord; 
		end 
		else if((reg2_re_o == 1'b1) && (ex_reg_we_i == 1'b1) && (ex_reg_waddr_i == reg2_raddr_o)) begin 
			s_op2_o <= ex_reg_wdata_i; 
		end 
		else if((reg2_re_o == 1'b1) && (mem_reg_we_i == 1'b1) && (mem_reg_waddr_i == reg2_raddr_o)) begin 
			s_op2_o <= mem_reg_wdata_i; 
		end 
		else if(reg2_re_o == 1'b1) begin 
			s_op2_o <= reg2_rdata_i; 
		end 
		else if(reg2_re_o == 1'b0) begin 
			s_op2_o <= imm; 
		end 
		else begin 
			s_op2_o <= `ZeroWord; 
		end
	end



endmodule