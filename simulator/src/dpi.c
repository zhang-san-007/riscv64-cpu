#include <common.h>
#include <cstdint>
#include <cstdio>
#include <defs.h>
#include "verilated_dpi.h" 
extern CPU_state cpu; 
extern u64 *reg_ptr;


extern "C" void dpi_ebreak(){
	printf("下一个要执行的指令是ebreak\n");
	SIMTRAP(0x80000000, 0);
}
extern "C" uint32_t dpi_instr_mem_read(uint64_t addr){
	if(addr >= CONFIG_MBASE && addr < CONFIG_MBASE + CONFIG_MSIZE){
		addr = addr & ~0x3u;
		return pmem_read(addr, 4);
	}

	else{
		printf("访问的地址是%lx，超过物理内存界限\n", addr);
		return 0x0;
    }
}

extern "C" uint64_t dpi_mem_read(uint64_t addr, int len, u64 pc) {
    if (addr >= CONFIG_MBASE && addr < (uint64_t)CONFIG_MBASE + CONFIG_MSIZE) {
        return pmem_read(addr, len);
    } else {
        //针对于
        
        if(pc == 0x0000000080000cb4 && addr == 0x0000000010000005){
          return 32;
        }
        else if (addr != 0) {
            fprintf(stderr, "[DPI mem_read error] Invalid address: 0x%016lx, len: %d, pc: 0x%016lx\n", addr, len, pc);
        }
        return 0;
    }
}

extern "C" void dpi_mem_write(uint64_t addr, uint64_t data, int len, u64 pc) {
    if (addr == CONFIG_SERIAL_MMIO) {
      char ch = data;
      printf("%c", ch);
      fflush(stdout);
    } else if (addr >= CONFIG_MBASE && addr < (uint64_t)CONFIG_MBASE + CONFIG_MSIZE) {
		//
		pmem_write(addr, len, data);
    } else {
        // 非法写入尝试
      fprintf(stderr, "[DPI mem_write error] Invalid address: 0x%016lx, data: 0x%016lx, len: %d, pc: 0x%016lx\n", addr, data, len, pc);
    }
}

extern "C" void dpi_read_regfile(const svOpenArrayHandle r) {
  reg_ptr = (u64 *)(((VerilatedDpiOpenVar*)r)->datap());
}

extern "C" void dpi_read_csrfile(const svOpenArrayHandle r) {
  csr_ptr = (u64 *)(((VerilatedDpiOpenVar*)r)->datap());
}




