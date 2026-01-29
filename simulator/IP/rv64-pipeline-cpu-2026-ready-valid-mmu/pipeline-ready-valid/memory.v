module memory(
    input  wire  clk,
    input  wire  rst,
    input  wire  [63:0]   decode_i_csr_satp,
    input  wire  [63:0]   regM_i_pc,     //for debug
    input  wire  [19:0]   regM_i_amo_info,
    input  wire  [10:0]   regM_i_load_store_info,
    input  wire  [63:0]   regM_i_alu_result,
    input  wire  [63:0]   regM_i_regdata2,
    input  wire  [63:0]   regM_i_regdata1,

//    output wire           memory_o_mem_rw
    output wire  [63:0]   memory_o_mem_rdata
);

import "DPI-C" function void    dpi_mem_write(input longint addr, input longint data, int len, input longint pc);
import "DPI-C" function longint dpi_mem_read (input longint addr, input int len,               input longint pc);

wire inst_lrw      = regM_i_amo_info[19];
wire inst_scw      = regM_i_amo_info[18];
wire inst_amoswapw = regM_i_amo_info[17];
wire inst_amoaddw  = regM_i_amo_info[16];
wire inst_amoxorw  = regM_i_amo_info[15];
wire inst_amoorw   = regM_i_amo_info[14];
wire inst_amominw  = regM_i_amo_info[13];
wire inst_amomaxw  = regM_i_amo_info[12];
wire inst_amominuw = regM_i_amo_info[11];
wire inst_amomaxuw = regM_i_amo_info[10];
wire inst_lrd      = regM_i_amo_info[9];
wire inst_scd      = regM_i_amo_info[8];
wire inst_amoswapd = regM_i_amo_info[7];
wire inst_amoaddd  = regM_i_amo_info[6];
wire inst_amoxord  = regM_i_amo_info[5];
wire inst_amoord   = regM_i_amo_info[4];
wire inst_amomind  = regM_i_amo_info[3];
wire inst_amomaxd  = regM_i_amo_info[2];
wire inst_amominud = regM_i_amo_info[1];
wire inst_amomaxud = regM_i_amo_info[0];


wire [63:0] mem_addr  = (inst_amoswapw) ? regM_i_regdata1 : regM_i_alu_result;
wire [63:0] mem_wdata = regM_i_regdata2;

wire inst_lb    =   regM_i_load_store_info[10];
wire inst_lh    =   regM_i_load_store_info[9 ];
wire inst_lw    =   regM_i_load_store_info[8 ];
wire inst_ld    =   regM_i_load_store_info[7 ];
wire inst_lbu   =   regM_i_load_store_info[6 ];
wire inst_lhu   =   regM_i_load_store_info[5 ];
wire inst_lwu   =   regM_i_load_store_info[4 ];

wire inst_sb    =   regM_i_load_store_info[3];
wire inst_sh    =   regM_i_load_store_info[2];
wire inst_sw    =   regM_i_load_store_info[1];
wire inst_sd    =   regM_i_load_store_info[0];

wire inst_load  =   inst_lb | inst_lh | inst_lw | inst_ld | inst_lbu | inst_lhu | inst_lwu;
wire inst_store =   inst_sb | inst_sh | inst_sw | inst_sd;

// reg [63:0] mem_rdata;
// always @(*) begin
//     if(inst_load)begin
//         mem_rdata = dpi_mem_read(mem_addr, 8, regM_i_pc);
//     end
//     else begin
//         mem_rdata = 64'd0;
//     end
// end

wire [63:0] mem_rdata = (inst_load) ? dpi_mem_read(mem_addr, 8, regM_i_pc) : 64'd0;


assign memory_o_mem_rdata  = (inst_lb)          ?     { {56{mem_rdata[7]}},    mem_rdata[7 :0]}   :
                             (inst_lh)          ?     { {48{mem_rdata[15]}},   mem_rdata[15:0]}   :  
                             (inst_lw)          ?     { {32{mem_rdata[31]}},   mem_rdata[31:0]}   :
                             (inst_ld)          ?     {                        mem_rdata[63:0]}   :
                             (inst_lbu)         ?     { 56'd0,                 mem_rdata[7 :0]}   :
                             (inst_lhu)         ?     { 48'd0,                 mem_rdata[15:0]}   :
                             (inst_lwu)         ?     { 32'd0,                 mem_rdata[31:0]}   : 
                             (inst_amoswapw)    ?     { {32{mem_rdata[31]}},   mem_rdata[31:0]}   : 64'd0;
                             
wire [31:0] mem_wlen = (inst_sb) ? 32'd1:
                       (inst_sh) ? 32'd2:
                       (inst_sw) ? 32'd4:
                       (inst_sd) ? 32'd8: 
                       (inst_amoswapw) ? 32'd4 : 32'd0;

always @(posedge clk) begin
	if(inst_store | inst_amoswapw) begin
		dpi_mem_write(mem_addr, mem_wdata, mem_wlen, regM_i_pc);
	end
end
endmodule