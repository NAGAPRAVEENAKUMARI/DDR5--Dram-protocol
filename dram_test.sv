// class ddr5_dram_test extends uvm_test;
  
// `uvm_component_utils(ddr5_dram_test)
  
//   ddr5_dram_env env;
//   ddr5_dram_seqs seqs;
  
//   function new(string name="ddr5_dram_test",uvm_component parent);
//     super.new(name,parent);
//   endfunction 
  
//   function void build_phase (uvm_phase phase);
//     super.build_phase(phase);
//     env=ddr5_dram_env::type_id::create("env",this);
//   endfunction
  
//     function void end_of_elaboration_phase(uvm_phase phase);
//     super.end_of_elaboration_phase(phase);
//     uvm_top.print_topology;
//   endfunction
 
  
//   task run_phase(uvm_phase phase);
//     seqs=ddr5_dram_seqs::type_id::create("seqs");
//     phase.raise_objection(this);
//     seqs.start(env.agent.seqr);
//     phase.drop_objection(this);
//   endtask
// endclass

class ddr5_dram_test extends uvm_test;
  `uvm_component_utils(ddr5_dram_test)
  
  ddr5_dram_env env;
  ddr5_dram_seqs seqs;
  
  function new(string name="ddr5_dram_test", uvm_component parent);
    super.new(name, parent);
  endfunction 
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ddr5_dram_env::type_id::create("env", this);
    seqs = ddr5_dram_seqs::type_id::create("seqs", this);
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // Start the sequence
    seqs.start(env.agent.seqr);
    
    // Add some delay to allow monitoring to complete
    #100;
    
    phase.drop_objection(this);
  endtask
endclass

  