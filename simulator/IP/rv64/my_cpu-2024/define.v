`define alu_valA_sel_valA   2'd0
`define alu_valA_sel_pc     2'd1
`define alu_valA_sel_zero   2'd2

`define alu_valB_sel_valB   2'd0
`define alu_valB_sel_imm    2'd1
`define alu_valB_sel_zero   2'd2

`define alu_func_add        4'd0
`define alu_func_sub        4'd1
`define alu_func_sll        4'd2
`define alu_func_slt        4'd3
`define alu_func_sltu       4'd4
`define alu_func_xor        4'd5
`define alu_func_srl        4'd6
`define alu_func_sra        4'd7
`define alu_func_or         4'd8
`define alu_func_and        4'd9
`define alu_func_jalr       4'd10

`define alu_func_out_normal 1'd0
`define alu_func_out_cut    1'd1

`define mem_read_stop       1'b0
`define mem_read_allow      1'b1

`define mem_write_stop      1'b0
`define mem_write_allow     1'b1

`define zero_byte           4'd0
`define one_byte            4'd1
`define two_byte            4'd2
`define four_byte           4'd4
`define eight_byte          4'd8

`define lb                  3'b000
`define lh                  3'b001
`define lw                  3'b010
`define ld                  3'b011
`define lbu                 3'b100
`define lhu                 3'b101
`define lwu                 3'b110
`define mem_no_read         3'b111

`define reg_wen_w           1'd1
`define reg_wen_no_w	    1'd0

`define wb_valD_sel_valE    2'd0
`define wb_valD_sel_valM    2'd1
`define wb_valD_sel_valP    2'd2


//最开始的nop指令
`define nop_instr           32'h00000013
`define nop_commit          1'b0
`define nop_pc              64'd0
`define nop_pre_pc          64'd0

//debug
`define debug               1'b0