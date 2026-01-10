module check_csr_rid(
    input wire  [11:0]  csr_rid1,
    input wire  [11:0]  csr_rid2,
    output wire         right_csr_rid1,
    output wire         right_csr_rid2
);


wire csr_id1_user    =    (csr_rid1 == `cycle)      | (csr_rid1 == `timer)       | (csr_rid1 == `instret);
wire csr_id1_machine =    (csr_rid1 == `mvendorid)  | (csr_rid1 == `marchid)     | (csr_rid1 == `mimpid)
                    | (csr_rid1 == `mhartid)        | (csr_rid1 == `mconfigptr)  | (csr_rid1 == `misa)
                    | (csr_rid1 == `mstatus)        | (csr_rid1 == `medeleg)     | (csr_rid1 == `mideleg)
                    | (csr_rid1 == `mie)            | (csr_rid1 == `mtvec)       | (csr_rid1 == `mcounteren)
                    | (csr_rid1 == `mscratch)       | (csr_rid1 == `mepc)        | (csr_rid1 == `mcause)
                    | (csr_rid1 == `mtval)          | (csr_rid1 == `mip)         | (csr_rid1 == `mcycle)                 
                    | (csr_rid1 == `minstret)       | (csr_rid1 == `menvcfg);
wire csr_id1_super = (csr_rid1 == `sstatus)         | (csr_rid1 == `sie)         | (csr_rid1 == `stvec)     | (csr_rid1 == `scounteren)
                    | (csr_rid1 == `sscratch)       | (csr_rid1 == `sepc)        | (csr_rid1 == `scause)    | (csr_rid1 == `stval)
                    | (csr_rid1 == `sip)            | (csr_rid1 == `satp)        | (csr_rid1 == `stimecmp);
wire csr_id1_pmp =    (csr_rid1 == `pmpcfg0)        | (csr_rid1 == `pmpcfg1)     | (csr_rid1 == `pmpcfg2)   | (csr_rid1 == `pmpcfg3)
                    | (csr_rid1 == `pmpaddr0)       | (csr_rid1 == `pmpaddr1)    | (csr_rid1 == `pmpaddr2)  | (csr_rid1 == `pmpaddr3)
                    | (csr_rid1 == `pmpaddr4)       | (csr_rid1 == `pmpaddr5)    | (csr_rid1 == `pmpaddr6)  | (csr_rid1 == `pmpaddr7)
                    | (csr_rid1 == `pmpaddr8)       | (csr_rid1 == `pmpaddr9)    | (csr_rid1 == `pmpaddr10) | (csr_rid1 == `pmpaddr11)
                    | (csr_rid1 == `pmpaddr12)      | (csr_rid1 == `pmpaddr13)   | (csr_rid1 == `pmpaddr14) | (csr_rid1 == `pmpaddr15);


wire csr_id2_user    =    (csr_rid2 == `cycle)       | (csr_rid2 == `timer)         | (csr_rid2 == `instret);
wire csr_id2_machine =    (csr_rid2 == `mvendorid)   | (csr_rid2 == `marchid)       | (csr_rid2 == `mimpid)
                        | (csr_rid2 == `mhartid)     | (csr_rid2 == `mconfigptr)    | (csr_rid2 == `misa)
                        | (csr_rid2 == `mstatus)     | (csr_rid2 == `medeleg)       | (csr_rid2 == `mideleg)
                        | (csr_rid2 == `mie)         | (csr_rid2 == `mtvec)         | (csr_rid2 == `mcounteren)
                        | (csr_rid2 == `mscratch)    | (csr_rid2 == `mepc)          | (csr_rid2 == `mcause)
                        | (csr_rid2 == `mtval)       | (csr_rid2 == `mip)           | (csr_rid2 == `mcycle)                 
                        | (csr_rid2 == `minstret)    | (csr_rid2 == `menvcfg);
wire csr_id2_super =      (csr_rid2 == `sstatus)     | (csr_rid2 == `sie)           | (csr_rid2 == `stvec)      | (csr_rid2 == `scounteren)
                        | (csr_rid2 == `sscratch)    | (csr_rid2 == `sepc)          | (csr_rid2 == `scause)     | (csr_rid2 == `stval)
                        | (csr_rid2 == `sip)         | (csr_rid2 == `satp)          | (csr_rid2 == `stimecmp);
wire csr_id2_pmp =        (csr_rid2 == `pmpcfg0)     | (csr_rid2 == `pmpcfg1)       | (csr_rid2 == `pmpcfg2)    | (csr_rid2 == `pmpcfg3)
                        | (csr_rid2 == `pmpaddr0)    | (csr_rid2 == `pmpaddr1)      | (csr_rid2 == `pmpaddr2)   | (csr_rid2 == `pmpaddr3)
                        | (csr_rid2 == `pmpaddr4)    | (csr_rid2 == `pmpaddr5)      | (csr_rid2 == `pmpaddr6)   | (csr_rid2 == `pmpaddr7)
                        | (csr_rid2 == `pmpaddr8)    | (csr_rid2 == `pmpaddr9)      | (csr_rid2 == `pmpaddr10)  | (csr_rid2 == `pmpaddr11)
                        | (csr_rid2 == `pmpaddr12)   | (csr_rid2 == `pmpaddr13)     | (csr_rid2 == `pmpaddr14)  | (csr_rid2 == `pmpaddr15);

assign right_csr_rid1 = csr_id1_user | csr_id1_machine | csr_id1_super | csr_id1_pmp;
assign right_csr_rid2 = csr_id2_user | csr_id2_machien | csr_id2_super | csr_id2_pmp;

endmodule

