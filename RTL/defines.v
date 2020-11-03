//////////////////////////////////////////////////////////////////////
// Module:  
// File:    defines.v
// Author:  Energy_Zheng
// E-mail:  zheng_wanbin@qq.com
// Description: 宏定义
// Revision: 1.0.0
//////////////////////////////////////////////////////////////////////

//--------
//全局变量
//--------
`define RstEnable              1'b1  //复位信号有效
`define RstDisable             1'b0  //复位信号有效
`define ZeroWord               32'h00000000  //32位的数值0
`define WriteEnable            1'b1  //使能写
`define WriteDisable           1'b0  //禁止写
`define ReadEnable             1'b1  //使能读
`define ReadDisable            1'b0  //禁止读
`define AluOpBus               7:0   //译码阶段的输出aluop_o的宽度
`define AluSelBus              2:0   //译码阶段的输出alusel_o的宽度
`define InstValid              1'b0  //指令有效
`define InstInvalid            1'b1  //指令无效
`define Stop                   1'b1  
`define NoStop                 1'b0
`define InDelaySlot            1'b1
`define NotInDelaySlot         1'b0
`define Branch                 1'b1
`define NotBranch              1'b0
`define InterruptAssert        1'b1
`define InterruptNotAssert     1'b0
`define TrapAssert             1'b1
`define TrapNotAssert          1'b0
`define True                   1'b1  //逻辑“真”
`define False                  1'b0  //逻辑“假”
`define ChipEnable             1'b1  //芯片使能
`define ChipDisable            1'b0  //芯片禁止

//-------------------
//RV32I基本整数指令集
//-------------------

//- opcode of Instruction

//-- R type inst
`define OP_ARITH       7'b0110011

//-- I type inst
`define OP_JALR        7'b1100111
`define OP_LOAD        7'b0000011
`define OP_ARITH_IMM   7'b0010011
`define OP_FENCE       7'b0001111
`define OP_CSR         7'b1110011

//-- S type inst
`define OP_STORE       7'b0100011

//-- B type inst
`define OP_BRANCH      7'b1100011

//-- U type inst
`define OP_LUI         7'b0110111
`define OP_AUIPC       7'b0010111

//-- J type inst
`define OP_JAL         7'b1101111

//- funct3 of Instruction

//-- JALR
`define FUNCT3_JALR    3'b000
//-- Branch
`define FUNCT3_BEQ     3'b000
`define FUNCT3_BNE     3'b001
`define FUNCT3_BLT     3'b100
`define FUNCT3_BGE     3'b101
`define FUNCT3_BLTU    3'b110
`define FUNCT3_BGEU    3'b111
//-- LOAD
`define FUNCT3_LB      3'b000
`define FUNCT3_LH      3'b001
`define FUNCT3_LW      3'b010
`define FUNCT3_LBU     3'b100
`define FUNCT3_LHU     3'b101
//-- STORE
`define FUNCT3_SB      3'b000
`define FUNCT3_SH      3'b001
`define FUNCT3_SW      3'b010
//-- ARITH_IMM
`define FUNCT3_ADDI    3'b000
`define FUNCT3_SLTI    3'b010
`define FUNCT3_SLTIU   3'b011
`define FUNCT3_XORI    3'b100
`define FUNCT3_ORI     3'b110
`define FUNCT3_ANDI    3'b111
`define FUNCT3_SLLI    3'b001
`define FUNCT3_SRLI_SRAI 3'b101
//-- ARITH
`define FUNCT3_ADD_SUB 3'b000
`define FUNCT3_SLL     3'b001
`define FUNCT3_SLT     3'b010
`define FUNCT3_SLTU    3'b011
`define FUNCT3_XOR     3'b100
`define FUNCT3_SRL_SRA 3'b101
`define FUNCT3_OR      3'b110
`define FUNCT3_AND     3'b111
//-- FENCE
`define FUNCT3_FENCE   3'b000
`define FUNCT3_FENCEI  3'b001
//-- CSR
`define FUNCT3_ECALL_EBREAK  3'b000
`define FUNCT3_CSRRW   3'b001
`define FUNCT3_CSRRS   3'b010
`define FUNCT3_CSRRC   3'b011
`define FUNCT3_CSRRWI  3'b101
`define FUNCT3_CSSRRSI 3'b110
`define FUNCT3_CSRRCI  3'b111

//- funct7 of Instruction
//-- SLLI
`define FUNCT7_SLLI 7'b0000000
//-- SRLI_SRAI
`define FUNCT7_SRLI 7'b0000000
`define FUNCT7_SRAI 7'b0100000
//-- ADD_SUB
`define FUNCT7_ADD  7'b0000000
`define FUNCT7_SUB  7'b0100000
`define FUNCT7_SLL  7'b0000000
`define FUNCT7_SLT  7'b0000000
`define FUNCT7_SLTU 7'b0000000
`define FUNCT7_XOR  7'b0000000
//-- SRL_SRA
`define FUNCT7_SRL 7'b0000000
`define FUNCT7_SRA 7'b0100000
`define FUNCT7_OR  7'b0000000
`define FUNCT7_AND 7'b0000000

//-------------------
//AluSel——运算类型定义
//-------------------
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_NOP         3'b000
`define EXE_RES_ARITH       3'b100
`define EXE_RES_MUL         3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE  3'b111

//-------------------
//AluOp——运算子类型定义
//-------------------
`define EXE_NOP_OP          0

`define EXE_AND_OP          1
`define EXE_OR_OP           2
`define EXE_XOR_OP          3

`define EXE_SLL_OP          4
`define EXE_SRL_OP          5
`define EXE_SRA_OP          6

`define EXE_ADD_OP          7
`define EXE_SUB_OP          8
`define EXE_SLT_OP          9
`define EXE_SLTU_OP         10

`define EXE_JAL_OP          11
`define EXE_JALR_OP         12
`define EXE_BEQ_OP          13
`define EXE_BNE_OP          14
`define EXE_BLT_OP          15
`define EXE_BGE_OP          16
`define EXE_BLTU_OP         17
`define EXE_BGEU_OP         18

`define EXE_LB_OP           19
`define EXE_LH_OP           20
`define EXE_LW_OP           21
`define EXE_LBU_OP          22
`define EXE_LHU_OP          23
`define EXE_SB_OP           24
`define EXE_SH_OP           25
`define EXE_SW_OP           26


//------------------
//指令存储器inst_rom
//------------------
`define InstAddrBus     31:0    //ROM的地址总线宽度
`define InstBus         31:0    //ROM的数据总线宽度
`define InstMemNum      131071  //ROM的实际大小为128KB
`define InstMemNumLog2  17      //ROM实际使用的地址线宽度

//-----------------
//通用寄存器regfile
//-----------------
`define RegAddrBus      4:0    //regfile模块的地址线宽度
`define RegBus          31:0   //regfile模块的数据线宽度
`define RegWidth        32     //通用寄存器位宽
`define DoubleRegWidth  64     //两倍的通用寄存器位宽
`define DoubleRegBus    63:0   //两倍的通用寄存器数据线宽度
`define RegNum          32     //通用寄存器的数量
`define RegNumLog2      5      //寻址通用寄存器使用的地址位数
`define NOPRegAddr      5'b00000


