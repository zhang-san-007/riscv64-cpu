module icache(
    input wire 		     clk,
	input wire 		     rst,
    input wire           bubble,
    input wire           stall,
	input wire [63:0]    pc,
    output reg [31:0]    icache_o_instr
);
localparam cache_size       = 8192;                                     //8192字节，是8KB
localparam addr_size        = 64;                                       //地址是64bit
localparam way_size         = 2;                                        //二路组相连
localparam cache_data       = 16;                                       //cache_line每个数据大小是16zi
localparam num_sets         = cache_size / way_size / cache_data;       //一共256组
localparam index_size       = $clog2(num_sets);                         //256组需要8bit进行索引
localparam block_offset     = $clog2(cache_data);                       //16字节需要4bit进行索引
localparam tag_size         = addr_size - index_size - block_offset;    //64bit地址中剩下的数据全部是tag
localparam cache_line_size  = 1 + tag_size + cache_data * 8;            //181

//  reg [63:0] pc           =  [tag(63:12), index(11:4),  offset(3:0)];
//  reg [180:0] cache_line  =  [valid(180), tag(179:128), cache_data(127:0)];
reg [cache_line_size - 1: 0] cache [num_sets-1:0][way_size-1:0]; // [Valid bit, Tag, Data]
import "DPI-C" function     int dpi_instr_mem_read (input longint addr);
wire [127:0] memory_data = {dpi_instr_mem_read(pc+12), dpi_instr_mem_read(pc+8), 
                            dpi_instr_mem_read(pc+4),  dpi_instr_mem_read(pc)};
wire [51:0] pc_tag             =   pc[63:12];
wire [7 :0] pc_index           =   pc[11: 4];
wire [3 :0] pc_offset          =   pc[3 : 0];
wire cache_hit_index0          =    cache[pc_index][0][179:128] == pc_tag && cache[pc_index][0][180] == 1'b1;
wire cache_hit_index1          =    cache[pc_index][1][179:128] == pc_tag && cache[pc_index][1][180] == 1'b1;
wire cache_miss                =   ~(cache_hit_index0 || cache_hit_index1);


always @(posedge clk) begin
    if(rst || bubble) begin
        icache_o_instr <= 32'd0;
    end
    else if(~stall)begin    
        if(cache_hit_index0) begin
            icache_o_instr <=   pc_offset == 4'd0  ? cache[pc_index][0][31: 0] :             
                                pc_offset == 4'd4  ? cache[pc_index][0][63:32] :
                                pc_offset == 4'd8  ? cache[pc_index][0][95:64] :
                                pc_offset == 4'd12 ? cache[pc_index][0][127:96]: icache_o_instr;
        end
        else if(cache_hit_index1) begin
            icache_o_instr <=   pc_offset == 4'd0  ? cache[pc_index][1][31: 0] :             
                                pc_offset == 4'd4  ? cache[pc_index][1][63:32] :
                                pc_offset == 4'd8  ? cache[pc_index][1][95:64] :
                                pc_offset == 4'd12 ? cache[pc_index][1][127:96]: icache_o_instr;
        end
        else if(cache_miss) begin
            integer rand_val;
            rand_val = $random % 2; // 生成0或1
            cache[pc_index][rand_val][180]     <= 1'b1;
            cache[pc_index][rand_val][179:128] <= pc_tag;
            cache[pc_index][rand_val][127:0]   <= memory_data;
            icache_o_instr <=    pc_offset == 4'd0  ? memory_data[31: 0] :             
                                 pc_offset == 4'd4  ? memory_data[63:32] :
                                 pc_offset == 4'd8  ? memory_data[95:64] :
                                 pc_offset == 4'd12 ? memory_data[127:96]: icache_o_instr;            
        end
    end
end
endmodule