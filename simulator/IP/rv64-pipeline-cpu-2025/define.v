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
`define nop_csr_id             12'd0
`define nop_csr_wen             1'd0
//commit
`define nop_commit_info         161'd0




// User Level CSRs
`define cycle          12'hC00
`define timer          12'hC01
`define instret        12'hC02

// Machine Level CSRs
`define mvendorid    12'hF11
`define marchid      12'hF12
`define mimpid       12'hF13
`define mhartid      12'hF14
`define mconfigptr   12'hF15
`define misa        12'h301
`define mstatus     12'h300
`define medeleg     12'h302
`define mideleg     12'h303
`define mie         12'h304
`define mtvec       12'h305
`define mcounteren  12'h306
`define mscratch    12'h340
`define mepc        12'h341
`define mcause      12'h342
`define mtval       12'h343
`define mip         12'h344
`define mcycle      12'hB00
`define minstret    12'hB02
`define menvcfg     12'h30A


// Supervisor Level CSRs
`define stimecmp    12'h14d
`define sstatus     12'h100
`define sie         12'h104
`define stvec       12'h105
`define scounteren  12'h106
`define sscratch    12'h140
`define sepc        12'h141
`define scause      12'h142
`define stval       12'h143
`define sip         12'h144
`define satp        12'h180

// PMP (Physical Memory Protection)
`define pmpcfg0     12'h3A0
`define pmpcfg1     12'h3A1
`define pmpcfg2     12'h3A2
`define pmpcfg3     12'h3A3
`define pmpaddr0    12'h3B0
`define pmpaddr1    12'h3B1
`define pmpaddr2    12'h3B2
`define pmpaddr3    12'h3B3
`define pmpaddr4    12'h3B4
`define pmpaddr5    12'h3B5
`define pmpaddr6    12'h3B6
`define pmpaddr7    12'h3B7
`define pmpaddr8    12'h3B8
`define pmpaddr9    12'h3B9
`define pmpaddr10   12'h3BA
`define pmpaddr11   12'h3BB
`define pmpaddr12   12'h3BC
`define pmpaddr13   12'h3BD
`define pmpaddr14   12'h3BE
`define pmpaddr15   12'h3BF

