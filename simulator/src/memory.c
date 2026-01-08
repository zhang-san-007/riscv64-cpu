#include "cpu.h"
#include <common.h>
#include <debug.h>
#include <defs.h>


uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {}; 


void init_mem() {
#if defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
  Log("物理内存区域为 [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}
//8000effc          ->         0000effc + pmem
//ffffffff80007ff4  ->ffffffff_00007ff4 + pmem  (pmem最大就是128MB)

//fetch(pc)--->


uint8_t* guest_to_host(paddr_t paddr) { 
  return pmem + paddr - CONFIG_MBASE; 
}

static inline word_t host_read(void *addr, int len) {
  switch (len) {
    case 1: return *(uint8_t  *)addr;
    case 2: return *(uint16_t *)addr;
    case 4: return *(uint32_t *)addr;
    case 8: return *(uint64_t *)addr;
    default: assert(0);
  }
}
static inline void host_write(void *addr, int len, word_t data) {
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    case 8: *(uint64_t *)addr = data; return;
    default: assert(0);
  }
}
static inline bool in_pmem(paddr_t addr) {
  return addr >= CONFIG_MBASE && addr <= CONFIG_MBASE + CONFIG_MSIZE;
}

extern CPU_state cpu;
word_t pmem_read(paddr_t addr, int len){
  return host_read(guest_to_host(addr), len);
}
void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}
static void out_of_bound(paddr_t addr) {
  panic("in[npc] address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

word_t paddr_read(paddr_t addr, int len){
  IFDEF(CONFIG_INS_TRACE,Log("[read]addr = 0x%lx, len = %x",addr,len));

  if(likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  IFDEF(CONFIG_INS_TRACE,Log("[write]addr = 0x%lx, len = %x",addr,len));

  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}



//pmem_read
//p
