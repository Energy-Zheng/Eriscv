/////////////////////////////////
// Module:  Eriscv
// File:    eriscv.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 顶层模块Eriscv，对流水线各个阶段的模块进行例化、连接
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module eriscv(

	input wire clk,
	input wire rst,
	
	input wire[`RegBus]   rom_data_i,  //从指令存储器取得的指令
	output wire[`RegBus]  rom_addr_o,  //输出到指令存储器的地址
	output wire           rom_ce_o     //指令存储器使能信号
	
);

	//连接IF/ID模块与译码阶段ID模块的变量
	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus]     id_inst_i;
	
	//连接译码阶段ID模块的输出与ID/EX模块的输入
	wire[`AluOpBus] id_aluop_o;
	wire[`AluSelBus] id_alusel_o;
	wire[`RegBus] id_s_op1_o;
	wire[`RegBus] id_s_op2_o;
	wire id_reg_we_o;
	wire[`RegAddrBus] id_reg_waddr_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输入
	wire[`AluOpBus] ex_aluop_i;
	wire[`AluSelBus] ex_alusel_i;
	wire[`RegBus] ex_s_op1_i;
	wire[`RegBus] ex_s_op2_i;
	wire ex_reg_we_i;
	wire[`RegAddrBus] ex_reg_waddr_i;
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输入
	wire ex_reg_we_o;
	wire[`RegAddrBus] ex_reg_waddr_o;
	wire[`RegBus] ex_reg_wdata_o;

	//连接EX/MEM模块的输出与访存阶段MEM模块的输入
	wire mem_reg_we_i;
	wire[`RegAddrBus] mem_reg_waddr_i;
	wire[`RegBus] mem_reg_wdata_i;

	//连接访存阶段MEM模块的输出与MEM/WB模块的输入
	wire mem_reg_we_o;
	wire[`RegAddrBus] mem_reg_waddr_o;
	wire[`RegBus] mem_reg_wdata_o;
	
	//连接MEM/WB模块的输出与回写阶段的输入	
	wire wb_reg_we_i;
	wire[`RegAddrBus] wb_reg_waddr_i;
	wire[`RegBus] wb_reg_wdata_i;
	
	//连接译码阶段ID模块与通用寄存器Regfile模块
	wire reg1_re;
	wire reg2_re;
	wire[`RegBus] reg1_rdata;
	wire[`RegBus] reg2_rdata;
	wire[`RegAddrBus] reg1_raddr;
	wire[`RegAddrBus] reg2_raddr;
	
	wire id_branch_flag_o;
	wire[`RegBus] id_branch_addr_o;
	wire[`RegBus] id_link_addr_o;
	wire[`RegBus] ex_link_addr_i;
  
	//pc_reg例化
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),
		.branch_flag_i(id_branch_flag_o),
		.branch_addr_i(id_branch_addr_o),
		.pc(pc),
		.ce(rom_ce_o)		
	);
	
	assign rom_addr_o = pc;

	//IF/ID模块例化
	if_id if_id0(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);
	
	//译码阶段ID模块
	id id0(
		.rst(rst),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_rdata_i(reg1_rdata),
		.reg2_rdata_i(reg2_rdata),
		
		//处于执行阶段的指令要写入的目的寄存器信息
		.ex_reg_we_i(ex_reg_we_o),
		.ex_reg_wdata_i(ex_reg_wdata_o),
		.ex_reg_waddr_i(ex_reg_waddr_o),
		
		//处于访存阶段的指令要写入的目的寄存器信息
		.mem_reg_we_i(mem_reg_we_o),
		.mem_reg_wdata_i(mem_reg_wdata_o),
		.mem_reg_waddr_i(mem_reg_waddr_o),

		//送到regfile的信息
		.reg1_re_o(reg1_re),
		.reg2_re_o(reg2_re),
		.reg1_raddr_o(reg1_raddr),
		.reg2_raddr_o(reg2_raddr), 
	  
		//送到ID/EX模块的信息
		.aluop_o(id_aluop_o),
		.alusel_o(id_alusel_o),
		.s_op1_o(id_s_op1_o),
		.s_op2_o(id_s_op2_o),
		.reg_waddr_o(id_reg_waddr_o),
		.reg_we_o(id_reg_we_o),
		
		.branch_flag_o(id_branch_flag_o),
		.branch_addr_o(id_branch_addr_o),
		.link_addr_o(id_link_addr_o)
	);

	//通用寄存器REGS例化
	regs regs1(
		.clk(clk),
		.rst(rst),
		.we(wb_reg_we_i),
		.waddr(wb_reg_waddr_i),
		.wdata(wb_reg_wdata_i),
		.re1(reg1_re),
		.raddr1(reg1_raddr),
		.rdata1(reg1_rdata),
		.re2(reg2_re),
		.raddr2(reg2_raddr),
		.rdata2(reg2_rdata)
	);

	//ID/EX模块
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),
		
		//从译码阶段ID模块传递的信息
		.id_aluop(id_aluop_o),
		.id_alusel(id_alusel_o),
		.id_s_op1(id_s_op1_o),
		.id_s_op2(id_s_op2_o),
		.id_reg_waddr(id_reg_waddr_o),
		.id_reg_we(id_reg_we_o),
		.id_link_addr(id_link_addr_o),
	
		//传递到执行阶段EX模块的信息
		.ex_aluop(ex_aluop_i),
		.ex_alusel(ex_alusel_i),
		.ex_s_op1(ex_s_op1_i),
		.ex_s_op2(ex_s_op2_i),
		.ex_reg_waddr(ex_reg_waddr_i),
		.ex_reg_we(ex_reg_we_i),
		.ex_link_addr(ex_link_addr_i)
	);		
	
	//EX模块
	ex ex0(
		.rst(rst),
	
		//送到执行阶段EX模块的信息
		.aluop_i(ex_aluop_i),
		.alusel_i(ex_alusel_i),
		.s_op1_i(ex_s_op1_i),
		.s_op2_i(ex_s_op2_i),
		.reg_waddr_i(ex_reg_waddr_i),
		.reg_we_i(ex_reg_we_i),
		.link_addr_i(ex_link_addr_i),
	  
	  //EX模块的输出到EX/MEM模块信息
		.reg_waddr_o(ex_reg_waddr_o),
		.reg_we_o(ex_reg_we_o),
		.reg_wdata_o(ex_reg_wdata_o)
		
	);

	//EX/MEM模块
	ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),
	  
		//来自执行阶段EX模块的信息	
		.ex_reg_waddr(ex_reg_waddr_o),
		.ex_reg_we(ex_reg_we_o),
		.ex_reg_wdata(ex_reg_wdata_o),
	

		//送到访存阶段MEM模块的信息
		.mem_reg_waddr(mem_reg_waddr_i),
		.mem_reg_we(mem_reg_we_i),
		.mem_reg_wdata(mem_reg_wdata_i)

						       	
	);
	
  //MEM模块例化
	mem mem0(
		.rst(rst),
	
		//来自EX/MEM模块的信息	
		.reg_waddr_i(mem_reg_waddr_i),
		.reg_we_i(mem_reg_we_i),
		.reg_wdata_i(mem_reg_wdata_i),
	  
		//送到MEM/WB模块的信息
		.reg_waddr_o(mem_reg_waddr_o),
		.reg_we_o(mem_reg_we_o),
		.reg_wdata_o(mem_reg_wdata_o)
	);

  //MEM/WB模块
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		//来自访存阶段MEM模块的信息	
		.mem_reg_waddr(mem_reg_waddr_o),
		.mem_reg_we(mem_reg_we_o),
		.mem_reg_wdata(mem_reg_wdata_o),
	
		//送到回写阶段的信息
		.wb_reg_waddr(wb_reg_waddr_i),
		.wb_reg_we(wb_reg_we_i),
		.wb_reg_wdata(wb_reg_wdata_i)
									       	
	);

endmodule