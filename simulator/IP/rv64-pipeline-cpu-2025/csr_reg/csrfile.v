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

//csr data

// ==================== 性能计数器 ====================
wire [63:0] cycle      = csrfile[`cycle];      // 12'hC00 - 时钟周期计数器
wire [63:0] timer      = csrfile[`timer];      // 12'hC01 - 实时时钟计数器
wire [63:0] instret    = csrfile[`instret];    // 12'hC02 - 指令退休计数器

// ==================== 机器信息寄存器 ====================
wire [63:0] mvendorid  = csrfile[`mvendorid];  // 12'hF11 - 厂商ID
wire [63:0] marchid    = csrfile[`marchid];    // 12'hF12 - 架构ID
wire [63:0] mimpid     = csrfile[`mimpid];     // 12'hF13 - 实现ID
wire [63:0] mhartid    = csrfile[`mhartid];    // 12'hF14 - 硬件线程ID
wire [63:0] mconfigptr = csrfile[`mconfigptr]; // 12'hF15 - 配置结构指针

// ==================== 机器模式控制和状态寄存器 ====================
wire [63:0] misa       = csrfile[`misa];       // 12'h301 - ISA信息
wire [63:0] mstatus    = csrfile[`mstatus];    // 12'h300 - 机器状态
wire [63:0] medeleg    = csrfile[`medeleg];    // 12'h302 - 异常委托
wire [63:0] mideleg    = csrfile[`mideleg];    // 12'h303 - 中断委托
wire [63:0] mie        = csrfile[`mie];        // 12'h304 - 中断使能
wire [63:0] mtvec      = csrfile[`mtvec];      // 12'h305 - 机器异常向量基址
wire [63:0] mcounteren = csrfile[`mcounteren]; // 12'h306 - 计数器使能
wire [63:0] mscratch   = csrfile[`mscratch];   // 12'h340 - 机器临时数据
wire [63:0] mepc       = csrfile[`mepc];       // 12'h341 - 机器异常程序计数器
wire [63:0] mcause     = csrfile[`mcause];     // 12'h342 - 机器异常原因
wire [63:0] mtval      = csrfile[`mtval];      // 12'h343 - 机器异常值
wire [63:0] mip        = csrfile[`mip];        // 12'h344 - 机器中断等待
wire [63:0] mcycle     = csrfile[`mcycle];     // 12'hB00 - 机器模式时钟周期计数器
wire [63:0] minstret   = csrfile[`minstret];   // 12'hB02 - 机器模式指令退休计数器
wire [63:0] menvcfg    = csrfile[`menvcfg];    // 12'h30A - 

// ==================== 监督模式控制和状态寄存器 ====================
wire [63:0] sstatus    = csrfile[`sstatus];    // 12'h100 - 监督状态
wire [63:0] sie        = csrfile[`sie];        // 12'h104 - 监督中断使能
wire [63:0] stvec      = csrfile[`stvec];      // 12'h105 - 监督异常向量基址
wire [63:0] scounteren = csrfile[`scounteren]; // 12'h106 - 监督计数器使能
wire [63:0] sscratch   = csrfile[`sscratch];   // 12'h140 - 监督临时数据
wire [63:0] sepc       = csrfile[`sepc];       // 12'h141 - 监督异常程序计数器
wire [63:0] scause     = csrfile[`scause];     // 12'h142 - 监督异常原因
wire [63:0] stval      = csrfile[`stval];      // 12'h143 - 监督异常值
wire [63:0] sip        = csrfile[`sip];        // 12'h144 - 监督中断等待
wire [63:0] satp       = csrfile[`satp];       // 12'h180 - 监督地址转换和保护

// ==================== 物理内存保护配置寄存器 ====================
wire [63:0] pmpcfg0    = csrfile[`pmpcfg0];    // 12'h3A0 - PMP配置寄存器0
wire [63:0] pmpcfg1    = csrfile[`pmpcfg1];    // 12'h3A1 - PMP配置寄存器1
wire [63:0] pmpcfg2    = csrfile[`pmpcfg2];    // 12'h3A2 - PMP配置寄存器2
wire [63:0] pmpcfg3    = csrfile[`pmpcfg3];    // 12'h3A3 - PMP配置寄存器3

// ==================== 物理内存保护地址寄存器 ====================
wire [63:0] pmpaddr0   = csrfile[`pmpaddr0];   // 12'h3B0 - PMP地址寄存器0
wire [63:0] pmpaddr1   = csrfile[`pmpaddr1];   // 12'h3B1 - PMP地址寄存器1
wire [63:0] pmpaddr2   = csrfile[`pmpaddr2];   // 12'h3B2 - PMP地址寄存器2
wire [63:0] pmpaddr3   = csrfile[`pmpaddr3];   // 12'h3B3 - PMP地址寄存器3
wire [63:0] pmpaddr4   = csrfile[`pmpaddr4];   // 12'h3B4 - PMP地址寄存器4
wire [63:0] pmpaddr5   = csrfile[`pmpaddr5];   // 12'h3B5 - PMP地址寄存器5
wire [63:0] pmpaddr6   = csrfile[`pmpaddr6];   // 12'h3B6 - PMP地址寄存器6
wire [63:0] pmpaddr7   = csrfile[`pmpaddr7];   // 12'h3B7 - PMP地址寄存器7
wire [63:0] pmpaddr8   = csrfile[`pmpaddr8];   // 12'h3B8 - PMP地址寄存器8
wire [63:0] pmpaddr9   = csrfile[`pmpaddr9];   // 12'h3B9 - PMP地址寄存器9
wire [63:0] pmpaddr10  = csrfile[`pmpaddr10];  // 12'h3BA - PMP地址寄存器10
wire [63:0] pmpaddr11  = csrfile[`pmpaddr11];  // 12'h3BB - PMP地址寄存器11
wire [63:0] pmpaddr12  = csrfile[`pmpaddr12];  // 12'h3BC - PMP地址寄存器12
wire [63:0] pmpaddr13  = csrfile[`pmpaddr13];  // 12'h3BD - PMP地址寄存器13
wire [63:0] pmpaddr14  = csrfile[`pmpaddr14];  // 12'h3BE - PMP地址寄存器14
wire [63:0] pmpaddr15  = csrfile[`pmpaddr15];  // 12'h3BF - PMP地址寄存器15

//dpi
import "DPI-C" function void dpi_read_csrfile(input logic [63 : 0] a []); 
initial begin
    integer i;
    for (i = 0; i < 4096; i = i + 1) begin
        csrfile[i] = 64'd0; 
    end
    dpi_read_csrfile(csrfile);
end


//csr read
wire [11:0] csr_rid     = decode_i_csr_id;
wire csr_user_r    =    (csr_rid == `cycle)       | (csr_rid == `timer)       | (csr_rid == `instret);
wire csr_machine_r =    (csr_rid == `mvendorid)   | (csr_rid == `marchid)     | (csr_rid == `mimpid)
                    | (csr_rid == `mhartid)     | (csr_rid == `mconfigptr)  | (csr_rid == `misa)
                    | (csr_rid == `mstatus)     | (csr_rid == `medeleg)     | (csr_rid == `mideleg)
                    | (csr_rid == `mie)         | (csr_rid == `mtvec)       | (csr_rid == `mcounteren)
                    | (csr_rid == `mscratch)    | (csr_rid == `mepc)        | (csr_rid == `mcause)
                    | (csr_rid == `mtval)       | (csr_rid == `mip)         | (csr_rid == `mcycle)                 
                    | (csr_rid == `minstret)    | (csr_rid == `menvcfg);
wire csr_supervisor_r = (csr_rid == `sstatus)   | (csr_rid == `sie)     | (csr_rid == `stvec)  | (csr_rid == `scounteren)
                    | (csr_rid == `sscratch)  | (csr_rid == `sepc)    | (csr_rid == `scause) | (csr_rid == `stval)
                    | (csr_rid == `sip)       | (csr_rid == `satp)      | (csr_rid == `stimecmp);
wire csr_pmp_r =        (csr_rid == `pmpcfg0)  | (csr_rid == `pmpcfg1)  | (csr_rid == `pmpcfg2)  | (csr_rid == `pmpcfg3)
                    | (csr_rid == `pmpaddr0) | (csr_rid == `pmpaddr1) | (csr_rid == `pmpaddr2) | (csr_rid == `pmpaddr3)
                    | (csr_rid == `pmpaddr4) | (csr_rid == `pmpaddr5) | (csr_rid == `pmpaddr6) | (csr_rid == `pmpaddr7)
                    | (csr_rid == `pmpaddr8) | (csr_rid == `pmpaddr9) | (csr_rid == `pmpaddr10)| (csr_rid == `pmpaddr11)
                    | (csr_rid == `pmpaddr12)| (csr_rid == `pmpaddr13)| (csr_rid == `pmpaddr14)| (csr_rid == `pmpaddr15);
wire right_csr_rid = csr_user_r | csr_machine_r | csr_supervisor_r | csr_pmp_r;

assign csr_o_csr_rdata =  right_csr_rid ? csrfile[csr_rid] : 64'd0;  


//csr write
wire csr_wen    = wb_i_csr_wen;
wire [11:0] csr_wid     = wb_i_csr_id;
wire [63:0] csr_wdata  = wb_i_csr_wdata; 

wire csr_user_w    =      (csr_wid == `cycle)       | (csr_wid == `timer)       | (csr_wid == `instret);
wire csr_machine_w =      (csr_wid == `mvendorid)   | (csr_wid == `marchid)     | (csr_wid == `mimpid)
                        | (csr_wid == `mhartid)     | (csr_wid == `mconfigptr)  | (csr_wid == `misa)
                        | (csr_wid == `mstatus)     | (csr_wid == `medeleg)     | (csr_wid == `mideleg)
                        | (csr_wid == `mie)         | (csr_wid == `mtvec)       | (csr_wid == `mcounteren)
                        | (csr_wid == `mscratch)    | (csr_wid == `mepc)        | (csr_wid == `mcause)
                        | (csr_wid == `mtval)       | (csr_wid == `mip)         | (csr_wid == `mcycle)                 
                        | (csr_wid == `minstret)    | (csr_wid == `menvcfg);

wire csr_supervisor_w =   (csr_wid == `sstatus)   | (csr_wid == `sie)     | (csr_wid == `stvec)  | (csr_wid == `scounteren)
                    |     (csr_wid == `sscratch)  | (csr_wid == `sepc)    | (csr_wid == `scause) | (csr_wid == `stval)
                    |     (csr_wid == `sip)       | (csr_wid == `satp)    | (csr_wid == `stimecmp);
wire csr_pmp_w =        (csr_wid == `pmpcfg0)  | (csr_wid == `pmpcfg1)  | (csr_wid == `pmpcfg2)  | (csr_wid == `pmpcfg3)
                    | (csr_wid == `pmpaddr0) | (csr_wid == `pmpaddr1) | (csr_wid == `pmpaddr2) | (csr_wid == `pmpaddr3)
                    | (csr_wid == `pmpaddr4) | (csr_wid == `pmpaddr5) | (csr_wid == `pmpaddr6) | (csr_wid == `pmpaddr7)
                    | (csr_wid == `pmpaddr8) | (csr_wid == `pmpaddr9) | (csr_wid == `pmpaddr10)| (csr_wid == `pmpaddr11)
                    | (csr_wid == `pmpaddr12)| (csr_wid == `pmpaddr13)| (csr_wid == `pmpaddr14)| (csr_wid == `pmpaddr15);
wire right_csr_wid = csr_user_w | csr_machine_w | csr_supervisor_w | csr_pmp_w;
always @(posedge clk) begin
    if(rst) begin
        csrfile[`mhartid] <= 64'd0;
        csrfile[`mtvec]   <= 64'd0;
        csrfile[`mstatus] <= 64'h0000_000a_0000_0000;
        csrfile[`mie]     <= 64'h220;
        csrfile[`mip]     <= 64'd0;        
        csrfile[`satp]    <= 64'd0;
        csrfile[`medeleg] <= 64'd0;
        csrfile[`mideleg] <= 64'd0;
    end
    else if(csr_wen && right_csr_wid) begin
        csrfile[csr_wid] <= csr_wdata;
    end
end
                  
//timer
always @(posedge clk) begin
    if(rst) begin
        csrfile[`timer] <= 64'd0;
    end
    else begin
        csrfile[`timer] <= csrfile[`timer]  + 1;
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




endmodule