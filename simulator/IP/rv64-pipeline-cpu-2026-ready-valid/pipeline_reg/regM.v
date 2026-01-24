`include "define.v"
module regM(    
    input  wire         clk,
    input  wire         rst,
    input  wire [10:0]  regE_i_load_store_info,
    input  wire [13:0]  regE_i_opcode_info,
    input  wire [5:0]   regE_i_csrrw_info,
    input  wire [6:0]   regE_i_system_info,
    input  wire [19:0]  regE_i_amo_info,
    input  wire [63:0]  execute_i_alu_result,
    input  wire [63:0]  regE_i_pc,          
    input  wire [63:0]  regE_i_csr_rdata1,
    input  wire [63:0]  regE_i_regdata1,
    input  wire [63:0]  regE_i_regdata2,
    input  wire [11:0]  regE_i_csr_wid,
    input  wire         regE_i_csr_wen,
    input  wire [4:0]   regE_i_reg_rd,
    input  wire         regE_i_reg_wen,
    input  wire [160:0] execute_i_commit_info,
    input  wire         regE_o_valid,
    output wire         regM_o_allowin,    // 已修改为输出信号
    output wire         regM_o_valid,
    input  wire         regW_allowin,
    output reg  [10:0]  regM_o_load_store_info,
    output reg  [13:0]  regM_o_opcode_info,
    output reg  [5:0]   regM_o_csrrw_info,
    output reg  [6:0]   regM_o_system_info,   
    output reg  [19:0]  regM_o_amo_info,
    output reg  [63:0]  regM_o_alu_result,
    output reg  [63:0]  regM_o_pc,         
    output reg  [63:0]  regM_o_csr_rdata1,
    output reg  [63:0]  regM_o_regdata1,
    output reg  [63:0]  regM_o_regdata2,
    output reg  [11:0]  regM_o_csr_wid,
    output reg          regM_o_csr_wen,
    output reg  [4:0]   regM_o_reg_rd,
    output reg          regM_o_reg_wen,
    output reg  [160:0] regM_o_commit_info
);

    reg         regM_valid;
    wire        regM_ready_go;

//让别人进只有两种情况
//  第一种是我自身无效
//  第二种是我准备好了，然后后一级别和我说你来吧。


    assign regM_ready_go  = 1'b1;
    assign regM_o_allowin = !regM_valid || (regM_ready_go && regW_allowin);
    assign regM_o_valid   =  regM_valid && regM_ready_go;


    always @(posedge clk) begin
        if (rst) begin
            regM_valid <= 1'b0;
        end else if (regM_o_allowin) begin
            regM_valid <= regE_o_valid;
        end
        //只要上级
        if (regE_o_valid && regM_o_allowin) begin
            regM_o_load_store_info  <= regE_i_load_store_info;
            regM_o_opcode_info      <= regE_i_opcode_info;
            regM_o_csrrw_info       <= regE_i_csrrw_info;
            regM_o_system_info      <= regE_i_system_info;
            regM_o_amo_info         <= regE_i_amo_info;
            regM_o_regdata2         <= regE_i_regdata2;
            regM_o_regdata1         <= regE_i_regdata1;
            regM_o_alu_result       <= execute_i_alu_result;
            regM_o_pc               <= regE_i_pc;
            regM_o_csr_rdata1       <= regE_i_csr_rdata1;
            regM_o_reg_rd           <= regE_i_reg_rd;
            regM_o_reg_wen          <= regE_i_reg_wen;
            regM_o_csr_wid          <= regE_i_csr_wid;
            regM_o_csr_wen          <= regE_i_csr_wen;
            regM_o_commit_info      <= execute_i_commit_info;
        end
    end

endmodule




// 阶段:          [ IF ]               [ ID ]               [ EXE ]              [ MEM ]
// 寄存器:         regF                 regD                 regE                 regM
//              +---------+          +---------+          +---------+          +---------+
// 指令内容:     |    A    |          |    B    |          |   JAL   |          |    D    |
//              +---------+          +---------+          +---------+          +---------+
// 内部Valid位:  |    1    |          |    1    |          |    1    |          |    1    |
//              +---------+          +---------+          +---------+          +---------+
//                   |                    |                    |                    |
// [发出的Valid]  o_valid=1 ----------> i_valid=1 ----------> i_valid=1 ----------> o_valid=1
//                   |                    |                    |                    |
// [接收的Allow]  i_allow=1 <---------  o_allow=1 <---------  o_allow=1 <--------- i_allow=1
//                   ^                    ^                    ^                    |
//                   |                    |                    |                    |
//                   |             [ 握手控制中心 ]         [ 跳转发生 ]              |
//                   |                    |                    |                    |
//                   |                    | <---jump_taken=1---|                    |
//                   |                    |                    |                    |
//                   V                    V                    V                    V
// [下一拍动作]   更新PC为             写入valid=0           JAL进入regM          正常流动
