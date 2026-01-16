#include <common.h> //types.h

#include <sim_state.h>
#include <defs.h>
#include <debug.h>
#include <sys/types.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "verilated_fst_c.h"
#include <npc.h>
#include <defs.h>
#include <riscv/cpu.h>
#include <difftest/difftest.h>
#include <difftest/commit.h>

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)
#define MAX_INST_TO_PRINT 100
#define MAX_GUEST_INST 30000


//全局变量
difftest_t dut_diff;

extern uint8_t pmem[CONFIG_MSIZE];
extern CPU_state  cpu;
extern SIMState   sim_state;
static u64        g_timer = 0; // unit: us
static bool       g_print_step = false;



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
  memcpy(&cpu.csr[0], csr_ptr, 8 * 4096);
}


void npc_single_cycle() {
  dut.clk = 0;  
  dut.eval();   
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



void npc_init() {
  IFDEF(CONFIG_NPC_OPEN_SIM, npc_open_simulation());  
  npc_reset(1);  
  update_cpu_state(); //更新这个CPU状态，是为了后面同步给difftest

  printf("dut.commit_pc = %ld", dut.commit_pc);
    if(dut.cur_pc != 0x80000000){
    npc_close_simulation();
    printf("处理器的值目前为pc=0x%lx, 处理器初始化/复位之后, PC值应该为0x80000000\n", cpu.pc);
    printf("处理器初始化/复位的PC值不正确, 程序退出\n");
    exit(1);
  }
  Log("处理器初始化完毕");
}




void check_ebreak(const commit_t *commit){
  if(commit->instr == inst_ebreak){
    instr_trace(    commit->pc , commit->instr);
    printf("由于仿真框架将[ebreak]指令看作是程序结束的指令，执行[ebreak]指令之后，我们退出程序\n");
    sim_state.state = SIM_END;
  }

}

//si 1执行一条指令就确定是一次commit, 而不是多次clk
void execute(uint64_t n){
  for (   ;n > 0; n --) {
    CPU_state gold_cpu;
    memcpy(&gold_cpu, &cpu, sizeof(CPU_state));

    while(dut.commit != 1){      
      npc_single_cycle();
    }
    // get_commit_info(&dut_diff.commit, &dut);
    // get_decode_info(&dut_diff.decode, dut_diff.commit.instr);

    

    npc_single_cycle();                  
    update_cpu_state();
    // get_cpu_info  (&dut_diff.cpu, cpu);

    

    // if(inst_exec_one_million()){
    //   printf("已经执行了%ld条指令\n", g_nr_guest_inst);
    // }
    // IFDEF(CONFIG_TRACE_LOG, instr_trace_log(commit.pc, commit.instr));
    // IFDEF(CONFIG_ITRACE,    instr_itrace(commit.pc , commit.instr));
    // IFDEF(CONFIG_DIFFTEST,  difftest_step(&commit));  
    
  }
}

void statistic() {
  npc_close_simulation();
  #define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("你的处理器执行了" NUMBERIC_FMT "条指令(不含nop指令)", g_nr_guest_inst);
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

void sim_exit(const char *msg){
    npc_single_cycle();
    npc_close_simulation();
    Log("%s\n", msg);
    exit(1);
}