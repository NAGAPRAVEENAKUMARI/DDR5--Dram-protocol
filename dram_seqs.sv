class ddr5_dram_seqs extends uvm_sequence#(ddr5_dram_trans);
  
  `uvm_object_utils(ddr5_dram_seqs)
  
  function new(string name="ddr5_dram_seqs");
    super.new(name);
  endfunction 
  
  task body;
   // repeat(10)
     // begin
    req=ddr5_dram_trans::type_id::create("req");
    
     repeat(10)
       begin
        start_item(req);
        req.randomize();  `uvm_info(get_full_name,$sformatf("req=%0p",req),UVM_NONE);
finish_item(req);
      end
  endtask
endclass
