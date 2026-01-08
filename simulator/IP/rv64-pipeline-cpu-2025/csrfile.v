module csrfile(
    input clk,
    input rst,
    //write
    input wire         wb_i_csr_wen,
    input wire  [11:0] wb_i_csr_id,
    input wire  [63:0] wb_i_csr_wdata,

    //read
    input  wire [11:0] decode_i_csr_id,
    output wire [63:0] csr_o_csr_rdata
); 
reg [63:0] csrfile[4096];

import "DPI-C" function void dpi_read_csrfile(input logic [63 : 0] a []); 
initial begin
    dpi_read_csrfile(csrfile);
end
initial begin
    integer i;
    for (i = 0; i < 4096; i = i + 1) begin
        csrfile[i] = 64'd0; 
    end
end


wire [11:0] csr_rid     = decode_i_csr_id;
wire csr_user    =    (csr_rid == `cycle)       | (csr_rid == `timer)       | (csr_rid == `instret);
wire csr_machine =    (csr_rid == `mvendorid)   | (csr_rid == `marchid)     | (csr_rid == `mimpid)
                    | (csr_rid == `mhartid)     | (csr_rid == `mconfigptr)  | (csr_rid == `misa)
                    | (csr_rid == `mstatus)     | (csr_rid == `medeleg)     | (csr_rid == `mideleg)
                    | (csr_rid == `mie)         | (csr_rid == `mtvec)       | (csr_rid == `mcounteren)
                    | (csr_rid == `mscratch)    | (csr_rid == `mepc)        | (csr_rid == `mcause)
                    | (csr_rid == `mtval)       | (csr_rid == `mip)         | (csr_rid == `mcycle)                 
                    | (csr_rid == `minstret);
wire csr_supervisor = (csr_rid == `sstatus)   | (csr_rid == `sie)     | (csr_rid == `stvec)  | (csr_rid == `scounteren)
                    | (csr_rid == `sscratch)  | (csr_rid == `sepc)    | (csr_rid == `scause) | (csr_rid == `stval)
                    | (csr_rid == `sip)       | (csr_rid == `satp);
wire csr_pmp =        (csr_rid == `pmpcfg0)  | (csr_rid == `pmpcfg1)  | (csr_rid == `pmpcfg2)  | (csr_rid == `pmpcfg3)
                    | (csr_rid == `pmpaddr0) | (csr_rid == `pmpaddr1) | (csr_rid == `pmpaddr2) | (csr_rid == `pmpaddr3)
                    | (csr_rid == `pmpaddr4) | (csr_rid == `pmpaddr5) | (csr_rid == `pmpaddr6) | (csr_rid == `pmpaddr7)
                    | (csr_rid == `pmpaddr8) | (csr_rid == `pmpaddr9) | (csr_rid == `pmpaddr10)| (csr_rid == `pmpaddr11)
                    | (csr_rid == `pmpaddr12)| (csr_rid == `pmpaddr13)| (csr_rid == `pmpaddr14)| (csr_rid == `pmpaddr15);
wire right_csr_rid = csr_user | csr_machine | csr_supervisor | csr_pmp;

assign csr_o_csr_rdata =  right_csr_rid ? csrfile[csr_rid] : 64'd0;  


//CSR的初始值

wire csr_wen    = wb_i_csr_wen;
wire [11:0] csr_wid     = wb_i_csr_id;
wire [63:0] csr_wdata  = wb_i_csr_wdata; 




always @(posedge clk) begin
    if(rst) begin
        // csrfile[`mhartid] <= 64'd0;
        // csrfile[`mtvec]   <= 64'd0;
        // csrfile[`mstatus] <= 64'd0; //64'h0000_000a_0000_0000;
        // csrfile[`mie]     <= 64'd0;
        // csrfile[`mip]     <= 64'd0;        
        // csrfile[`satp]    <= 64'd0;
        // csrfile[`medeleg] <= 64'd0;
        // csrfile[`mideleg] <= 64'd0;
    end
    else if(csr_wen) begin
        csrfile[csr_wid] <= csr_wdata;
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