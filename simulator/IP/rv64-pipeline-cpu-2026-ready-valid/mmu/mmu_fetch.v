module new_fetch(
    // ============================================================
    // INPUTS (Prefix _i_, except 'pc')
    // ============================================================
    input  wire         clk,
    input  wire         rst,
    
    // 来自 PC 模块的信号
    input  wire [63:0]  pc,                 // 只有原始 pc 是特殊的
    input  wire         pc_i_valid,         
    
    // 来自 CSR 模块的信号
    input  wire [63:0]  decode_i_csr_satp,
    
    output wire         fetch_o_ready_go,   
    output wire [63:0]  fetch_o_pc,         // 恢复规范：fetch_o_pc
    output wire [31:0]  fetch_o_instr,
    output wire [63:0]  fetch_o_next_pc,    // 恢复规范：fetch_o_next_pc
    output wire [160:0] fetch_o_commit_info
);

    // DPI-C 函数导入
    import "DPI-C" function int dpi_instr_mem_read (input longint addr);

    // --- 1. MMU 实例化 ---
    wire        mmu_o_ready;
    wire [63:0] mmu_o_pa;
    wire        mmu_o_valid;

    mmu u_mmu(
        .clk            ( clk               ),
        .rst            ( rst               ),
        .va             ( pc                ), 
        .va_i_valid     ( pc_i_valid        ), 
        .satp           ( decode_i_csr_satp ),
        .mmu_o_ready    ( mmu_o_ready       ),
        .mmu_o_pa       ( mmu_o_pa          ),
        .mmu_o_valid    ( mmu_o_valid       )
    );

    // --- 2. 握手逻辑 ---
    assign fetch_o_ready_go = pc_i_valid && mmu_o_valid && mmu_o_ready;

    // --- 3. 指令读取 ---
    wire [31:0] instr = (fetch_o_ready_go) ? dpi_instr_mem_read(mmu_o_pa) : 32'h00000013;

    // --- 4. 输出信号赋值 ---
    assign fetch_o_pc          = pc;            
    assign fetch_o_instr       = instr;
    assign fetch_o_next_pc     = pc + 64'd4;    
    
    // commit_info 拼接
    assign fetch_o_commit_info = {1'b1, fetch_o_instr, fetch_o_next_pc, fetch_o_pc};

endmodule