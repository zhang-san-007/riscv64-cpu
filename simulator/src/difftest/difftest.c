
#include "simulator_state.h"
#include <dlfcn.h>
#include <utils.h>
#include <common.h>
#include <defs.h>
#include <debug.h>
#include <cpu.h>


void (*ref_difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
#ifdef CONFIG_DIFFTEST
extern CPU_state cpu;
extern SIMState sim_state;

static bool is_skip_ref = false;
static int skip_dut_nr_inst = 0;
void difftest_skip_ref() {
  is_skip_ref = true;
  skip_dut_nr_inst = 0;
}

void difftest_skip_dut(int nr_ref, int nr_dut) {
  skip_dut_nr_inst += nr_dut;
  while (nr_ref -- > 0) {
    ref_difftest_exec(1);
  }
}

void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);
  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  ref_difftest_memcpy =  (void (*)(paddr_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);

  ref_difftest_exec =  (void (*)(uint64_t))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_raise_intr = (void (*)(uint64_t))dlsym(handle, "difftest_raise_intr");
  assert(ref_difftest_raise_intr);

  void (*ref_difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_init(port); //do nothing

  printf("img_size=%ld\n",img_size);
  printf("RESET_VECTOR=%lx\n", RESET_VECTOR);
//  printf("pmem=%p\n", pmem);
  ref_difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_size, DIFFTEST_TO_REF);


  ref_difftest_regcpy(&cpu, DIFFTEST_TO_REF);  //cpu-->REF
  Log("Difftest已打开");
}

static void checkregs(CPU_state *ref, vaddr_t pc, paddr_t next_pc) {  
  extern void npc_single_cycle();
  if(next_pc != ref->pc){
      printf("\n%-9s\n", ANSI_FMT(str(DIFFTEST), ANSI_FG_YELLOW ANSI_BG_RED));
      printf("[NPC] Difftest Error: 在执行完pc=[%lx]指令之后,DUT和REF的状态出现不一致:\n", pc);
      printf("[参考处理器.pc]=0x%-9lx\n[你的处理器.pc]=0x%-9lx\n", ref->pc, next_pc);
      printf("\n-----------以下是所有寄存器数据：\n");
      for(int i = 0;  i < 32; ++i){
        printf("[参考处理器.%-3s]=0x%-9lx,\t [你的处理器.%-3s]=0x%-9lx\n", reg_name(i), ref->gpr[i], reg_name(i), gpr(i));
      }
      //delay one clk
      npc_single_cycle();
      npc_close_simulation();
      printf("下面将会产生一个makefile错误m暂时不用担心\n");
      exit(1);
  }

  for(int i = 0; i < 32; ++i){
    if(ref->gpr[i] != cpu.gpr[i]){
      printf("\n%-9s\n", ANSI_FMT(str(DIFFTEST), ANSI_FG_YELLOW ANSI_BG_RED));  
      printf("[NPC] Difftest Error: 在执行完pc=[%lx]指令之后,DUT和REF状态出现不一致:\n", pc);
      printf("[参考处理器.%s]=0x%lx, [你的处理器.%s]=0x%lx\n", reg_name(i), ref->gpr[i], reg_name(i), gpr(i));
      printf("\n-----------以下是所有寄存器数据：\n");
      for(int i = 0;  i < 32; ++i){
        printf("[参考处理器.%-3s]=0x%-11lx, [你的处理器.%-3s]=0x%-11lx\n", reg_name(i), ref->gpr[i], reg_name(i), gpr(i));
      }
      //delay one clk
      npc_single_cycle();
      npc_close_simulation();
      printf("下面将会产生一个makefile错误,暂时不用担心\n");
      exit(1);
    }
  }
}


//difftest_step
void difftest_step(paddr_t pc, paddr_t next_pc) {
  CPU_state ref_r;
  ref_difftest_exec(1);
  ref_difftest_regcpy(&ref_r, DIFFTEST_TO_DUT); //把REF的内容
  checkregs(&ref_r, pc, next_pc);
}

#else
void init_difftest(char *ref_so_file, long img_size, int port) { }
#endif
