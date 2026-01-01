#include <common.h>
#include <defs.h>
#include <debug.h>
#include <sys/types.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "verilated_fst_c.h"
#include <npc.h>
#include <simulator_state.h>
#include <common.h>
#include <defs.h>

extern CPU_state  cpu;
extern SIMState   sim_state;
uint64_t          g_nr_guest_inst = 0;
static uint64_t   g_timer = 0; // unit: us
static bool       g_print_step = false;
#define MAX_INST_TO_PRINT 100


static TOP_NAME dut;  			    //CPU
static VerilatedFstC *m_trace = NULL;  //仿真波形
static word_t sim_time = 0;			//时间
static word_t clk_count = 0;

void npc_open_simulation(){
  Verilated::traceEverOn(true);
  m_trace= new VerilatedFstC;
  dut.trace(m_trace, 5);
  m_trace->open("waveform.fst");
  Log("打开波形追踪(FST格式)");
}
void npc_close_simulation(){
  IFDEF(CONFIG_NPC_OPEN_SIM, 	m_trace->close());
  IFDEF(CONFIG_NPC_OPEN_SIM, Log("波形追踪已完成,可以通过make sim命令查看"));
}


void update_cpu_state(){
  cpu.pc = dut.cur_pc;
  memcpy(&cpu.gpr[0], reg_ptr, 8 * 32);
//  memcpy(&cpu.csr[0], csr_ptr, 8 * 4096);
}
void npc_single_cycle() {
  dut.clk = 0;  dut.eval();   
  IFDEF(CONFIG_NPC_OPEN_SIM,   m_trace->dump(sim_time++));
  dut.clk = 1;  dut.eval(); 
  IFDEF(CONFIG_NPC_OPEN_SIM,   m_trace->dump(sim_time++));
  clk_count++;
}
void npc_reset(int n) {
  dut.rst = 1;
  while (n -- > 0) npc_single_cycle();
  dut.rst = 0;
}
typedef struct {
    uint32_t id;
    const char *name;
} csr_map_t;

// 定义你关注的 CSR 列表
const csr_map_t target_csrs[] = {
    // Machine Information
    {0xf11, "mvendorid"}, {0xf12, "marchid" }, {0xf13, "mimpid"    }, {0xf14, "mhartid"}, {0xf15, "mconfigptr"},
    // Machine Trap Setup
    {0x300, "mstatus"  }, {0x301, "misa"    }, {0x302, "medeleg"   }, {0x303, "mideleg"},
    {0x304, "mie"      }, {0x305, "mtvec"   }, {0x306, "mcounteren"},
    // Machine Trap Handling
    {0x340, "mscratch" }, {0x341, "mepc"    }, {0x342, "mcause"    }, {0x343, "mtval"}, {0x344, "mip"},
    // Machine Memory Protection (PMP)
    {0x3a0, "pmpcfg0"  }, {0x3a1, "pmpcfg1"}, {0x3a2,  "pmpcfg2"},
    // ... 可以按需添加更多 PMP 寄存器 ...
    // Others
    {0xb00, "mcycle"},    {0xb02, "minstret"},
    {0x7a0, "tselect"},   {0x7a1, "tdata1"},
    {0x180, "satp"}
};

// 计算数组长度
#define TARGET_CSR_CNT (sizeof(target_csrs) / sizeof(csr_map_t))

void print_cpu(FILE *out) {
    if (out == NULL) out = stdout;

    fprintf(out, "\n" "---------------- CPU State Dump ----------------\n");
    fprintf(out, "PC: 0x%016lx\n", cpu.pc);

    // 1. 打印通用寄存器 (保持原样或微调)
    fprintf(out, "\n[General Purpose Registers]\n");
    for (int i = 0; i < 32; ++i) {
        fprintf(out, "x%-2d: 0x%016lx%s", i, cpu.gpr[i], (i % 4 == 3) ? "\n" : "  ");
    }

    // 2. 只打印关注的 CSR
    fprintf(out, "\n[Selected Control and Status Registers]\n");
    for (int i = 0; i < TARGET_CSR_CNT; ++i) {
        uint32_t id = target_csrs[i].id;
        const char *name = target_csrs[i].name;
        
        // 假设 cpu.csr 是一个通过 ID 索引的数组，如 cpu.csr[4096]
        // 如果你的存储方式不同，请调整索引逻辑
        fprintf(out, "%-10s[0x%03x]: 0x%016lx", name, id, cpu.csr[id]);
        
        // 每行打印 2 个，保持整齐
        fprintf(out, (i % 2 == 1) ? "\n" : "    ");
    }
    
    // 如果最后一行没换行，补一个
    if (TARGET_CSR_CNT % 2 != 0) fprintf(out, "\n");
    
    fprintf(out, "------------------------------------------------\n");
}
void npc_init() {
  IFDEF(CONFIG_NPC_OPEN_SIM, npc_open_simulation());  
  npc_reset(1);
  update_cpu_state();
//  print_cpu(NULL);

  if(cpu.pc != 0x80000000){
    npc_close_simulation();
    printf("处理器的值目前为pc=0x%lx, 处理器初始化/复位之后, PC值应该为0x80000000\n", cpu.pc);
    printf("处理器初始化/复位的PC值不正确, 程序退出\n");
    exit(1);
  }
  Log("处理器初始化完毕");
}


commit_t commit;

void get_commit_info(){
    commit.pc         = dut.commit_pc;
    commit.next_pc    = dut.commit_next_pc;
    commit.instr      = dut.commit_instr;
    commit.mem_addr   = dut.commit_mem_addr;
    commit.mem_rdata  = dut.commit_mem_rdata;
    commit.mem_wdata  = dut.commit_mem_wdata;
}

//si 1执行一条指令就确定是一次commit, 而不是多次clk
void execute(uint64_t n){
  for (   ;n > 0; n --) {
    while(dut.commit != 1){      
      npc_single_cycle();
    }
    get_commit_info();
    if(commit.instr == 0x00100073){
      instr_trace(    commit.pc , commit.instr);
      printf("由于仿真框架将[ebreak]指令看作是程序结束的指令，执行[ebreak]指令之后，我们退出程序\n");
      sim_state.state = SIM_END;
      break;
    }
    npc_single_cycle();                             
    update_cpu_state();
    g_nr_guest_inst++;
    IFDEF(CONFIG_ITRACE,   instr_trace(commit.pc , commit.instr));
    IFDEF(CONFIG_DIFFTEST, difftest_step(&commit));  
  }
}

void statistic() {
  npc_close_simulation();
  #define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("你的处理器执行了" NUMBERIC_FMT "条指令(包含流水线冲刷等情况)", g_nr_guest_inst);
  Log("你的处理器执行了" NUMBERIC_FMT "个时钟周期", clk_count);
  if (g_timer > 0) {
    Log("你处理器的执行频率是" NUMBERIC_FMT " instr/s", g_nr_guest_inst * 1000000 / g_timer);
  }else{
    Log("Finish running in less than 1 us and can not calculate the simulation frequency");
  }
}

void cpu_exec(uint64_t n) {
  g_print_step = (n < MAX_INST_TO_PRINT); 
  switch (sim_state.state) {
    case SIM_END: 
    case SIM_ABORT:
      printf("Program execution has ended. To restart the program, exit  and run again.\n");
      return;
    default: sim_state.state = SIM_RUNNING;
  }
  uint64_t timer_start = get_time();
  execute(n); 

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (sim_state.state) {
    case SIM_RUNNING: sim_state.state = SIM_STOP; break;
    case SIM_END: 
    case SIM_ABORT:
      Log("SIM: %s at pc = [pc值信息有误,待修复]" FMT_WORD,
          (sim_state.state == SIM_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
          (sim_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
          ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          sim_state.halt_pc);
    case SIM_QUIT: 
        statistic();
  }
}
//我想的就是复位的时候