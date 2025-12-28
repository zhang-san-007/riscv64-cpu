module memory
#(parameter WIDTH=64, LS_SIZE=11)
(
    input wire  clk,
    input wire  rst,
    input wire  [LS_SIZE-1:0]   regM_load_store_info,
    input wire  [WIDTH-1:0]   regM_alu_result,
    input wire  [WIDTH-1:0]   regM_regdata2,
    output wire [WIDTH-1:0]   memory_memdata
);
import "DPI-C" function void    dpi_mem_write(input longint addr, input longint data, int len);
import "DPI-C" function longint dpi_mem_read (input longint addr, input int len);

wire [WIDTH-1:0] mem_addr  = regM_alu_result;
wire [WIDTH-1:0] mem_wdata = regM_regdata2;

wire inst_lb    =   regM_load_store_info[LS_SIZE-1];
wire inst_lh    =   regM_load_store_info[9];
wire inst_lw    =   regM_load_store_info[8];
wire inst_ld    =   regM_load_store_info[7];
wire inst_lbu   =   regM_load_store_info[6];
wire inst_lhu   =   regM_load_store_info[5];
wire inst_lwu   =   regM_load_store_info[4];
wire inst_sb    =   regM_load_store_info[3];
wire inst_sh    =   regM_load_store_info[2];
wire inst_sw    =   regM_load_store_info[1];
wire inst_sd    =   regM_load_store_info[0];

wire inst_load  =   inst_lb | inst_lh | inst_lw | inst_ld | inst_lbu | inst_lhu | inst_lwu;
wire inst_store =   inst_sb | inst_sh | inst_sw | inst_sd;

reg [WIDTH-1:0] mem_rdata;
always @(*) begin
    if(inst_load)begin
        mem_rdata = dpi_mem_read(mem_addr, 8);
    end
    else begin
        mem_rdata = 64'd0;
    end
end
assign memory_memdata  = (inst_lb)  ?       { {56{mem_rdata[7]}},    mem_rdata[7 :0]}   :
                           (inst_lh)  ?     { {48{mem_rdata[15]}},   mem_rdata[15:0]}   :  
                           (inst_lw)  ?     { {32{mem_rdata[31]}},   mem_rdata[31:0]}   :
                           (inst_ld)  ?     {                        mem_rdata[WIDTH-1:0]}   :
                           (inst_lbu) ?     { 56'd0,                 mem_rdata[7 :0]}   :
                           (inst_lhu) ?     { 48'd0,                 mem_rdata[15:0]}   :
                           (inst_lwu) ?     { 32'd0,                 mem_rdata[31:0]}   : 64'd0;

//要写入的数据
always @(posedge clk) begin
	if(inst_sb) begin
		dpi_mem_write(mem_addr, mem_wdata, 1);
	end
	else if(inst_sh) begin
		dpi_mem_write(mem_addr, mem_wdata, 2);		
	end
	else if(inst_sw) begin
		dpi_mem_write(mem_addr, mem_wdata, 4);				
	end
    else if(inst_sd) begin
        dpi_mem_write(mem_addr, mem_wdata, 8);		
    end
end
endmodule