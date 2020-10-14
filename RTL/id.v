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
	output reg[`InstBus]       inst_o,
	output reg[`RegBus]         s_op1_o,      //译码得到的源操作数1
	output reg[`RegBus]         s_op2_o,      //译码得到的源操作数2
	output reg[`RegAddrBus]     reg_waddr_o,  //写通用寄存器地址
	output reg                  reg_we_o     //写通用寄存器使能信号
	//output reg[`AluOpBus]       aluop_o,
	//output reg[`AluSelBus]      alusel_o,
);

wire[6:0] opcode = inst_i[6:0];
wire[2:0] funct3 = inst_i[14:12];
wire[6:0] funct7 = inst_i[31:25];
wire[4:0] rd     = inst_i[11:7];
wire[4:0] rs1    = inst_i[19:15];
wire[4:0] rs2    = inst_i[24:20];
  
reg[`RegBus] imm;  //保存指令执行需要的立即数
reg instvalid;     //指示指令是否有效

//--------------  
//对指令进行译码
//--------------
always @ (*) begin	
	if (rst == `RstEnable) begin
		inst_o <= `ZeroWord;
		//aluop_o <= `EXE_NOP_OP;
		//alusel_o <= `EXE_RES_NOP;
		reg_waddr_o <= `NOPRegAddr;
		reg_we_o <= `WriteDisable;
		instvalid <= `InstValid;
		reg1_re_o <= 1'b0;
		reg2_re_o <= 1'b0;
		reg1_raddr_o <= `NOPRegAddr;
		reg2_raddr_o <= `NOPRegAddr;
		imm <= 32'h0;			
	end 
	else begin
		inst_o <= inst_i;
		//aluop_o <= `EXE_NOP_OP;
		//alusel_o <= `EXE_RES_NOP;
		reg_waddr_o <= rd;  //默认的目的寄存器地址
		reg_we_o <= `WriteDisable;
		instvalid <= `InstInvalid;	   
		reg1_re_o <= 1'b0;
		reg2_re_o <= 1'b0;
		reg1_raddr_o <= rs1;  //默认的读通用寄存器1的地址
		reg2_raddr_o <= rs2;  //默认的读通用寄存器2的地址	
		imm <= `ZeroWord;			
		case (opcode)
		  	`INST_TYPE_I: begin                        
				case (funct3)
					`INST_ORI: begin   //ORI指令
                            instvalid <= `InstValid;
                            reg_we_o <= `WriteEnable;
                            reg_waddr_o <= rd;
                            reg1_re_o <= 1'b1;
							reg2_re_o <= 1'b0;
							imm <= inst_i[31:20];
					end 							 
					default: begin
					end
				endcase  //case funct3
			end
		endcase  //case opcode
	end  //else
end  //always
	
//确定进行运算的源操作数1
always @ (*) begin
	if(rst == `RstEnable) begin
		s_op1_o <= `ZeroWord;
	end 
	else if(reg1_re_o == 1'b1) begin
		s_op1_o <= reg1_rdata_i;
	end 
	else if(reg1_re_o == 1'b0) begin
	  	s_op1_o <= imm;
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