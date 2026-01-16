#ifndef __DECODE_H__
#define __DECODE_H__
#include <types.h>

#define GET_OPCODE(i)   ((i) & 0x7f)            // [6:0]
#define GET_RD(i)       (((i) >> 7) & 0x1f)     // [11:7] 目标寄存器
#define GET_RS1(i)      (((i) >> 15) & 0x1f)    // [19:15] 源寄存器 1
#define GET_RS2(i)      (((i) >> 20) & 0x1f)    // [24:20] 源寄存器 2

#define GET_CSR_ID(i) (((i) >> 20) & 0xfff)  // 指令[31:20] - CSR地址（12位）

#define GET_FUNC3(i)   (((i) >> 12) & 0x7)     // [14:12]
#define GET_FUNC7(i)   (((i) >> 25) & 0x7f)    // [31:25]

#define op_load  0b0000011
#define op_store 0b0100011
#define op_csr   0b1110011


#define func3000 0b000
#define func3001 0b001
#define func3010 0b010
#define inst_ebreak 0x00100073


typedef struct {
    u32 opcode;     //GET_OPCODE
    u32 csr_id;     //GET_CSR_ID
    u32 func3;      //GET_FUNCT3
    u32 func7;      //GET_FUNCT7
    u32 rd    ;     //GET_RD
}decode_t;


#endif