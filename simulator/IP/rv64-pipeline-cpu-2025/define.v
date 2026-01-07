//pc&instr
`define nop_pc                  64'd0
`define nop_instr               32'h00000013 // addi x0, x0, 0
//info
`define nop_alu_info            28'd0
`define nop_load_store_info     11'd0   
`define nop_opcode_info         13'd0
`define nop_branch_info         6'd0
`define nop_csrrw_info          6'd0
`define nop_system_info         7'd0
//data
`define nop_imm                 64'd0
`define nop_regdata1            64'd0
`define nop_regdata2            64'd0
`define nop_csr_rdata           64'd0
`define nop_mem_rdata           64'd0
`define nop_alu_result          64'd0
//reg&csr
`define nop_reg_rd              5'd0
`define nop_reg_wen             1'd0
`define nop_csr_id              12'd0
`define nop_csr_wen             1'd0
//commit
`define nop_commit_info         161'd0




// User Level CSRs
`define cycle_id           12'hC00
`define timer_id           12'hC01
`define instret_id         12'hC02

// Machine Level CSRs
`define mvendorid_id    12'hF11
`define marchid_id      12'hF12
`define mimpid_id       12'hF13
`define mhartid_id      12'hF14
`define mconfigptr_id   12'hF15
`define misa_id         12'h301
`define mstatus_id      12'h300
`define medeleg_id      12'h302
`define mideleg_id      12'h303
`define mie_id          12'h304
`define mtvec_id        12'h305
`define mcounteren_id   12'h306
`define mscratch_id     12'h340
`define mepc_id         12'h341
`define mcause_id       12'h342
`define mtval_id        12'h343
`define mip_id          12'h344
`define mcycle_id       12'hB00
`define minstret_id     12'hB02

// Supervisor Level CSRs
`define sstatus_id      12'h100
`define sie_id          12'h104
`define stvec_id        12'h105
`define scounteren_id   12'h106
`define sscratch_id     12'h140
`define sepc_id         12'h141
`define scause_id       12'h142
`define stval_id        12'h143
`define sip_id          12'h144
`define satp_id         12'h180

// PMP (Physical Memory Protection)
`define pmpcfg0_id      12'h3A0
`define pmpcfg1_id      12'h3A1
`define pmpcfg2_id      12'h3A2
`define pmpcfg3_id      12'h3A3
`define pmpaddr0_id     12'h3B0
`define pmpaddr1_id     12'h3B1
`define pmpaddr2_id     12'h3B2
`define pmpaddr3_id     12'h3B3
`define pmpaddr4_id     12'h3B4
`define pmpaddr5_id     12'h3B5
`define pmpaddr6_id     12'h3B6
`define pmpaddr7_id     12'h3B7
`define pmpaddr8_id     12'h3B8
`define pmpaddr9_id     12'h3B9
`define pmpaddr10_id    12'h3BA
`define pmpaddr11_id    12'h3BB
`define pmpaddr12_id    12'h3BC
`define pmpaddr13_id    12'h3BD
`define pmpaddr14_id    12'h3BE
`define pmpaddr15_id    12'h3BF
