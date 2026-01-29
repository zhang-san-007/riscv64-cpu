/* verilator lint_off WIDTHTRUNC */

module mmu(
    input  wire        clk,           
    input  wire        rst,             
    input  wire [63:0] va,              // 虚拟地址
    input  wire        va_i_valid,      // 请求有效信号
    input  wire [63:0] satp,            // SATP 寄存器

    output reg         mmu_o_ready,     // MMU 准备好接收新请求
    output reg  [63:0] mmu_o_pa,        // 翻译后的物理地址
    output reg         mmu_o_valid      // 输出有效
);

    // --- 状态机定义 ---
    localparam STATE_IDLE      = 3'd0;
    localparam STATE_FETCH_PTE = 3'd1; // 发起内存读取
    localparam STATE_CHECK_PTE = 3'd2; // 检查条目并决定下一步
    localparam STATE_DONE      = 3'd3;

    reg [2:0]  current_state;
    reg [1:0]  level;          // 记录当前遍历层级 (2 -> 1 -> 0)
    reg [63:0] current_pte;
    reg [63:0] v_addr_reg;     // 锁存输入的 va

    // DPI 函数声明
    import "DPI-C" function longint dpi_mem_read (input longint addr, input int len, input longint pc);

    // --- 辅助信号解析 ---
    wire [43:0] satp_ppn       = satp[43:0];
    wire [3:0]  satp_mode      = satp[63:60];
    wire        translation_en = (satp_mode == 4'd8); 

    // 根据当前层级获取对应的 VPN 段 (Sv39: 9 bits per level)
    wire [8:0] vpn_at_level = (level == 2'd2) ? v_addr_reg[38:30] :
                              (level == 2'd1) ? v_addr_reg[29:21] : 
                                                v_addr_reg[20:12];

    // PTE 属性解析 (RISC-V Sv39 标准)
    wire pte_v   = current_pte[0];
    wire pte_r   = current_pte[1];
    wire pte_w   = current_pte[2];
    wire pte_x   = current_pte[3];
    wire is_leaf = (pte_r | pte_w | pte_x);

    // --- 严谨的地址计算逻辑 (修复 67-bit 警告) ---
    wire [63:0] base_addr;
    wire [63:0] offset;
    wire [63:0] next_pte_addr_raw;
    wire [63:0] next_pte_addr;

    // 分离基地址与偏移量计算，强制 64 位宽
    assign base_addr = (current_state == STATE_IDLE) ? 
                       {8'b0, satp_ppn, 12'b0} : 
                       {8'b0, current_pte[53:10], 12'b0};

    assign offset    = (current_state == STATE_IDLE) ? 
                       {53'b0, va[38:30], 3'b0} : 
                       {53'b0, vpn_at_level, 3'b0};

    assign next_pte_addr_raw = base_addr + offset;
    assign next_pte_addr     = next_pte_addr_raw[63:0]; // 显式截断确保 64 位

    // --- 状态转移逻辑 ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= STATE_IDLE;
            mmu_o_ready   <= 1'b1;
            mmu_o_valid   <= 1'b0;
            mmu_o_pa      <= 64'b0;
            level         <= 2'd2;
            current_pte   <= 64'b0;
            v_addr_reg    <= 64'b0;
        end else begin
            case (current_state)
                STATE_IDLE: begin
                    mmu_o_valid <= 1'b0;
                    if (va_i_valid && mmu_o_ready) begin
                        v_addr_reg <= va;
                        if (!translation_en) begin
                            mmu_o_pa    <= va; // Bare 模式直接透传
                            mmu_o_valid <= 1'b1;
                        end else begin
                            mmu_o_ready <= 1'b0;
                            level       <= 2'd2;
                            // 第一次读取：从 SATP 根页表开始
                            current_pte   <= dpi_mem_read(next_pte_addr, 8, 0);
                            current_state <= STATE_CHECK_PTE;
                        end
                    end
                end

                STATE_FETCH_PTE: begin
                    // 读取下一级页表项
                    current_pte   <= dpi_mem_read(next_pte_addr, 8, 0);
                    current_state <= STATE_CHECK_PTE;
                end

                STATE_CHECK_PTE: begin
                    if (!pte_v || (!pte_r && pte_w)) begin
                        // 异常处理：无效位或 R=0,W=1 的非法组合
                        mmu_o_pa      <= 64'hFFFF_FFFF_FFFF_FFFF; 
                        current_state <= STATE_DONE;
                    end else if (is_leaf) begin
                        // 发现叶节点，根据当前 Level 拼接物理地址 (支持大页)
                        case (level)
                            2'd2: mmu_o_pa <= {8'b0, current_pte[53:28], v_addr_reg[29:0]}; // 1G page
                            2'd1: mmu_o_pa <= {8'b0, current_pte[53:19], v_addr_reg[20:0]}; // 2M page
                            2'd0: mmu_o_pa <= {8'b0, current_pte[53:10], v_addr_reg[11:0]}; // 4K page
                            default: mmu_o_pa <= 64'hFFFF_FFFF_FFFF_FFFF;
                        endcase
                        current_state <= STATE_DONE;
                    end else if (level == 2'd0) begin
                        // 异常：遍历到 Level 0 仍不是叶子节点
                        mmu_o_pa      <= 64'hFFFF_FFFF_FFFF_FFFF;
                        current_state <= STATE_DONE;
                    end else begin
                        // 向下一级页表进发
                        level         <= level - 1'b1;
                        current_state <= STATE_FETCH_PTE;
                    end
                end

                STATE_DONE: begin
                    mmu_o_valid   <= 1'b1;
                    mmu_o_ready   <= 1'b1;
                    current_state <= STATE_IDLE;
                end

                default: current_state <= STATE_IDLE;
            endcase
        end
    end

endmodule

/* verilator lint_on WIDTHTRUNC */