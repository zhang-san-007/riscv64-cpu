module csr(
    input  wire clk,
    input  wire rst,
    input  wire [63:0] rs1,
    input  wire [63:0] pc,

    output wire [63:0] csr
);
reg [63:0] mstatus; 
reg [63:0] mtvec;
reg [63:0] mcause;
reg [63:0] mepc;

//有关csr的指令
//csrrw : t  = CSRs[csr];  CSRs[csr] = x[rs1]; x[rd] = t;
//csrrs : t  = CSRs[csr];  CSRs[csr] = t | x[rs1]; x[rd] = t; 
//mret  : pc = CSRs[mepc]; CSRs[mstatus]修改(目前没写,只设置了修改pc)  
//ecall : [根据ysyx] mepc = pc; 设置mcause异常号,  设置mstatus

endmodule