module new_pc (
    input  wire         clk,
    input  wire         rst,
    input  wire         regF_stall,
    input  wire         regF_bubble,    
    input  wire         execute_i_branch_need_jump,
    input  wire [63:0]  execute_i_branch_next_pc,
    input  wire         execute_i_mret_need_jump,
    input  wire [63:0]  execute_i_mret_next_pc,

    input  wire [63:0]  fetch_i_next_pc,    // 预测的顺序下一跳 PC
    input  wire         fetch_i_ready_go,   // Fetch 模块是否处理完当前指令

    input  wire         regD_i_allowin,     // 下一级 (Decode 寄存器) 是否允许输入

    output wire         pc_o_allowin,       // 允许 PC 更新
    output wire         pc_o_valid,         // PC 输出有效信号
    output reg  [63:0]  pc                  // 特殊命名：pc
);

    reg         pc_valid;

    wire pc_ready_go =    !regF_stall && fetch_i_ready_go;
    assign pc_o_allowin = !pc_valid || (pc_ready_go && regD_i_allowin);
    assign pc_o_valid   =  pc_valid;

    always @(posedge clk) begin
        if (rst) begin
            pc_valid <= 1'b0;
            pc       <= 64'h80000000;
        end 
        else if (pc_o_allowin) begin
            pc_valid <= 1'b1;
            if (pc_valid) begin
                pc <=  execute_i_mret_need_jump   ? execute_i_mret_next_pc   :
                       execute_i_branch_need_jump ? execute_i_branch_next_pc : fetch_i_next_pc;
            end
        end
    end

endmodule