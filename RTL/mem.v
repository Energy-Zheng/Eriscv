/////////////////////////////////
// Module:  mem
// File:    mem.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: mem模块，若是加载存储指令则对数据存储器进行操作，
// 否则将执行阶段取得的运算结果向回写阶段传递
// Revision: 1.0.0
/////////////////////////////////

`include "defines.v"

module mem(

	input wire rst,
	
	//from ex	
	input wire[`RegAddrBus]   reg_waddr_i,
	input wire                reg_we_i,
	input wire[`RegBus]       reg_wdata_i,
	
	input wire[`AluOpBus]     aluop_i,
	input wire[`RegBus]       mem_addr_i,
	input wire[`RegBus]       rt_data_i,
	
	//from DATA RAM
	input wire[`RegBus]       mem_data_i ,
	
	//to wb
	output reg[`RegAddrBus]   reg_waddr_o,
	output reg                reg_we_o,
	output reg[`RegBus]       reg_wdata_o,
	
	//to DATA RAM
	output reg[`RegBus]       mem_addr_o,
	output reg                mem_we_o,
	output reg[3:0]           mem_sel_o,
	output reg[`RegBus]       mem_data_o,
	output reg                mem_ce_o
	
);

	
always @ (*) begin
	if(rst == `RstEnable) begin
		reg_waddr_o <= `NOPRegAddr;
		reg_we_o <= `WriteDisable;
		reg_wdata_o <= `ZeroWord;
		mem_sel_o <= 4'b0000; 
		mem_we_o <= `WriteDisable; 
		mem_addr_o <= `ZeroWord; 
		mem_data_o <= `ZeroWord;
		mem_ce_o <= `ChipDisable;
	end else begin
		reg_waddr_o <= reg_waddr_i;
		reg_we_o <= reg_we_i;
		reg_wdata_o <= reg_wdata_i;  //此处不能将这句注释掉，因为非加载存储指令需要用到
		mem_sel_o <= 4'b1111;       //以下几句可以注释，因为对具体的加载存储指令在之后都有赋值
		mem_we_o <= `WriteDisable; 
		mem_addr_o <= `ZeroWord; 
		mem_data_o <= `ZeroWord;
		mem_ce_o <= `ChipDisable;
		
		case(aluop_i)
			`EXE_LB_OP: begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteDisable;
				mem_ce_o <= `ChipEnable;
				case (mem_addr_i[1:0])
					2'b00   : reg_wdata_o <= {{24{mem_data_i[7]}}, mem_data_i[7:0]};
					2'b01   : reg_wdata_o <= {{24{mem_data_i[15]}}, mem_data_i[15:8]};
					2'b10   : reg_wdata_o <= {{24{mem_data_i[23]}}, mem_data_i[23:16]};
					2'b11   : reg_wdata_o <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};
					default : reg_wdata_o <= 0;
				endcase 
			end
			
			`EXE_LH_OP : begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteDisable;
				mem_ce_o <= `ChipEnable;
				case (mem_addr_i[1:0])
					2'b00   : reg_wdata_o <= {{16{mem_data_i[15]}}, mem_data_i[15:0]};
					2'b10   : reg_wdata_o <= {{16{mem_data_i[15]}}, mem_data_i[31:16]};
					default : reg_wdata_o <= 0;
				endcase 
			end
			
			`EXE_LW_OP : begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteDisable;
				mem_ce_o <= `ChipEnable;
				case (mem_addr_i[1:0])
					2'b00   : reg_wdata_o <= mem_data_i;
					default : reg_wdata_o <= 0;
				endcase 
			end
			
			`EXE_LBU_OP : begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteDisable;
				mem_ce_o <= `ChipEnable;
				case (mem_addr_i[1:0])
					2'b00   : reg_wdata_o <= {{24{1'b0}}, mem_data_i[7:0]};
					2'b01   : reg_wdata_o <= {{24{1'b0}}, mem_data_i[15:8]};
					2'b10   : reg_wdata_o <= {{24{1'b0}}, mem_data_i[23:16]};
					2'b11   : reg_wdata_o <= {{24{1'b0}}, mem_data_i[31:24]};
					default : reg_wdata_o <= 0;
				endcase 
			end
			
			`EXE_LHU_OP : begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteDisable;
				mem_ce_o <= `ChipEnable;
				case (mem_addr_i[1:0])
					2'b00   : reg_wdata_o <= {{16{1'b0}}, mem_data_i[15:0]};
					2'b10   : reg_wdata_o <= {{16{1'b0}}, mem_data_i[31:16]};
					default : reg_wdata_o <= 0;
				endcase 
			end
			
			`EXE_SB_OP : begin
				//reg_wdata_o <= 0;
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteEnable;
				mem_ce_o <= `ChipEnable;
				mem_data_o = {4{rt_data_i[7:0]}};
				case (mem_addr_i[1:0])
					2'b00   : mem_sel_o <= 4'b0001;
					2'b01   : mem_sel_o <= 4'b0010;
					2'b10   : mem_sel_o <= 4'b0100;
					2'b11   : mem_sel_o <= 4'b1000;
					default : mem_sel_o <= 4'b0000;
				endcase 
			end
			
			`EXE_SH_OP : begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteEnable;
				mem_ce_o <= `ChipEnable;
				mem_data_o <= {2{rt_data_i[15:0]}};
				case (mem_addr_i[1:0])
					2'b00   : mem_sel_o <= 4'b0011;
					2'b10   : mem_sel_o <= 4'b1100;
					default : mem_sel_o <= 4'b0000;
				endcase 
			end
			
			`EXE_SW_OP : begin
				mem_addr_o <= mem_addr_i;
				mem_we_o <= `WriteEnable;
				mem_ce_o <= `ChipEnable;
				mem_data_o <= rt_data_i;
				case (mem_addr_i[1:0])
					2'b00   : mem_sel_o <= 4'b1111;
					default : mem_sel_o <= 4'b0000;
				endcase 
			end
			
			default : begin
				//do nothing
			end
		endcase		
	end  
end  //always
			

endmodule