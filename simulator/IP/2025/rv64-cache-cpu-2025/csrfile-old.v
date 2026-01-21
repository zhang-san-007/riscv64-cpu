// module csr(
//     input clk,
//     input rst
// ); 

// //--------------------------------------------------------------------------
// // 1. Control and Status Registers (Read/Write)
// //--------------------------------------------------------------------------
// // Machine Trap Setup
// reg [63:0] mstatus;    // Machine Status Register，
// reg [63:0] medeleg;    // Machine Exception Delegation Register
// reg [63:0] mideleg;    // Machine Interrupt Delegation Register
// reg [63:0] mie;        // Machine Interrupt Enable Register
// reg [63:0] mtvec;      // Machine Trap-Vector Base-Address Register
// reg [63:0] mcounteren; // Machine Counter Enable Register

// // Machine Trap Handling
// reg [63:0] mscratch;   // Machine Scratch Register (for temporary storage)
// reg [63:0] mepc;       // Machine Exception Program Counter
// reg [63:0] mcause;     // Machine Cause Register
// reg [63:0] mtval;      // Machine Trap Value Register
// reg [63:0] mip;        // Machine Interrupt Pending Register

// // Machine Counter/Timers
// reg [63:0] mcycle;     // Machine Cycle Counter
// reg [63:0] minstret;   // Machine Instructions-Retired Counter

// // Supervisor Mode
// reg [63:0] satp;       // Supervisor Address Translation and Protection Register

// // Debug Registers
// reg [63:0] tselect;    // Debug Trigger Select Register
// reg [63:0] tdata1;     // Debug Trigger Data Register 1

// //--------------------------------------------------------------------------
// // 2. Machine Information Registers (Read-Only Constants)
// //--------------------------------------------------------------------------
// wire [63:0] mvendorid; // Machine Vendor ID Register
// wire [63:0] marchid;   // Machine Architecture ID Register
// wire [63:0] mimpid;    // Machine Implementation ID Register
// wire [63:0] mhartid;   // Machine Hart ID Register (Hardware Thread ID)
// wire [63:0] mconfigptr;// Machine Configuration Pointer Register
// wire [63:0] misa;      // Machine ISA Register (Instruction Set Architecture)



// //instruction
// wire excption_instruction_address_misaligned  = xx; //id=0
// wire excption_instruction_access_fault        = xx; //id=1
// wire excption_instruction_illegal_instruction = xx; //id=2
// wire excption_breakpoint                      = xx; //id=3
// //load  
// wire excption_load_address_misaligned         = xx; //id=4
// wire excption_load_access_fault               = xx; //id=5
// //store
// wire excption_store_amo_address_misaligned    = xx; //id=6
// wire excption_store_amo_access_fault          = xx; //id=7
// //eacll
// wire excption_ecall_from_umode                = xx; //id=8
// wire excption_ecall_from_smode                = xx; //id=9
// wire excption_ecall_from_mmode                = xx; //id=11
// //page
// wire excption_instruction_page_fault          = xx; //id=12
// wire excption_load_page_fault                 = xx; //id=13
// wire excption_store_amo_page_fault            = xx; //id=15



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



// 2. 操作系统要做的事情
// 不归我管














// endmodule

// module csr(
//     input wire clk,
//     input wire rst
// );

// endmodule