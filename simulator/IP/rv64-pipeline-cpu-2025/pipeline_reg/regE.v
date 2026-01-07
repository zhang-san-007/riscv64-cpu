`include "define.v"
module regE(
    input wire         clk,                    // 时钟信号
    input wire         rst,                    // 复位信号
    input wire         regE_bubble,            // Bubble 信号
    input wire         regE_stall,             // Stall 信号
//---------input-----------------
    //data
    input wire  [63:0] decode_i_imm,           // 立即数
    input wire  [63:0] decode_i_regdata1,      // 寄存器数据1
    input wire  [63:0] decode_i_regdata2,      // 寄存器数据2
    input wire  [63:0] regD_i_pc,              // 当前指令的PC
    input wire  [63:0] decode_i_csr_rdata,

    //info
    input wire   [27:0] decode_i_alu_info,          // ALU操作信息
    input wire   [10:0] decode_i_load_store_info,   // 访存操作信息
    input wire   [12:0] decode_i_opcode_info,       // 操作码信息
    input wire   [5:0]  decode_i_branch_info,       // 分支信息
    input wire   [5:0]  decode_i_csrrw_info,
    input wire   [6:0]  decode_i_system_info,

    //reg
    input wire  [4:0]   decode_i_reg_rd,            
    input wire          decode_i_reg_wen,       
    //csr
    input wire   [11:0] decode_i_csr_id,
    input wire          decode_i_csr_wen,
    //commit
    input wire  [160:0] regD_i_commit_info,

//-------------------output-------------------------------
    //data
    output reg  [63:0]  regE_o_regdata1,        
    output reg  [63:0]  regE_o_regdata2,        
    output reg  [63:0]  regE_o_imm,             
    output reg  [63:0]  regE_o_pc,              
    output reg  [63:0]  regE_o_csr_rdata,

    //info
    output reg  [27:0]  regE_o_alu_info,        
    output reg  [10:0]  regE_o_load_store_info, 
    output reg  [12:0]  regE_o_opcode_info,     
    output reg  [5:0]   regE_o_branch_info,     
    output reg  [5:0]   regE_o_csrrw_info,
    output reg  [6:0]   regE_o_system_info,

    //csr
    output reg  [11:0]  regE_o_csr_id,
    output reg          regE_o_csr_wen,
    //reg
    output reg  [4:0]   regE_o_reg_rd,              
    output reg          regE_o_reg_wen,         
    //commit
    output reg  [160:0] regE_o_commit_info
);

// 时序逻辑：控制寄存器的更新，使用时钟信号 clk
always @(posedge clk or posedge rst) begin
    if (rst || regE_bubble) begin
        //data
        regE_o_regdata1         <= `nop_regdata1;
        regE_o_regdata2         <= `nop_regdata2;
        regE_o_pc               <= `nop_pc;
        regE_o_imm              <= `nop_imm;
        regE_o_csr_rdata        <= `nop_csr_rdata;
        //info
        regE_o_alu_info         <= `nop_alu_info;
        regE_o_load_store_info  <= `nop_load_store_info;
        regE_o_opcode_info      <= `nop_opcode_info;
        regE_o_branch_info      <= `nop_branch_info;
        regE_o_csrrw_info       <= `nop_csrrw_info;
        regE_o_system_info      <= `nop_system_info;
        //csr
        regE_o_csr_id           <= `nop_csr_id;
        regE_o_csr_wen          <= `nop_csr_wen;
        //reg
        regE_o_reg_rd           <= `nop_reg_rd;
        regE_o_reg_wen          <= `nop_reg_wen;
        //commit
        regE_o_commit_info      <= `nop_commit_info;
    end
    else if (!regE_stall) begin
        regE_o_regdata1         <= decode_i_regdata1;
        regE_o_regdata2         <= decode_i_regdata2;
        regE_o_pc               <= regD_i_pc;
        regE_o_imm              <= decode_i_imm;
        regE_o_csr_rdata        <= decode_i_csr_rdata;
        //info
        regE_o_alu_info         <= decode_i_alu_info;
        regE_o_load_store_info  <= decode_i_load_store_info;
        regE_o_opcode_info      <= decode_i_opcode_info;
        regE_o_branch_info      <= decode_i_branch_info;
        regE_o_csrrw_info       <= decode_i_csrrw_info;
        regE_o_system_info      <= decode_i_system_info;
        //csr
        regE_o_csr_id           <= decode_i_csr_id;
        regE_o_csr_wen          <= decode_i_csr_wen;
        //reg
        regE_o_reg_rd           <= decode_i_reg_rd;
        regE_o_reg_wen          <= decode_i_reg_wen;
        //commit
        regE_o_commit_info      <= regD_i_commit_info;
    end
end

endmodule
