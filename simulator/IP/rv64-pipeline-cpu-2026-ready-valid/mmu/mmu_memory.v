// `include "define.v"

// module new_memory(
//     input  wire         clk,
//     input  wire         rst,
//     input  wire         regM_i_valid,          
//     input  wire [63:0]  decode_i_csr_satp,
//     input  wire [63:0]  regM_i_pc,
//     input  wire [19:0]  regM_i_amo_info,
//     input  wire [10:0]  regM_i_load_store_info,
//     input  wire [63:0]  regM_i_alu_result,
//     input  wire [63:0]  regM_i_regdata2,
//     input  wire [63:0]  regM_i_regdata1,

//     output wire         memory_o_ready_go,     
//     output wire [63:0]  memory_o_mem_rdata
// );

//     import "DPI-C" function void    dpi_mem_write(input longint addr, input longint data, int len, input longint pc);
//     import "DPI-C" function longint dpi_mem_read (input longint addr, input int len,               input longint pc);

//     wire inst_amoswapw = regM_i_amo_info[17];
//     wire [63:0] mem_vaddr = (inst_amoswapw) ? regM_i_regdata1 : regM_i_alu_result;
//     wire [63:0] mem_wdata = regM_i_regdata2;

//     wire inst_lb  = regM_i_load_store_info[10];
//     wire inst_lh  = regM_i_load_store_info[9 ];
//     wire inst_lw  = regM_i_load_store_info[8 ];
//     wire inst_ld  = regM_i_load_store_info[7 ];
//     wire inst_lbu = regM_i_load_store_info[6 ];
//     wire inst_lhu = regM_i_load_store_info[5 ];
//     wire inst_lwu = regM_i_load_store_info[4 ];

//     wire inst_sb  = regM_i_load_store_info[3];
//     wire inst_sh  = regM_i_load_store_info[2];
//     wire inst_sw  = regM_i_load_store_info[1];
//     wire inst_sd  = regM_i_load_store_info[0];

//     wire inst_load  = (inst_lb | inst_lh | inst_lw | inst_ld | inst_lbu | inst_lhu | inst_lwu);
//     wire inst_store = (inst_sb | inst_sh | inst_sw | inst_sd);
//     wire inst_amo   = (inst_amoswapw);

//     wire        mmu_o_ready;
//     wire [63:0] mmu_o_pa;
//     wire        mmu_o_valid;
    
//     wire        mem_valid = regM_i_valid && (inst_load || inst_store || inst_amo);
//     wire [63:0] mem_o_paddr = mmu_o_pa;

//     mmu u_mmu(
//         .clk             ( clk              ),
//         .rst             ( rst              ),
//         .va              ( mem_vaddr        ),
//         .va_i_valid      ( mem_valid        ), 
//         .satp            ( decode_i_csr_satp),
//         .mmu_o_ready     ( mmu_o_ready      ),
//         .mmu_o_pa        ( mmu_o_pa         ),
//         .mmu_o_valid     ( mmu_o_valid      )
//     );

//     assign memory_o_ready_go = (mem_valid) ? (mmu_o_valid && mmu_o_ready) : 1'b1;

//     wire [63:0] mem_rdata = (inst_load && regM_i_valid && memory_o_ready_go) ?  dpi_mem_read(mem_o_paddr, 8, regM_i_pc) : 64'd0;

//     assign memory_o_mem_rdata = (inst_lb)   ? { {56{mem_rdata[7]}},  mem_rdata[7 :0]} :
//                                 (inst_lh)   ? { {48{mem_rdata[15]}}, mem_rdata[15:0]} :  
//                                 (inst_lw)   ? { {32{mem_rdata[31]}}, mem_rdata[31:0]} :
//                                 (inst_ld)   ? mem_rdata :
//                                 (inst_lbu)  ? { 56'd0, mem_rdata[7 :0]} :
//                                 (inst_lhu)  ? { 48'd0, mem_rdata[15:0]} :
//                                 (inst_lwu)  ? { 32'd0, mem_rdata[31:0]} : 
//                                 (inst_amoswapw) ? { {32{mem_rdata[31]}}, mem_rdata[31:0]} : 64'd0;

//     wire [31:0] mem_wlen = (inst_sb) ? 32'd1 :
//                            (inst_sh) ? 32'd2 :
//                            (inst_sw) ? 32'd4 :
//                            (inst_sd) ? 32'd8 : 
//                            (inst_amoswapw) ? 32'd4 : 32'd0;

//     always @(posedge clk) begin
//         if (!rst && regM_i_valid && memory_o_ready_go && (inst_store || inst_amo)) begin
//             dpi_mem_write(mem_o_paddr, mem_wdata, mem_wlen, regM_i_pc);
//         end
//     end

// endmodule