module csr(


)
//----------------------------------------------------------csr_id--begin-----------------------------------------------
// Machine Information Registers
localparam mvendorid_id   = 12'hf11; localparam marchid_id     = 12'hf12;
localparam mimpid_id      = 12'hf13; localparam mhartid_id     = 12'hf14;
localparam mconfigptr_id  = 12'hf15;
// Machine Trap Setup
localparam mstatus_id     = 12'h300; localparam misa_id        = 12'h301;
localparam medeleg_id     = 12'h302; localparam mideleg_id     = 12'h303;
localparam mie_id         = 12'h304; localparam mtvec_id       = 12'h305;
localparam mcounteren_id  = 12'h306;
// Machine Trap Handling
localparam mscratch_id    = 12'h340; localparam mepc_id        = 12'h341;
localparam mcause_id      = 12'h342; localparam mtval_id       = 12'h343;
localparam mip_id         = 12'h344;
// Machine Memory Protection
localparam pmpcfg0_id     = 12'h3a0; localparam pmpcfg1_id     = 12'h3a1;
localparam pmpcfg2_id     = 12'h3a2; localparam pmpcfg3_id     = 12'h3a3;
localparam pmpaddr0_id    = 12'h3b0; localparam pmpaddr1_id    = 12'h3b1;
localparam pmpaddr2_id    = 12'h3b2; localparam pmpaddr3_id    = 12'h3b3;
localparam pmpaddr4_id    = 12'h3b4; localparam pmpaddr5_id    = 12'h3b5;
localparam pmpaddr6_id    = 12'h3b6; localparam pmpaddr7_id    = 12'h3b7;
localparam pmpaddr8_id    = 12'h3b8; localparam pmpaddr9_id    = 12'h3b9;
localparam pmpaddr10_id   = 12'h3ba; localparam pmpaddr11_id   = 12'h3bb;
localparam pmpaddr12_id   = 12'h3bc; localparam pmpaddr13_id   = 12'h3bd;
localparam pmpaddr14_id   = 12'h3be; localparam pmpaddr15_id   = 12'h3bf;
// Machine Counter/Timers
localparam mcycle_id      = 12'hb00; localparam minstret_id    = 12'hb02;
// Debug Registers
localparam tselect_id     = 12'h7a0; localparam tdata1_id      = 12'h7a1;
// stap
localparam satp_id        = 12'h180;
//--------------------------------------------------------csr_id----end-------------------------------------------

//-----csr_file------
reg [63:0] csr[4096];



























endmodule