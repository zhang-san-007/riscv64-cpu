# --- 基础路径定义 ---
SIM_HOME := $(abspath .)
BUILD_DIR := $(SIM_HOME)/build
OBJ_DIR := $(BUILD_DIR)/obj_dir
INC_DIR := $(SIM_HOME)/include
SRC_DIR := $(SIM_HOME)/src

# --- 1. 引入 Kconfig 配置逻辑 ---
# 必须先引入 Makefile.conf 以获得 CONFIG_xxx 变量
include Makefile.conf

# --- 核心变量定义 ---
TOPNAME := top_cpu
CPU_DIR := $(SIM_HOME)/IP/rv64-pipeline-cpu-2026-ready-valid
BIN := $(BUILD_DIR)/$(TOPNAME)

# --- 编译器设置 ---
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -j 8 -trace-fst -cc -O0 
VERILATOR_CFLAGS += --x-assign fast --x-initial fast --noassert
VERILATOR_CFLAGS += -I$(CPU_DIR) --top-module $(TOPNAME) --prefix npc

# --- 编译参数映射 ---
INC_PATH = $(INC_DIR) $(INC_DIR)/utils $(INC_DIR)/riscv $(INC_DIR)/difftest
INCFLAGS := $(addprefix -I, $(INC_PATH))

# 链接库与 CXX 标志
LDFLAGS += -lreadline -lhistory -ldl -pie $(shell llvm-config --libs)
CXXFLAGS += $(INCFLAGS) -DTOP_NAME=npc -fpermissive

# --- 源码扫描 ---
VSRCS = $(shell find $(abspath $(CPU_DIR)) -name "*.v" -o -name "*.sv")
CSRCS = $(shell find $(abspath $(SRC_DIR)) -name "*.c" -o -name "*.cpp" -o -name "*.cc")

# --- 颜色与图标定义 ---
BLUE   = \033[1;34m
GREEN  = \033[1;32m
PURPLE = \033[1;35m
CYAN   = \033[1;36m
YELLOW = \033[1;33m
RESET  = \033[0m
ROCKET = 🚀
CHECK  = ✅
BUILD  = 🛠️
RUN    = 🏃

# --- 构建规则 ---

default: $(BIN)

# 核心：二进制文件依赖于 $(AUTOCONF_H)，确保配置更改后自动触发重新编译
$(BIN): $(VSRCS) $(CSRCS) $(AUTOCONF_H)
	@echo "$(BLUE)$(BUILD) [1/2] Preparing build directory...$(RESET)"
	@mkdir -p $(BUILD_DIR)
	@rm -rf $(OBJ_DIR)
	@echo "$(PURPLE)$(ROCKET) [2/2] Starting Verilator compilation...$(RESET)"
	$(VERILATOR) $(VERILATOR_CFLAGS) $(VSRCS) $(CSRCS) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) \
		$(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))
	@echo "$(GREEN)$(CHECK) Build successful! Binary: $(BIN)$(RESET)"

# --- 运行逻辑 ---

# 示例：根据 Kconfig 中的配置动态增加运行参数
override ARGS ?= --log=$(SIM_HOME)/bin/npc-log.txt
override ARGS += --diff=$(SIM_HOME)/diff/riscv64-spike-so

ifeq ($(CONFIG_BATCH_MODE),y)
    override ARGS += --batch
endif

run: $(BIN)
	@echo "$(CYAN)$(RUN) Launching simulation...$(RESET)"
	@$(BIN) $(ARGS) $(IMAGE)

sim:
	@echo "$(BLUE)🌊 Opening GTKWave...$(RESET)"
	@gtkwave $(SIM_HOME)/waveform.fst

clean:
	@echo "$(YELLOW)🧹 Cleaning up build artifacts...$(RESET)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(AUTOCONF_H)
	@echo "$(GREEN)$(CHECK) Clean done.$(RESET)"

.PHONY: default all clean run sim menuconfig syncconfig