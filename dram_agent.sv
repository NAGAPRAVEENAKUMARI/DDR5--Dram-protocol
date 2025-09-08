// class ddr5_dram_agent extends uvm_agent;
  
//   `uvm_component_utils(ddr5_dram_agent)
  
//   ddr5_dram_seqr seqr;
//   ddr5_dram_driver drv;
//   ddr5_dram_monitor mon;
  
//   function new(string name ="ddr5_dram_agent",uvm_component parent);
//     super.new(name,parent);
//   endfunction
  
//   function void build_phase(uvm_phase phase);
//     super.build_phase (phase);
    
//     seqr=ddr5_dram_seqr::type_id::create("seqr",this);
//     drv=ddr5_dram_driver::type_id::create("drv",this);
//     mon=ddr5_dram_monitor::type_id::create("mon", this);
//   endfunction
  
//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
    
//     drv.seq_item_port.connect(seqr.seq_item_export);
//   endfunction
  
// endclass
class ddr5_dram_agent extends uvm_agent;
  `uvm_component_utils(ddr5_dram_agent)
  
  ddr5_dram_seqr seqr;
  ddr5_dram_driver drv;
 // ddr5_dram_monitor mon;
  
  uvm_analysis_port#(ddr5_dram_trans) mon_ap;
  
  function new(string name ="ddr5_dram_agent", uvm_component parent);
    super.new(name, parent);
   // mon_ap = new("mon_ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    seqr = ddr5_dram_seqr::type_id::create("seqr", this);
    drv = ddr5_dram_driver::type_id::create("drv", this);
   // mon = ddr5_dram_monitor::type_id::create("mon", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    drv.seq_item_port.connect(seqr.seq_item_export);
    //mon.mon_ap.connect(mon_ap);
  endfunction
endclass
    