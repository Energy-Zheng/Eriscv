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
`define AluOpBus               7:0   //
`define AluSelBus              2:0
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


// R type inst

// I type inst
`define INST_TYPE_I 7'b0010011  //I类型指令的操作码
`define INST_ORI    3'b110      //ORI指令的功能码

// S type inst

// B type inst

// U type inst

// J type inst

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


