class ddr5_dram_seqr extends uvm_sequencer#(ddr5_dram_trans);
  
  `uvm_component_utils(ddr5_dram_seqr)
  
  function new(string name="ddr5_dram_seqr",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
endclass

