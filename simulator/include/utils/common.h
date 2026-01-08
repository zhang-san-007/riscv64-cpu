#ifndef __COMMON_H__
#define __COMMON_H__
#include <macro.h>
#include <autoconf.h>
#include <sim_difftest.h>
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

enum csr_id{
    //u_mode
    cycle = 0xc00, timer = 0xc01, instret = 0xc02,
    //s_mode
    sstatus = 0x100, sie = 0x104, stvec = 0x105, scounteren = 0x106,
    sscratch = 0x140, sepc = 0x141, scause = 0x142, stval = 0x143, sip = 0x144,
    satp = 0x180,
    //m_mode
    mvendorid = 0xf11, marchid = 0xf12, mimpid = 0xf13, mhartid = 0xf14, mconfigptr = 0xf15,
    mstatus = 0x300, misa = 0x301, medeleg = 0x302, mideleg = 0x303, mie = 0x304, mtvec = 0x305, mcounteren = 0x306,
    mscratch = 0x340, mepc = 0x341, mcause = 0x342, mtval = 0x343, mip = 0x344,
    mcycle = 0xb00, minstret = 0xb02, tselect = 0x7a0, tdata1 = 0x7a1,

    //pmp
    pmpcfg0 = 0x3a0, pmpcfg1 = 0x3a1, pmpcfg2 = 0x3a2, pmpcfg3 = 0x3a3,
    pmpaddr0 = 0x3b0, pmpaddr1 = 0x3b1, pmpaddr2 = 0x3b2, pmpaddr3 = 0x3b3,
    pmpaddr4 = 0x3b4, pmpaddr5 = 0x3b5, pmpaddr6 = 0x3b6, pmpaddr7 = 0x3b7,
    pmpaddr8 = 0x3b8, pmpaddr9 = 0x3b9, pmpaddr10 = 0x3ba, pmpaddr11 = 0x3bb,
    pmpaddr12 = 0x3bc, pmpaddr13 = 0x3bd, pmpaddr14 = 0x3be, pmpaddr15 = 0x3bf
};
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
