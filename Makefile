#### create make file
QUESTA_PATH = /mnt/c/questasim64_10.7c/win64

VLOG = $(QUESTA_PATH)/vlog.exe
VSIM = $(QUESTA_PATH)/vsim.exe
VLIB = $(QUESTA_PATH)/vlib.exe

UVM_LIB_DIR = /mnt/c/questasim64_10.7c/verilog_src/uvm-1.2

UVM_INCLUDE = +incdir+$(UVM_LIB_DIR)

TEST_DIR = ./DDR5_PROTOCOL
WORK_DIR = work
LOG_DIR  = logs

TESTCASES_FILE = testcases.txt

TESTBENCH = $(TEST_DIR)/testbench.sv

INC = +incdir+$(TEST_DIR)

TOP_MODULE = tb

VSIM_OPT =+access -sva -sv_seed random 

all: compile simulate
compile:
	@echo "Creating work library..."
	@mkdir -p $(WORK_DIR)
	$(VLIB) $(WORK_DIR)
	@echo "compiling testbench files..."
	$(VLOG) -work $(WORK_DIR) $(UVM_INCLUDE) $(TESTBENCH)

generate_run_do:
	@echo "Generating run.do far testcase: $(TESTNAME).."
	@echo "log -r /*" >run.do
	@echo "run -all" >> run.do
	@echo "quit" >>run.do

simulate:
	@echo "Running simulation for test case :$(TESTNAME).."
	@mkdir -p $(LOG_DIR) 
	$(VSIM)  -do run.do $(VSIM_OPT) -wlf $(LOG_DIR)/$(TESTNAME).wlf -l $(LOG_DIR)/$(TESTNAME)_sim.log -coverage \
	$(WORK_DIR).$(TOP_MODULE) +UVM_TESTNAME=$(TESTNAME)
	
