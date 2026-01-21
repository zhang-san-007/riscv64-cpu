// module MemoryManagementUnit (
//     input  wire        clock,                   //时钟
//     input  wire        reset,                   //复位

//     //下面这三个信号是翻译配置
//     input  wire        translation_enable,      //是否允许翻译
//     input  wire [38:0] virtual_address,         //虚拟地址
//     input  wire [43:0] satp_root_page_frame,    //stap的页表起始地址

//     //任务握手，MMU可以工作且CPU发起请求
//     input  wire        request_valid,           //CPU告诉MMU，我有一个虚拟地址要转换，你准备开工吧，这是一个valid信号
//     output reg         request_ready,           //MMU告诉CPU，我现在能够工作进行虚实地址转换了

//     //这个是MMU翻译完成之后给CPU的结果交付
//     output reg  [55:0] physical_address,        //物理地址
//     output reg         address_valid,           //这个信号是说MMU的地址翻译结果出来了

//     //异常反馈
//     output reg         page_fault,              //页故障，翻译并不是每次都能成功的


//     //下面这四个信号是相互配合的，是因为MMU内部没有页表，MMU需要从内存里面去取数据
//     input  wire [63:0] memory_read_data,        //MMU遍历页表的时候，要从内存里面读数据，这个是内存返回的数据
//     input  wire        memory_response_valid    //这个表示内存返回的数据是否有效
//     output reg  [55:0] memory_access_address,   //MMU内部没有页表，需要从内存里面去访问，所以有一个内存访问地址
//     output reg         memory_read_enable,      //MMU内部没有页表，需要从内存里面去访问，所以有一个读内存_en
// );

//     localparam STATE_IDLE         = 3'd0;   //state_idle,idle是空闲的空置的，表明MMU是空闲的，可以工作
//     localparam STATE_WALK_LEVEL2  = 3'd1;   //state_walk_level2，地址翻译的第一步
//     localparam STATE_WALK_LEVEL1  = 3'd2;   //state_walk_level1，地址翻译的第二步
//     localparam STATE_WALK_LEVEL0  = 3'd3;   //state_walk_levle0，地址翻译的第三步
//     localparam STATE_DONE         = 3'd4;   //state_done       ，地址翻译的最终点，无论是成功翻译还是有错误。

//     reg [2:0] current_state;        //现在的状态，000，可以表示八个状态，涵盖了上面的5个状态。

//     // 64bit VA = { [63:39],  [38:30],  [29:21],  [20:12],  [11:0] }
//     //               符号扩    VPN[2]    VPN[1]    VPN[0]    Offset
//     wire [8:0] vpn [2:0];           //vpn, vpn0,vpn1,vpn2       vpn是va里面的来的
//     assign vpn[2] = virtual_address[38:30];
//     assign vpn[1] = virtual_address[29:21];
//     assign vpn[0] = virtual_address[20:12];
//     wire [11:0] page_offset = virtual_address[11:0];    //页表偏移量


//     // 64bit PTE = { [63:61], [60:54],   [53:28], [27:19], [18:10], [9:8], [7], [6], [5], [4], [3], [2], [1], [0] }
//     //                PBMT     Reserved   PPN[2]   PPN[1]   PPN[0]   RSW    D    A    G    U    X    W    R    V

//     wire pte_valid = memory_read_data[0];           //V     从内存里面读出来的pte
//     wire pte_read  = memory_read_data[1];           //R
//     wire pte_write = memory_read_data[2];           //W
//     wire pte_exec  = memory_read_data[3];           //X
//     wire [43:0] pte_ppn = memory_read_data[53:10];  //pte

//     //表示该pte是否为终点
//     //如果R=0, W=0, X=0，硬件认为这个PTE是一个指针，指向下一级页表
//     //如果R, W, X至少有一个为1，硬件认为
//     //R=1, 这是一个可读的数据页
//     //X=1，这是一个包含可执行代码的指令页
//     //在RISC-V中只要可写，就一定可读，只要可W，那么就一定可R。
//     //即只要W=1，那么R一定等于1，R不能等于0.
//     //但是R=1是，W不一定=1。
//     wire is_leaf_pte = (pte_read | pte_write | pte_exec); //   

//     always @(posedge clock or posedge reset) begin
//         if (reset) begin
//             current_state <= STATE_IDLE;    //MMU属于空闲状态。
//             request_ready <= 1'b1;          //MMU现在是空闲的，可以工作了。
//             address_valid <= 1'b0;          //MMU的翻译结果还没有出来，pa是无效的。
//             page_fault    <= 1'b0;          //清除之前的页故障标志。
//             physical_address   <= 56'b0;    //物理地址为0

//             memory_read_enable <= 1'b0;     //不读内存
//             memory_access_address <= 56'b0; //访问内存的地址为0
//         end else begin
//             case (current_state)
//                 STATE_IDLE: begin
//                     address_valid <= 1'b0;      //这个表明mmu给出去的物理地址是无效的
//                     page_fault    <= 1'b0;      //页表不故障。
//                     if (request_valid) begin    //如果有地址翻译的请求
//                         //MMU不工作
//                         if (!translation_enable) begin
//                             physical_address <= {17'b0, virtual_address};
//                             address_valid    <= 1'b1;
//                         //MMU开始工作
//                         end else begin
//                             request_ready <= 1'b0;      //表明MMU繁忙，不接受新的请求
//                             current_state <= STATE_WALK_LEVEL2; //开始第一个地址工作
//                             memory_access_address <= {satp_root_page_frame, 12'b0} + {32'b0, vpn[2], 3'b0};   //准备读页表内存
//                             memory_read_enable    <= 1'b1;      //准备读页表内存
//                         end
//                     end
//                 end

//                 STATE_WALK_LEVEL2: begin
//                     //如果内存返回的数据有效
//                     if (memory_response_valid) begin
//                         //如果pte无效
//                         if (!pte_valid) begin
//                             page_fault    <= 1'b1;          
//                             current_state <= STATE_DONE; //翻译结束
//                         //如果是叶子结点 
//                         end else if (is_leaf_pte) begin
//                             //构造物理地址
//                             physical_address <= {pte_ppn[43:18], virtual_address[29:0]};
//                             current_state    <= STATE_DONE;//翻译结束
//                         //继续向下翻译
//                         end else begin
//                             //构建访问页表的地址
//                             memory_access_address <= {pte_ppn, 12'b0} + {32'b0, vpn[1], 3'b0};
//                             current_state <= STATE_WALK_LEVEL1; //开始下一级翻译
//                         end
//                     end
//                 end

//                 STATE_WALK_LEVEL1: begin
//                     if (memory_response_valid) begin
//                         if (!pte_valid) begin
//                             page_fault    <= 1'b1;
//                             current_state <= STATE_DONE;
//                         end else if (is_leaf_pte) begin
//                             physical_address <= {pte_ppn[43:9], virtual_address[20:0]};
//                             current_state    <= STATE_DONE;
//                         end else begin
//                             memory_access_address <= {pte_ppn, 12'b0} + {32'b0, vpn[0], 3'b0};
//                             current_state <= STATE_WALK_LEVEL0;
//                         end
//                     end
//                 end

//                 STATE_WALK_LEVEL0: begin
//                     if (memory_response_valid) begin
//                         if (!pte_valid || !is_leaf_pte) begin
//                             page_fault    <= 1'b1;
//                         end else begin
//                             physical_address <= {pte_ppn, page_offset};
//                         end
//                         current_state <= STATE_DONE;
//                     end
//                 end

//                 STATE_DONE: begin
//                     //处理结束标志
//                     memory_read_enable <= 1'b0;
//                     address_valid      <= 1'b1;
//                     request_ready      <= 1'b1;
//                     current_state      <= STATE_IDLE;
//                 end

//                 default: current_state <= STATE_IDLE;
//             endcase
//         end
//     end
// endmodule