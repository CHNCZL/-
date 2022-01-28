module mmu (
    input wire  [31:0] inst_vaddr,  //指令地址pc
    output wire [31:0] inst_paddr,  //true_pc
    input wire  [31:0] data_vaddr,  //数据地址
    output wire [31:0] data_paddr,  //true数据地址

    output wire no_dcache    //鏄惁缁忚繃d cache
);
    wire inst_kseg0, inst_kseg1;
    wire data_kseg0, data_kseg1;

    assign inst_kseg0 = inst_vaddr[31:29] == 3'b100;
    assign inst_kseg1 = inst_vaddr[31:29] == 3'b101;
    assign data_kseg0 = data_vaddr[31:29] == 3'b100;
    assign data_kseg1 = data_vaddr[31:29] == 3'b101;

    assign inst_paddr = inst_kseg0 | inst_kseg1 ?
           {3'b0, inst_vaddr[28:0]} : inst_vaddr;
    assign data_paddr = data_kseg0 | data_kseg1 ?
           {3'b0, data_vaddr[28:0]} : data_vaddr;
    
    assign no_dcache = data_kseg1 ? 1'b1 : 1'b0;

endmodule