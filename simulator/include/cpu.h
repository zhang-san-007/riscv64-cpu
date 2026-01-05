#ifndef __CPU_CPU_H__
#define __CPU_CPU_H__

#include <common.h>
#include <debug.h>

typedef struct {
  u64 gpr[GPR_NUM];
  u64 pc;
  u64 csr[CSR_NUM];
} CPU_state;


#endif
