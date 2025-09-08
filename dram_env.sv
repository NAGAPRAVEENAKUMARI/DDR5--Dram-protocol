// class ddr5_dram_env extends uvm_env;
  
//   `uvm_component_utils(ddr5_dram_env)
 
//   ddr5_dram_agent agent;
  
//   function new(string name="ddr5_dram_env",uvm_component parent);
//     super.new(name,parent);
//   endfunction
  
//   function void build_phase (uvm_phase phase);
//     super.build_phase(phase);
//     agent=ddr5_dram_agent::type_id::create("agent",this);
//   endfunction
  
// endclass
class ddr5_dram_env extends uvm_env;
  `uvm_component_utils(ddr5_dram_env)
 
  ddr5_dram_agent agent;
 // ddr5_dram_scoreboard scb;
  
  function new(string name="ddr5_dram_env", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = ddr5_dram_agent::type_id::create("agent", this);
    //scb = ddr5_dram_scoreboard::type_id::create("scb", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //agent.mon_ap.connect(scb.item_imp);
  endfunction
endclass