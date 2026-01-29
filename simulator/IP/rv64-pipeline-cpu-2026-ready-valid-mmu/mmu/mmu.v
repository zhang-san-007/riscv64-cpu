/* verilator lint_off WIDTHTRUNC */

module mmu(
    input  wire         clk,
    input  wire         rst,
    input  wire [63:0]  va,
    input  wire         va_i_valid,
    input  wire [63:0]  satp,

    output wire         mmu_o_ready,
    output wire [63:0]  mmu_o_pa,
    output wire         mmu_o_valid
);

    import "DPI-C" function longint dpi_mem_read (input longint addr, input int len, input longint pc);

    localparam STATE_IDLE      = 3'd0;
    localparam STATE_FETCH_PTE = 3'd1;
    localparam STATE_CHECK_PTE = 3'd2;
    localparam STATE_DONE      = 3'd3;

    reg [2:0]  current_state;
    reg [1:0]  level;
    reg [63:0] current_pte;
    reg [63:0] v_addr_reg;
    reg [63:0] mmu_o_pa_reg;
    reg        mmu_o_valid_reg;
    reg        mmu_o_ready_reg;

    wire [43:0] satp_ppn       = satp[43:0];
    wire [3:0]  satp_mode      = satp[63:60];
    wire        translation_en = (satp_mode == 4'd8);

    wire [8:0] vpn_at_level = (level == 2'd2) ? v_addr_reg[38:30] :
                              (level == 2'd1) ? v_addr_reg[29:21] : 
                                                v_addr_reg[20:12];

    wire pte_v   = current_pte[0];
    wire pte_r   = current_pte[1];
    wire pte_w   = current_pte[2];
    wire pte_x   = current_pte[3];
    wire is_leaf = (pte_r | pte_w | pte_x);

    wire [63:0] base_addr = (current_state == STATE_IDLE) ? 
                            {8'b0, satp_ppn, 12'b0} : 
                            {8'b0, current_pte[53:10], 12'b0};

    wire [63:0] offset    = (current_state == STATE_IDLE) ? 
                            {53'b0, va[38:30], 3'b0} : 
                            {53'b0, vpn_at_level, 3'b0};

    wire [63:0] next_pte_addr = base_addr + offset;

    assign mmu_o_pa    = (va_i_valid && !translation_en) ? va : mmu_o_pa_reg;
    assign mmu_o_valid = (va_i_valid && !translation_en) ? 1'b1 : mmu_o_valid_reg;
    assign mmu_o_ready = (!translation_en) ? 1'b1 : mmu_o_ready_reg;

    always @(posedge clk) begin
        if (rst) begin
            current_state   <= STATE_IDLE;
            mmu_o_ready_reg <= 1'b1;
            mmu_o_valid_reg <= 1'b0;
            mmu_o_pa_reg    <= 64'b0;
            level           <= 2'd2;
            current_pte     <= 64'b0;
            v_addr_reg      <= 64'b0;
        end else begin
            case (current_state)
                STATE_IDLE: begin
                    mmu_o_valid_reg <= 1'b0;
                    if (va_i_valid && translation_en && mmu_o_ready_reg) begin
                        mmu_o_ready_reg <= 1'b0;
                        v_addr_reg      <= va;
                        level           <= 2'd2;
                        current_pte     <= dpi_mem_read(next_pte_addr, 8, 0);
                        current_state   <= STATE_CHECK_PTE;
                    end
                end

                STATE_FETCH_PTE: begin
                    current_pte   <= dpi_mem_read(next_pte_addr, 8, 0);
                    current_state <= STATE_CHECK_PTE;
                end

                STATE_CHECK_PTE: begin
                    if (!pte_v || (!pte_r && pte_w)) begin
                        mmu_o_pa_reg  <= 64'hFFFF_FFFF_FFFF_FFFF; 
                        current_state <= STATE_DONE;
                    end else if (is_leaf) begin
                        case (level)
                            2'd2: mmu_o_pa_reg <= {8'b0, current_pte[53:28], v_addr_reg[29:0]};
                            2'd1: mmu_o_pa_reg <= {8'b0, current_pte[53:19], v_addr_reg[20:0]};
                            2'd0: mmu_o_pa_reg <= {8'b0, current_pte[53:10], v_addr_reg[11:0]};
                            default: mmu_o_pa_reg <= 64'hFFFF_FFFF_FFFF_FFFF;
                        endcase
                        current_state <= STATE_DONE;
                    end else if (level == 2'd0) begin
                        mmu_o_pa_reg  <= 64'hFFFF_FFFF_FFFF_FFFF;
                        current_state <= STATE_DONE;
                    end else begin
                        level         <= level - 1'b1;
                        current_state <= STATE_FETCH_PTE;
                    end
                end

                STATE_DONE: begin
                    mmu_o_valid_reg <= 1'b1;
                    mmu_o_ready_reg <= 1'b1;
                    current_state   <= STATE_IDLE;
                end

                default: current_state <= STATE_IDLE;
            endcase
        end
    end

endmodule

/* verilator lint_on WIDTHTRUNC */