module csr(
    input clk,
    input rst
    input  wire [63:0] decode_i_regdata1,
    input  wire [11:0] decode_i_csr_id,
    output wire [63:0] csr_o_csrdata
); 

// Machine Information Registers
import "DPI-C" function void get_m_information_csr  (input longint mvendorid, input longint marchid, input longint mimpid, input longint mhartid, input longint mconfigptr);
// Machine Trap Setup and Handling
import "DPI-C" function void get_m_trap_setup_csr   (input longint mstatus, input longint misa, input longint medeleg, input longint mideleg, input longint mie, input longint mtvec, input longint mcounteren);
import "DPI-C" function void get_m_trap_handing_csr (input longint mscratch, input longint mepc, input longint mcause, input longint mtval, input longint mip);
import "DPI-C" function void get_m_counter_timer_csr(input longint mcycle, input longint minstret);

// Supervisor Mode Registers
import "DPI-C" function void get_s_satp_csr           (input longint satp);
import "DPI-C" function void get_s_trap_setup_csr   (input longint sstatus, input longint sie, input longint stvec, input longint scounteren);
import "DPI-C" function void get_s_trap_handing_csr (input longint sscratch, input longint sepc, input longint scause, input longint stval, input longint sip);

// User Mode Registers
import "DPI-C" function void get_u_counter_timer_csr(input longint cycle, input longint timer, input longint instret);

// PMP Configuration and Address Registers
import "DPI-C" function void get_pmp_cfg_csr    (input longint pmpcfg0, input longint pmpcfg1, input longint pmpcfg2, input longint pmpcfg3);
import "DPI-C" function void get_pmp_addr1_csr  (input longint pmpaddr0, input longint pmpaddr1, input longint pmpaddr2, input longint pmpaddr3);
import "DPI-C" function void get_pmp_addr2_csr  (input longint pmpaddr4, input longint pmpaddr5, input longint pmpaddr6, input longint pmpaddr7);
import "DPI-C" function void get_pmp_addr3_csr  (input longint pmpaddr8, input longint pmpaddr9, input longint pmpaddr10, input longint pmpaddr11);
import "DPI-C" function void get_pmp_addr4_csr  (input longint pmpaddr12, input longint pmpaddr13, input longint pmpaddr14, input longint pmpaddr15);

//--------------------------------csr-reg--------------------------------------------
//machine information reg
reg [63:0] mvendorid, marchid, mimpid, mhartid, mconfigptr, misa;
//machine trap setup and handing
reg [63:0] mstatus, medeleg, mideleg, mie, mtvec, mcounteren;
reg [63:0] mscratch, mepc, mcause, mtval, mip;
reg [63:0] mcycle, minstret;

//s mode
reg [63:0] satp;
reg [63:0] sstatus, sie, stvec, scounteren;
reg [63:0] sscratch, sepc, scause, stval, sip;

//user mode
reg [63:0] cycle, timer, instret;
//pmp
reg [63:0] pmpcfg0,     pmpcfg1,    pmpcfg2,    pmpcfg3;
reg [63:0] pmpaddr0,    pmpaddr1,   pmpaddr2,   pmpaddr3;
reg [63:0] pmpaddr4,    pmpaddr5,   pmpaddr6,   pmpaddr7;
reg [63:0] pmpaddr8,    pmpaddr9,   pmpaddr10,  pmpaddr11;
reg [63:0] pmpaddr12,   pmpaddr13,  pmpaddr14,  pmpaddr15; 

always @(*) begin 
    get_m_information_csr  (mvendorid, marchid, mimpid, mhartid, mconfigptr);
    get_m_trap_setup_csr   (mstatus, misa, medeleg, mideleg, mie, mtvec, mcounteren);
    get_m_trap_handing_csr (mscratch, mepc, mcause, mtval, mip);
    get_m_counter_timer_csr(mcycle, minstret);
    get_s_satp_csr         (satp);
    get_s_trap_setup_csr   (sstatus, sie, stvec, scounteren);
    get_s_trap_handing_csr (sscratch, sepc, scause, stval, sip);
    get_u_counter_timer_csr(cycle, timer, instret);
    get_pmp_cfg_csr        (pmpcfg0, pmpcfg1, pmpcfg2, pmpcfg3);
    get_pmp_addr1_csr      (pmpaddr0, pmpaddr1, pmpaddr2, pmpaddr3);
    get_pmp_addr2_csr      (pmpaddr4, pmpaddr5, pmpaddr6, pmpaddr7);
    get_pmp_addr3_csr      (pmpaddr8, pmpaddr9, pmpaddr10, pmpaddr11);
    get_pmp_addr4_csr      (pmpaddr12, pmpaddr13, pmpaddr14, pmpaddr15);
end


wire [11:0] csr_id      = decode_i_csr_id;
wire [63:0] regdata1    = decode_i_regdata1;

assign csrrs_csr_data = (csr_id  == `timer_id)        ?   regdata1 | timer        :
                        (csr_id  == `cycle_id)        ?   regdata1 | cycle       :
                        (csr_id  == `instret_id)      ?   regdata1 | instret     :
                        (csr_id == `mvendorid_id)     ?   regdata1 | mvendorid   :
                        (csr_id == `marchid_id)       ?   regdata1 | marchid     :
                        (csr_id == `mimpid_id)        ?   regdata1 | mimpid      :
                        (csr_id == `mhartid_id)       ?   regdata1 | mhartid     :
                        (csr_id == `mconfigptr_id)    ?   regdata1 | mconfigptr  :
                        (csr_id == `misa_id)          ?   regdata1 | misa        :
                        (csr_id == `mstatus_id)       ?   regdata1 | mstatus     :
                        (csr_id == `medeleg_id)       ?   regdata1 | medeleg     :
                        (csr_id == `mie_id)           ?   regdata1 | mie         :
                        (csr_id == `mtvec_id)         ?   regdata1 | mtvec       :
                        (csr_id == `mcounteren_id)    ?   regdata1 | mcounteren  :
                        (csr_id == `mscratch_id)      ?   regdata1 | mscratch    :    
                        (csr_id == `mepc_id)          ?   regdata1 | mepc        :
                        (csr_id == `mcause_id)        ?   regdata1 | mcause      :
                        (csr_id == `mtval_id)         ?   regdata1 | mtval       :
                        (csr_id == `mip_id)           ?   regdata1 | mip         :
                        (csr_id == `mcycle_id)        ?   regdata1 | mcycle      :
                        (csr_id == `minstret_id)      ?   regdata1 | minstret    :
                        (csr_id == `satp_id)          ?   regdata1 | satp        :
                        (csr_id == `sstatus_id)       ?   regdata1 | sstatus     :
                        (csr_id == `sie_id)           ?   regdata1 | sie         :
                        (csr_id == `stvec_id)         ?   regdata1 | stvec       :
                        (csr_id == `scounteren_id)    ?   regdata1 | scounteren  :
                        (csr_id == `sscratch_id)      ?   regdata1 | sscratch    :
                        (csr_id == `sepc_id)          ?   regdata1 | sepc        :
                        (csr_id == `scause_id)        ?   regdata1 | scause      :
                        (csr_id == `stval_id)         ?   regdata1 | stval       :
                        (csr_id == `sip_id)           ?   regdata1 | sip         :
                        (csr_id == `pmpcfg0_id)       ?   regdata1 | pmpcfg0     :
                        (csr_id == `pmpcfg1_id)       ?   regdata1 | pmpcfg1     :
                        (csr_id == `pmpcfg2_id)       ?   regdata1 | pmpcfg2     :
                        (csr_id == `pmpcfg3_id)       ?   regdata1 | pmpcfg3     :
                        (csr_id == `pmpadd0_id)       ?   regdata1 | pmpaddr0    :
                        (csr_id == `pmpadd1_id)       ?   regdata1 | pmpaddr1    :
                        (csr_id == `pmpadd2_id)       ?   regdata1 | pmpaddr2    :
                        (csr_id == `pmpadd3_id)       ?   regdata1 | pmpaddr3    :
                        (csr_id == `pmpadd4_id)       ?   regdata1 | pmpaddr4    :
                        (csr_id == `pmpadd5_id)       ?   regdata1 | pmpaddr5    :
                        (csr_id == `pmpadd6_id)       ?   regdata1 | pmpaddr6    :
                        (csr_id == `pmpadd7_id)       ?   regdata1 | pmpaddr7    :
                        (csr_id == `pmpadd8_id)       ?   regdata1 | pmpaddr8    :
                        (csr_id == `pmpadd9_id)       ?   regdata1 | pmpaddr9    :
                        (csr_id == `pmpadd10_id)      ?   regdata1 | pmpaddr10   :
                        (csr_id == `pmpadd11_id)      ?   regdata1 | pmpaddr11   :
                        (csr_id == `pmpadd12_id)      ?   regdata1 | pmpaddr12   :
                        (csr_id == `pmpadd13_id)      ?   regdata1 | pmpaddr13   :
                        (csr_id == `pmpadd14_id)      ?   regdata1 | pmpaddr14   :
                        (csr_id == `pmpadd15_id)      ?   regdata1 | pmpaddr15   :64'd0

//CSR的初始值
always @(posedge clk) begin
    if(rst) begin
        mhartid <= 64'd0;
        mtvec   <= 64'd0;
        mstatus <= 64'd0; //这个设置的可能不对。
        mie     <= 64'd0;
        mip     <= 64'd0;
        satp    <= 64'd0;
        medeleg <= 64'd0;
        mideleg <= 64'd0;
    end
end
                  

// // 按照 RISC-V 典型的异常优先级排序实现
// // 优先级：取指异常 > 非法指令 > 环境调用 > 访存异常
//                      // 1. 取指阶段 (Instruction Fetch)
// // 定义一个不可达的值，通常 12'hFFF 比较合适（因为有效的异常 ID 只有 0-63）
// localparam NO_EXCEPTION = 12'hFFF;
// assign excption_id =    excption_instruction_address_misaligned   ? 12'd0  :
//                         excption_instruction_access_fault         ? 12'd1  :
//                         excption_instruction_page_fault           ? 12'd12 :    
//                         // 2. 解码与执行阶段 (Decode/Execute)
//                         excption_instruction_illegal_instruction  ? 12'd2  :
//                         excption_breakpoint                       ? 12'd3  :
//                         excption_ecall_from_umode                 ? 12'd8  :
//                         excption_ecall_from_smode                 ? 12'd9  :
//                         excption_ecall_from_mmode                 ? 12'd11 :    
//                         // 3. 访存阶段 (Load/Store/AMO)
//                         excption_load_address_misaligned          ? 12'd4  :
//                         excption_load_access_fault                ? 12'd5  :
//                         excption_load_page_fault                  ? 12'd13 :
//                         excption_store_amo_address_misaligned     ? 12'd6  :
//                         excption_store_amo_access_fault           ? 12'd7  :
//                         excption_store_amo_page_fault             ? 12'd15 :
//                         // 4. 无异常
//                         NO_EXCEPTION;
// wire mstatus_mpie= mstatus[7];
// wire mstatus_mpp = mstatus[12:11];
// wire mstatus_mie = mstatus[3];


// always @(posedge clk) begin
//     if(如果发生异常) begin
//         mepc <= pc;             //保存当前PC值到mepc中
//         mcause <= 异常类型;      //把异常的类型更新到mcause寄存器
//         mtval <= 虚拟地址;       //把发生异常时的虚拟地址更新到mtval寄存器中
//         mstatus_mpie <= xx;     //保存异常发生前的中断状态，即把异常发生前的MIE字段保存到mstatus寄存器的MPIE字段中
//         mstatus_mpp <= xx;      //保存异常发生前的处理器模式，即把异常发生前的处理器模式保存到mstatus寄存器的MPP字段中
//         mstatus_mie <= xx;      //关闭本地中断，即设置mstatus寄存器中的MIE字段为0    
//     end
//     else begin
//     end
// end


endmodule