
module  commit(
    //input commit信息
    input wire [160:0] regW_i_commit_info,
    //input load & store信息
    input wire [63:0]  regW_i_regdata2,
    input wire [63:0]  regW_i_mem_rdata,
    input wire [63:0]  regW_i_alu_result,
    output wire [63:0]  commit_o_mem_rdata,
    output wire [63:0]  commit_o_mem_wdata,
    output wire [63:0]  commit_o_mem_addr,
    //output commit信息
    output wire         commit_o_commit,
    output wire [31:0]  commit_o_instr,
    output wire [63:0]  commit_o_pc,
    output wire [63:0]  commit_o_next_pc
);
    //load&store
    assign commit_o_mem_addr  = regW_i_alu_result;
    assign commit_o_mem_wdata = regW_i_regdata2;
    assign commit_o_mem_rdata = regW_i_mem_rdata;
    //instr
    assign commit_o_commit    =  regW_i_commit_info[160]; //regW_i_valid
    assign commit_o_instr     =  regW_i_commit_info[159:128];
    assign commit_o_next_pc   =  regW_i_commit_info[127:64];
    assign commit_o_pc        =  regW_i_commit_info[63:0];


endmodule 

