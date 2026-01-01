`define nop_instr       32'h00000013
`define nop_rd          5'd0
`define nop_reg_wen     1'd0
`define nop_memdata     64'd0
`define nop_opcode_info 
`define nop_alu_result  64'd0
`define nop_pc          64'd0
`define nop_regdata2    64'd0
`define is_nop          


//处于nop的时候，commit是0，模拟器的commit