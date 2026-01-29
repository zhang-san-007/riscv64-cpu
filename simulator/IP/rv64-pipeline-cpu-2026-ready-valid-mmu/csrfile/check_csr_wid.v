module check_csr_wid(
    input  wire [11:0] csr_wid,
    output wire        right_csr_wid
);

wire csr_user    =      (csr_wid == `cycle)       | (csr_wid == `timer)       | (csr_wid == `instret);
wire csr_machine =      (csr_wid == `mvendorid)   | (csr_wid == `marchid)     | (csr_wid == `mimpid)
                        | (csr_wid == `mhartid)     | (csr_wid == `mconfigptr)  | (csr_wid == `misa)
                        | (csr_wid == `mstatus)     | (csr_wid == `medeleg)     | (csr_wid == `mideleg)
                        | (csr_wid == `mie)         | (csr_wid == `mtvec)       | (csr_wid == `mcounteren)
                        | (csr_wid == `mscratch)    | (csr_wid == `mepc)        | (csr_wid == `mcause)
                        | (csr_wid == `mtval)       | (csr_wid == `mip)         | (csr_wid == `mcycle)                 
                        | (csr_wid == `minstret)    | (csr_wid == `menvcfg);
wire csr_super =   (csr_wid == `sstatus)   | (csr_wid == `sie)     | (csr_wid == `stvec)  | (csr_wid == `scounteren)
                        |     (csr_wid == `sscratch)  | (csr_wid == `sepc)    | (csr_wid == `scause) | (csr_wid == `stval)
                        |     (csr_wid == `sip)       | (csr_wid == `satp)    | (csr_wid == `stimecmp);
wire csr_pmp =        (csr_wid == `pmpcfg0)  | (csr_wid == `pmpcfg1)  | (csr_wid == `pmpcfg2)  | (csr_wid == `pmpcfg3)
                    | (csr_wid == `pmpaddr0) | (csr_wid == `pmpaddr1) | (csr_wid == `pmpaddr2) | (csr_wid == `pmpaddr3)
                    | (csr_wid == `pmpaddr4) | (csr_wid == `pmpaddr5) | (csr_wid == `pmpaddr6) | (csr_wid == `pmpaddr7)
                    | (csr_wid == `pmpaddr8) | (csr_wid == `pmpaddr9) | (csr_wid == `pmpaddr10)| (csr_wid == `pmpaddr11)
                    | (csr_wid == `pmpaddr12)| (csr_wid == `pmpaddr13)| (csr_wid == `pmpaddr14)| (csr_wid == `pmpaddr15);

assign right_csr_wid = csr_user | csr_super | csr_machine | csr_pmp;
endmodule