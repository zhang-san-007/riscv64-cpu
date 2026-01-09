#ifndef __COMMON_H__
#define __COMMON_H__
#include <macro.h>
#include <autoconf.h>
#include <sim_difftest.h>
#include <csr.h>

//C-Standard-File
#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <autoconf.h>
#define __GUEST_ISA__ riscv64

typedef uint64_t  word_t;
typedef  int64_t sword_t;
typedef word_t   vaddr_t;
typedef word_t   paddr_t;
typedef  word_t     pa_t;
typedef  word_t     va_t;

typedef uint64_t     u64;
typedef uint32_t     u32;
typedef uint16_t     u16;
typedef uint8_t      u8;
typedef  int64_t     i64;
typedef  int32_t     i32;
typedef  int16_t     i16;
typedef   int8_t     i8;

#define FMT_WORD  "0x%16" PRIx64
#define FMT_PADDR "0x%16" PRIx64

#define PMEM_LEFT  ((paddr_t)CONFIG_MBASE)
#define PMEM_RIGHT ((paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1)
#define RESET_VECTOR (PMEM_LEFT + CONFIG_PC_RESET_OFFSET)

extern u64 *reg_ptr;
extern u64 *csr_ptr;

#define GPR_NUM 32
#define CSR_NUM 4096
enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };
enum { SIM_RUNNING, SIM_STOP, SIM_END, SIM_ABORT, SIM_QUIT };


//commit
typedef struct commit_t{
  u64 pc;
  u64 next_pc;
  u64 instr;

  u64 mem_addr;
  u64 mem_rdata;
  u64 mem_wdata;
}commit_t;

//g_nr_guest_inst
extern u64 g_nr_guest_inst;
#endif
