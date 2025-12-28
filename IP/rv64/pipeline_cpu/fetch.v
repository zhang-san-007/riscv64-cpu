
module fetch
#(parameter WIDTH=64, INSTR=32, COMMIT=161)
(
    input  wire  [WIDTH - 1  :0]     pc,
    output wire  [WIDTH - 1  :0]     fetch_pc,
    output wire  [INSTR - 1  :0]     fetch_instr,
    output wire  [WIDTH - 1  :0]     fetch_pre_pc,
    output wire  [COMMIT- 1  :0]     fetch_commit_info
);

import "DPI-C" function int dpi_instr_mem_read (input longint addr);

assign fetch_pc           =  pc;
assign fetch_instr        =  dpi_instr_mem_read(pc);
assign fetch_pre_pc       =  fetch_pc + 64'd4;
assign fetch_commit_info  = {1'b1, fetch_instr, fetch_pre_pc, fetch_pc};

endmodule 

