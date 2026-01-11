`include "define.v"
module regM(    
    input wire        clk,                    // 时钟信号
    input wire        rst,                    // 复位信号
    //
    input wire        regM_bubble,            // 气泡信号，用于清空当前阶段
    input wire        regM_stall,             // 停滞信号，用于暂停当前阶段的更新

//----------input---------------------------
    input wire  [10:0]  regE_i_load_store_info,
    input wire  [12:0]  regE_i_opcode_info,
    input wire   [5:0]  regE_i_csrrw_info,
    input wire   [6:0]  regE_i_system_info,
    //data
    input wire  [63:0]  execute_i_alu_result,
    input wire  [63:0]  regE_i_pc,         
    input wire  [63:0]  regE_i_csr_rdata1,
    input wire  [63:0]  regE_i_regdata2,
    //csr
    input wire  [11:0]  regE_i_csr_wid,
    input wire          regE_i_csr_wen,
    //reg
    input wire  [4:0]   regE_i_reg_rd,
    input wire          regE_i_reg_wen,

    //commit
    input wire  [160:0] execute_i_commit_info,

//-----------output-------------------------
    //info
    output reg   [10:0] regM_o_load_store_info,
    output reg   [12:0] regM_o_opcode_info,
    output reg   [5:0]  regM_o_csrrw_info,
    output reg   [6:0]  regM_o_system_info,   
    //data
    output reg   [63:0] regM_o_alu_result,
    output reg   [63:0] regM_o_pc,        
    output reg  [63:0]  regM_o_csr_rdata1,
    output reg   [63:0] regM_o_regdata2,

    //csr
    output reg  [11:0]  regM_o_csr_wid,
    output reg          regM_o_csr_wen,

    //reg
    output reg  [4:0]   regM_o_reg_rd,
    output reg          regM_o_reg_wen,
    //commit
    output reg  [160:0] regM_o_commit_info
);

    always @(posedge clk) begin
        if (rst || regM_bubble) begin
            //info
            regM_o_load_store_info  <= `nop_load_store_info;
            regM_o_opcode_info      <= `nop_opcode_info;
            regM_o_csrrw_info       <= `nop_csrrw_info;
            regM_o_system_info      <= `nop_system_info;

            //data
            regM_o_regdata2         <= `nop_regdata2;
            regM_o_alu_result       <= `nop_alu_result;
            regM_o_pc               <= `nop_pc;  // 清零程序计数器
            regM_o_csr_rdata1        <= `nop_csr_rdata1;

            //reg
            regM_o_reg_rd           <= `nop_reg_rd;
            regM_o_reg_wen          <= `nop_reg_wen;
            //csr
            regM_o_csr_wid           <= `nop_csr_wid;
            regM_o_csr_wen          <= `nop_csr_wen;
            //commit
            regM_o_commit_info      <= `nop_commit_info;
        end else if (regM_stall) begin
            // 在停滞信号时，保持当前值不变
            // Verilog中未赋值的reg类型会保持原值，因此这里不需要显式赋值
        end else begin
            // 正常情况下，将输入信号传递到输出信号
            regM_o_load_store_info  <= regE_i_load_store_info;
            regM_o_opcode_info      <= regE_i_opcode_info;
            regM_o_csrrw_info       <= regE_i_csrrw_info;
            regM_o_system_info      <= regE_i_system_info;

            //data
            regM_o_regdata2         <= regE_i_regdata2;
            regM_o_alu_result       <= execute_i_alu_result;
            regM_o_pc               <= regE_i_pc;
            regM_o_csr_rdata1        <= regE_i_csr_rdata1;

            //reg
            regM_o_reg_rd           <= regE_i_reg_rd;
            regM_o_reg_wen          <= regE_i_reg_wen;
            //csr
            regM_o_csr_wid           <= regE_i_csr_wid;
            regM_o_csr_wen          <= regE_i_csr_wen;
            //commit
            regM_o_commit_info      <= execute_i_commit_info;

        end
    end

endmodule