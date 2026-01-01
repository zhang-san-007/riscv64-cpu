#include <cpu.h>
#include <cstdint>
#include <simulator_state.h>
#include <common.h>
#include <defs.h>

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>




//只使用一次的指令追踪，这个
#define instr_max_size 128
void instr_trace(u64 pc, u32 instr) {
    char inst_str[instr_max_size];
    disassemble(inst_str,instr_max_size, pc, (u8 *)&instr, 8);
    printf("处理器执行了pc=[0x%lx]处的指令instr=[0x%08x], 其反汇编=[%s]\n", pc, instr, inst_str);
}

void instr_trace_log(u64 pc, u32 instr) {
    char inst_str[instr_max_size];
    disassemble(inst_str,instr_max_size, pc, (u8 *)&instr, 8);
    printf("处理器执行了pc=[0x%lx]处的指令instr=[0x%08x], 其反汇编=[%s]\n", pc, instr, inst_str);
}




#define ITRACE_POOL_SIZE 20
#define INST_STR_MAX 128
// 1. 定义环形缓冲区条目
typedef struct {
    u64 pc;
    u32 instr; // 使用 u32 存储指令，符合 RISC-V 32位指令规格
} TraceEntry;

// 2. 静态缓冲区及状态变量
static TraceEntry itrace_pool[ITRACE_POOL_SIZE];
static int itrace_ptr = 0;      // 下一个写入位置
static bool pool_full = false;  // 标记是否已写满过一轮

/**
 * 记录函数：仅保存原始数值
 */


void instr_itrace(u64 pc, u32 instr) {
    itrace_pool[itrace_ptr].pc = pc;
    itrace_pool[itrace_ptr].instr = instr;
    
    itrace_ptr = (itrace_ptr + 1) % ITRACE_POOL_SIZE;
    if (itrace_ptr == 0) pool_full = true;
}

/**
 * 打印函数：展示最近执行的指令
 */
void instr_itrace_display() {
// 颜色定义 (ANSI Escape Codes)
    #define ANSI_FG_CYAN  "\33[1;36m"
    #define ANSI_FG_YELLOW "\33[1;33m"
    #define ANSI_FG_RESET  "\33[0m"

    printf("\n" ANSI_FG_CYAN "======================== [ Trace Summary ] ========================" ANSI_FG_RESET "\n");
    printf("  " ANSI_FG_YELLOW "Total Executed" ANSI_FG_RESET " : %'lu instructions (inc. flushes/nops)\n", g_nr_guest_inst);
    printf("  " ANSI_FG_YELLOW "Trace Window" ANSI_FG_RESET "   : Last %d instructions\n", ITRACE_POOL_SIZE);
    printf(ANSI_FG_CYAN "-------------------------------------------------------------------" ANSI_FG_RESET "\n");
    
    // 1. 确定实际需要打印的条数
    // 如果还没填满，则只打印到 itrace_ptr 为止；如果满了，就打印整个数组
    int total = pool_full ? ITRACE_POOL_SIZE : itrace_ptr;
    
    // 2. 确定从哪里开始读（最旧的那一条）
    // 如果满了，下一条要写的位置 (itrace_ptr) 就是当前最旧的位置
    // 如果没满，最旧的位置就是索引 0
    int i = pool_full ? itrace_ptr : 0;
    for (int count = 0; count < total; count++) {
        char inst_str[INST_STR_MAX];
        TraceEntry *e = &itrace_pool[i];
        // 反汇编处理
        disassemble(inst_str, INST_STR_MAX, e->pc, (uint8_t *)&e->instr, 4);
        // 3. 标记出最后执行的一条（即写入指针的前一个位置）
        // 逻辑：(itrace_ptr - 1 + SIZE) % SIZE
        int last_idx = (itrace_ptr + ITRACE_POOL_SIZE - 1) % ITRACE_POOL_SIZE;
        char current_flag = (i == last_idx) ? '>' : ' ';
        printf("%c [0x%016lx]: 0x%08x  %s\n", current_flag, e->pc, e->instr, inst_str);
        // 4. 索引向后移动，实现环形遍历
        i = (i + 1) % ITRACE_POOL_SIZE;
    }
    if (total == 0) {
        printf(" (No instructions executed yet.)\n");
    }    
    printf("--- [ End of Trace ] ---\n");
}