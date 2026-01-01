#include <common.h>
#include <cstdint>
#include <cstdio>
#include <defs.h>
#include "verilated_dpi.h" 


extern "C" void dpi_ebreak(){
	printf("下一个要执行的指令是ebreak\n");
	SIMTRAP(0x80000000, 0);
}

extern "C" uint32_t dpi_instr_mem_read(uint64_t addr){
  if(addr >= CONFIG_MBASE && addr < CONFIG_MBASE + CONFIG_MSIZE){
		addr = addr & ~0x3u;
	
		IFDEF(,Log("[fetch]addr = %lx,intsr = %lx",addr,pmem_read(addr, 4)));
		return pmem_read(addr, 4);
	}else{
      return 0;
   }
}


extern "C" uint64_t dpi_mem_read(uint64_t addr, int len) {
    if (addr == 0) return 0;
    return pmem_read(addr, 8); 
}
//store指令
extern "C" void dpi_mem_write(uint64_t addr, uint64_t data, int len, uint32_t instr, uint64_t pc){
	if(addr == CONFIG_SERIAL_MMIO){
		char ch = data;
		printf("%c", ch);
		fflush(stdout);
	}else{
		pmem_write(addr, len, data);
	}
}


extern "C" void dpi_read_regfile(const svOpenArrayHandle r) {
  reg_ptr = (word_t *)(((VerilatedDpiOpenVar*)r)->datap());
}

extern "C" void dpi_read_csrfile(const svOpenArrayHandle r){
	csr_ptr = (word_t *)(((VerilatedDpiOpenVar*)r)->datap());
}


