`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips(
	input wire clk,resetn,
	input wire[5:0] int,
	//ָ��cache
	output wire inst_sram_en,          //Isramʹ���ź�
	output wire[3:0] inst_sram_wen,    //Isramдʹ���ź�
	output wire[31:0] inst_sram_addr,inst_sram_wdata, //д���ַ����ʱΪPcF��������
	input wire[31:0] inst_sram_rdata,  //�������ݣ�ָ�
	//����cache
	output wire data_sram_en,          //Dsramʹ���ź�
	output wire[3:0] data_sram_wen,    //Dsramдʹ���ź�
	output wire[31:0] data_sram_addr,data_sram_wdata,
	input wire[31:0] data_sram_rdata,
	//debug
	output wire[31:0] debug_wb_pc,
	output wire[3:0] debug_wb_rf_wen,
	output wire[4:0] debug_wb_rf_wnum,
	output wire[31:0] debug_wb_rf_wdata
    );
	
	wire [5:0] opD,functD;
	wire [4:0] rtD;
	wire [1:0] regdstE;
	wire alusrcE,pcsrcD;
	wire[1:0] memtoregE, memtoregM, memtoregW;
	wire regwriteE, regwriteM, regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,stallE,equalD;
	wire linkE;
	
    wire hilowriteM, memwriteM;
    wire[1:0] memwrite_conM;
	wire[2:0] memread_conM;
	wire[31:0] writedataM;
    wire[31:0] pcF, aluoutM;     //aluout��Ϊ��ǰ���ʵ�ַ����
    
    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;
    assign data_sram_en = memwriteM | memtoregM;    //Ϊʲô��
    assign debug_wb_rf_wen = {4{regwriteW}};
    
    mmu addr_trans(pcF, inst_sram_addr, aluoutM, data_sram_addr);
    
	controller c(
		clk,resetn,
		//decode stage
		opD,functD,
		rtD,
		pcsrcD,branchD,equalD,jumpD,jrD,linkD,
		sign_extD,
		
		//execute stage
		flushE,stallE,
		memtoregE,regdstE,
		alusrcE,regwriteE,	
		alucontrolE,
        linkE,
		//mem stage
		memtoregM,
		memwriteM, regwriteM, hilowriteM,
		memwrite_conM,
		memread_conM,
		
		//write back stage
		memtoregW,regwriteW
		);
		
	memwrite_mux memWmux(memwriteM,memwrite_conM,aluoutM, data_sram_wen);  //ѡ��������дʹ���ź�
	writeData_mux WDatamux(writedataM, memwrite_conM, data_sram_wdata);    //ѡ������Ҫд��cache����
	
	datapath dp(
		clk,resetn,
		//fetch stage
		pcF,
		inst_sram_rdata,  //InstrF
		//decode stage
		sign_extD,
		pcsrcD,branchD,
		jumpD,jrD,linkD,
		equalD,
		opD,functD,
		rtD,
		//execute stage
		memtoregE,regdstE,
		alusrcE,
		regwriteE,
		alucontrolE,
		linkE,
		flushE,stallE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,writedataM,
		data_sram_rdata,  //�൱��readdataM
		hilowriteM,
		memread_conM,
		//writeback stage
		memtoregW,
		regwriteW,
		//sram test
		debug_wb_pc,      //pcW
		debug_wb_rf_wnum, //writeregW
		debug_wb_rf_wdata //resultW
	    );
	
endmodule
