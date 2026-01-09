#ifndef __DECODE_H__
#define __DECODE_H__

#define GET_OPCODE(i) ((i) & 0x7f)
#define GET_FUNCT3(i) (((i) >> 12) & 0x7)
#define GET_RD(i)     (((i) >> 7) & 0x1f)
#define GET_CSR_ID(i) (((i) >> 20) & 0xfff)  // 指令[31:20] - CSR地址（12位）


#define op_load  0b0000011
#define op_store 0b0100011
#define op_csr   0b1110011
#define func3000 0b000
#define func3001 0b001
#define func3010 0b010


#endif