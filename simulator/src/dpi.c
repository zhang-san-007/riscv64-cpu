#include <common.h>
#include <cstdint>
#include <cstdio>
#include <defs.h>
#include "verilated_dpi.h" 
extern CPU_state cpu; 
// extern u64 *reg_ptr;
// extern u64 *csr_ptr;


extern "C" void dpi_ebreak(){
	printf("下一个要执行的指令是ebreak\n");
	SIMTRAP(0x80000000, 0);
}
extern "C" uint32_t dpi_instr_mem_read(uint64_t addr){
	//地址在物理内存中
	if(addr >= CONFIG_MBASE && addr < CONFIG_MBASE + CONFIG_MSIZE){
		addr = addr & ~0x3u;
		IFDEF(,Log("[fetch]addr = %lx,intsr = %lx",addr,pmem_read(addr, 4)));
		return pmem_read(addr, 4);
	}
	else{

		npc_close_simulation();
		Log("[dpi_instr_mem_read]访问的地址是%lx，超过物理内存界限\n", addr);
		exit(1);
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
  reg_ptr = (u64 *)(((VerilatedDpiOpenVar*)r)->datap());
}


extern "C" void dpi_read_csrfile(const svOpenArrayHandle r) {
  csr_ptr = (u64 *)(((VerilatedDpiOpenVar*)r)->datap());
}




