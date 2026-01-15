#include <cpu.h>
#include <cstdint>
#include <simulator_state.h>
#include <common.h>
#include <defs.h>

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <utils.h>



//只使用一次的指令追踪，这个
#define instr_max_size 128
void instr_trace(u64 pc, u32 instr) {
    char inst_str[instr_max_size];
    disassemble(inst_str,instr_max_size, pc, (u8 *)&instr, 8);
    printf("处理器执行了pc=[0x%lx]处的指令instr=[0x%08x], 其反汇编=[%s]\n", pc, instr, inst_str);
}

extern FILE *log_fp;
bool log_enable();

void instr_trace_log(u64 pc, u32 instr){
    char inst_str[instr_max_size];
    disassemble(inst_str,instr_max_size, pc, (u8 *)&instr, 8);
    if (log_enable()) {
        fprintf(log_fp, "处理器执行了pc=[0x%lx]处的指令instr=[0x%08x], 其反汇编=[%s]\n", pc, instr, inst_str);
        fflush(log_fp); // 非常重要：确保在报错或崩溃前日志已经刷入磁盘
    }
}



#define ITRACE_POOL_SIZE 20
#define INST_STR_MAX 128
typedef struct {
    u64 pc;
    u32 instr; 
} TraceEntry;

static TraceEntry itrace_pool[ITRACE_POOL_SIZE];
static int itrace_ptr = 0;      // 下一个写入位置
static bool pool_full = false;  // 标记是否已写满过一轮

void instr_itrace(u64 pc, u32 instr) {
//    mark_instr_executed(instr);
    itrace_pool[itrace_ptr].pc = pc;
    itrace_pool[itrace_ptr].instr = instr;
    itrace_ptr = (itrace_ptr + 1) % ITRACE_POOL_SIZE;
    if (itrace_ptr == 0) pool_full = true;
}



void instr_itrace_display() {    

    int total = pool_full ? ITRACE_POOL_SIZE : itrace_ptr;
    printf("\n%s ● " ANSI_BOLD "最近 %d 条指令 " ANSI_FG_RESET "(总计已执行: %" PRIu64 " 条, 不含 nop)\n",  ANSI_FG_CYAN, total, g_nr_guest_inst);    
    int i = pool_full ? itrace_ptr : 0;
    //执行count循环
    for (int count = 0; count < total; count++) {
        char inst_str[INST_STR_MAX];
        TraceEntry *e = &itrace_pool[i];

        disassemble(inst_str, INST_STR_MAX, e->pc, (uint8_t *)&e->instr, 4);
        int last_idx = (itrace_ptr + ITRACE_POOL_SIZE - 1) % ITRACE_POOL_SIZE;
        char current_flag = (i == last_idx) ? '>' : ' ';
        printf("%c [0x%016lx]: 0x%08x  %s\n", current_flag, e->pc, e->instr, inst_str);

        i = (i + 1) % ITRACE_POOL_SIZE;
    }
    if (total == 0) {
        printf(" (No instructions executed yet.)\n");
    }    
    printf("--- [ End of Trace ] ---\n");
}


// 1
// 2
// 3 
// 4
// 5
// 6 ----> pc记录下来， reg, csr, memory ---->spike[csr]
// 7 ----> 出错      



//1. 
//2. 实现那条指令
//3. 保存CPU状态，出错之前的那条指令
//4. xv6跑到哪了