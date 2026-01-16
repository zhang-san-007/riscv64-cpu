#ifndef __COMMIT__H__
#define __COMMIT__H__

#include <types.h>

typedef struct commit_t{
  u64 pc;
  u64 next_pc;
  u64 instr;

  u64 mem_addr;
  u64 mem_rdata;
  u64 mem_wdata;
}commit_t;

#endif