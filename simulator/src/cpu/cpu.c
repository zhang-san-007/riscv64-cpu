#include <common.h>
#include <cstdint>
#include <defs.h>
#include <cpu.h>

CPU_state cpu; 
uint32_t *reg_ptr = NULL;

const char *regs[] = {
  "$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
  "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
  "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

int check_reg_idx(int idx) {
  assert(idx >= 0 && idx < GPR_NUM);
  return idx;
}
int check_csr_idx(int idx){
  assert(idx >= 0 && idx < CSR_NUM);
  return idx;
}
#define gpr(idx) (cpu.gpr[check_reg_idx(idx)])
#define pc_self  (cpu.pc)
#define csr(idx) (cpu.gpr[check_csr_idx(idx)])

const char* reg_name(int idx) {
  extern const char* regs[];
  return regs[check_reg_idx(idx)];
}




