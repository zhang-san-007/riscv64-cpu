
#ifndef __DIFFTEST__H__
#define __DIFFTEST__H__

#include <riscv.h>
#include <types.h>
#include <commit.h>

typedef struct {
    CPU_state cpu;      // 架构寄存器状态 (GPR, CSR, PC)
    commit_t  commit;   // 当前提交的指令详情
    decode_t  decode;   // 指令的解码信息（方便快速定位指令类型）
    uint64_t  timestamp; // 可选：记录当前是第几条指令 (g_nr_guest_inst)
} difftest_t;


#endif

//difftest.h 作为difftest文件夹下的头文件
//common.h   作为utils文件夹下的头文件
//riscv.h    作为riscv文件夹下的头文件