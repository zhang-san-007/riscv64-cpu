module fetch(
    input   [63:0]  pc_i,
    output  [63:0]  inst_o
);
assign inst_o = mem[pc_i];
endmodule
