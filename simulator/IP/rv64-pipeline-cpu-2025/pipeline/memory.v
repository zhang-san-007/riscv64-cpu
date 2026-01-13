module memory(
    input wire clk,
    input wire rst,
    input wire  [63:0]   regM_i_pc,     //for debug
    input wire  [19:0]   regM_i_amo_info,
    input wire  [10:0]   regM_i_load_store_info,
    input wire  [63:0]   regM_i_alu_result,
    input wire  [63:0]   regM_i_regdata2,
    input wire  [63:0]   regM_i_regdata1,
    output wire [63:0]   memory_o_mem_rdata
);

import "DPI-C" function void    dpi_mem_write(input longint addr, input longint data, int len, input longint pc);
import "DPI-C" function longint dpi_mem_read (input longint addr, input int len,               input longint pc);

wire inst_amoswapw = regM_i_amo_info[17];

// assign decode_o_amo_info = {
// 	inst_lrw		,	//19
// 	inst_scw	  	,	//18
// 	inst_amoswapw	,	//17
// 	inst_amoaddw	,	//16
// 	inst_amoxorw	,	//15
// 	inst_amoorw		,	//14
// 	inst_amominw	,	//13
// 	inst_amomaxw	,	//12
// 	inst_amominuw	,	//11
// 	inst_amomaxuw	,	//10
// 	inst_lrd		,	//9
// 	inst_scd		,	//8
// 	inst_amoswapd	,	//7
// 	inst_amoaddd	,	//6
// 	inst_amoxord	,	//5
// 	inst_amoord		,	//4
// 	inst_amomind	,	//3
// 	inst_amomaxd	,	//2
// 	inst_amominud	,	//1
// 	inst_amomaxud		//0
// };

wire [63:0] mem_addr  = (inst_amoswapw) ? regM_i_regdata1 : regM_i_alu_result;
wire [63:0] mem_wdata = regM_i_regdata2;




// regdata1作为内存地址
// 1. 把内存地址里面的读出来的数据rd
// 2. 把regdata2写入该地址里面去


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

reg [63:0] mem_rdata;
always @(*) begin
    if(inst_load)begin
        mem_rdata = dpi_mem_read(mem_addr, 8, regM_i_pc);
    end
    else begin
        mem_rdata = 64'd0;
    end
end
assign memory_o_mem_rdata  = (inst_lb)          ?     { {56{mem_rdata[7]}},    mem_rdata[7 :0]}   :
                             (inst_lh)          ?     { {48{mem_rdata[15]}},   mem_rdata[15:0]}   :  
                             (inst_lw)          ?     { {32{mem_rdata[31]}},   mem_rdata[31:0]}   :
                             (inst_ld)          ?     {                        mem_rdata[63:0]}   :
                             (inst_lbu)         ?     { 56'd0,                 mem_rdata[7 :0]}   :
                             (inst_lhu)         ?     { 48'd0,                 mem_rdata[15:0]}   :
                             (inst_lwu)         ?     { 32'd0,                 mem_rdata[31:0]}   : 
                             (inst_amoswapw)    ?     { {32{mem_rdata[31]}},   mem_rdata[31:0]}   : 64'd0;
                             

//要写入的数据
always @(posedge clk) begin
	if(inst_sb) begin
		dpi_mem_write(mem_addr, mem_wdata, 1, regM_i_pc);
	end
	else if(inst_sh) begin
		dpi_mem_write(mem_addr, mem_wdata, 2, regM_i_pc);		
	end
	else if(inst_sw) begin
		dpi_mem_write(mem_addr, mem_wdata, 4, regM_i_pc);				
	end
    else if(inst_sd) begin
        dpi_mem_write(mem_addr, mem_wdata, 8, regM_i_pc);		
    end
    else if(inst_amoswapw) begin
        dpi_mem_write(mem_addr, mem_wdata, 4, regM_i_pc);
    end
end
endmodule