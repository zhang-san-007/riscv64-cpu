// 1. 判定当前地址落在哪个 PMP 区域 (假设有 8 个区域)
wire [7:0] region_match;
assign region_match[0] = is_in_range(current_pc, pmpaddr0, pmpcfg0.mode);
assign region_match[1] = is_in_range(current_pc, pmpaddr1, pmpcfg1.mode);
assign region_match[2] = is_in_range(current_pc, pmpaddr2, pmpcfg2.mode);
assign region_match[3] = is_in_range(current_pc, pmpaddr3, pmpcfg3.mode);
assign region_match[4] = is_in_range(current_pc, pmpaddr3, pmpcfg4.mode);

wire [2:0] matched_index;
priority_encoder8_3 my_encoder (
    .in(region_match),
    .out(matched_index)
);
wire has_x_permission;
assign has_x_permission = pmpcfg[matched_index].X; // 获取该区域的执行权限位

always @(*) begin
    if (|region_match) begin
        if (!has_x_permission && (priv_mode != MACHINE_MODE || pmpcfg[matched_index].L))
            instruction_access_fault = 1'b1;
        else
            instruction_access_fault = 1'b0;
    end else begin
        // 情况 B: 没有任何区域匹配
        // 如果是 M 模式，默认允许通过；如果是 U/S 模式，默认禁止
        instruction_access_fault = (priv_mode == MACHINE_MODE) ? 1'b0 : 1'b1;
    end
end