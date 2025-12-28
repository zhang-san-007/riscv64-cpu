#ifndef __CPU_CPU_H__
#define __CPU_CPU_H__

#include <common.h>
#include <debug.h>

typedef struct {
  word_t  gpr[GPR_NUM];
  vaddr_t pc;
  word_t  csr[CSR_NUM];
} CPU_state;


#endif
