// class ddr5_dram_driver extends uvm_driver#(ddr5_dram_trans);
//   `uvm_component_utils(ddr5_dram_driver)
  
//   virtual ddr5_dram_if vif;
//   localparam int POWER_ON_DELAY_VPP = 10;
//   localparam int POWER_ON_DELAY_VDD = 8;
//   localparam int CS_INIT_DELAY = 210;
//   localparam int CS_HIGH_DELAY1 = 14;
//   localparam int CS_LOW_DELAY1 = 1;
//   localparam int CS_LOW_DELAY2 = 3;
//   localparam int MRW_CMD_DELAY = 7;
//   localparam int WRITE_LATENCY = 18;
//   localparam int READ_LATENCY = 20;
//   localparam int WRITE_READ_GAP = 16;
//   localparam int REFRESH_INTERVAL = 4; // Refresh every 4 operations

//   function new(string name = "ddr5_dram_driver", uvm_component parent);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if (!uvm_config_db#(virtual ddr5_dram_if)::get(this, "", "vif", vif))
//       `uvm_fatal(get_full_name(), "Virtual interface not set via config DB")
//   endfunction

//   task run_phase(uvm_phase phase);
//     super.run_phase(phase);
//     forever begin
//       seq_item_port.get_next_item(req);
//       execute_transaction(req);
//       seq_item_port.item_done();
//     end
//  endtask

//   task execute_transaction(ddr5_dram_trans xtn);
//     fork
//       initialize_power();
//       chipselect_n(); 
//     join
//     send_mode_registers(xtn);
//     activate_row(xtn);
//     write_data_burst(xtn); 
// for (int i = 0; i < 10; i++) begin
//   ddr5_dram_trans temp_xtn;
//   temp_xtn = ddr5_dram_trans::type_id::create("temp_xtn");

//   if (!temp_xtn.randomize()) begin
//     `uvm_error(get_full_name(), "Randomization failed")
//   end
//  activate_row(temp_xtn);
//   read_data_burst(temp_xtn);
// end
// refresh_all();
//   endtask
//   task initialize_power();
//     #POWER_ON_DELAY_VPP; vif.vpp <= 1;
//     #POWER_ON_DELAY_VDD; vif.vdd <= 1;
//   endtask
   
//   task chipselect_n();
//     vif.ca <= 14'h3FFF;   // 16383 inn decimal
//     #CS_INIT_DELAY;  
//     vif.cs_n <= 0;
//     #CS_HIGH_DELAY1;
//     vif.cs_n <= 1;
//     vif.ca <= 14'b1;
//     #CS_LOW_DELAY1;  vif.cs_n <= 0;
//     vif.ca <= 14'b0000_0000_1111_11;  // 14'h03F → 63 (dec)
//     #CS_LOW_DELAY2; 
//     vif.ca <= 14'h3FFF;
//     vif.cs_n <= 1;
//     @(posedge vif.ck_t)  
//     vif.cs_n <= 0;
//   endtask
    
//   // Mode register writes
//     task send_mode_registers(ddr5_dram_trans xtn);
//       send_mrw(14'b00_0000_0000_0101, xtn.m_0);     // 14'h005 → 5 (dec)
//       send_mrw(14'b0_0000_0010_00101, xtn.m_2);     // 14'h025 → 37 (dec)
//       send_mrw(14'b00_0000_1000_0101, xtn.m_8);     // 14'h085 → 133 (dec)
//     `uvm_info(get_full_name(), "Mode Registers Configured", UVM_LOW)
//   endtask
    
//   task send_mrw(bit [13:0] opcode, bit [7:0] modereg);
//     vif.cs_n <= 1'b0; 
//     vif.ca <= opcode;
//     wait_clk_pos(); 
//     delay_cycles(MRW_CMD_DELAY);
//     vif.cs_n <= 1;
//     vif.ca <= {6'b111111, modereg};
//     wait_clk_pos();
//     wait_clk_neg();  
//     vif.cs_n <= 1;
//   endtask

//     task activate_row( ddr5_dram_trans xtn); 
//     wait_clk_neg(); 
//     vif.cs_n <= 0; 
//       vif.ca <= {3'b000,xtn.bankgroup,xtn.bankaddr,xtn.rowaddr,2'b00}; // 14'h94C → 2380 (dec)
//     wait_clk_pos();
//     wait_clk_neg(); 
//     vif.cs_n <= 1;  
//     vif.ca <= 14'b10000010100001; // 14'h20A1 → 8353 (dec)
//     wait_clk_pos();  
//     vif.cs_n <= 1;
//   endtask
    
//     //////////////////WRITE ////////////////////
    
//   task write_data_burst(ddr5_dram_trans xtn);
//     send_write_cmd(xtn);
//     delay_cycles(WRITE_LATENCY);
//     drive_preamble(xtn.wr_pre); 
    
//     for (int i = 0; i < 8; i++) begin
//       wait_clk_pos();  
//       vif.dqs_t <= 1;
//       vif.dq <= xtn.write_data[i*2]; 
//       wait_clk_neg();  
//       vif.dqs_t <= 0;
//       vif.dq <= xtn.write_data[i*2 + 1];  
//     end
   
// drive_postamble(xtn.wr_post); 
//     vif.dqs_t <= 0; 
//     vif.dq <= 16'b0;
//     delay_cycles(WRITE_READ_GAP);
//   endtask

//     task send_write_cmd(ddr5_dram_trans xtn);  
//     wait_clk_neg();   
//     vif.cs_n <= 0; 
//     vif.ca <= {3'b000,xtn.bankgroup,1'b0,xtn.bankaddr,5'b01101};  // 14'h316D → 12653 (dec)
//     wait_clk_pos();
//     wait_clk_neg();   
//     vif.cs_n <= 1; 
//     vif.ca <= 14'b1000_0000_1111_00; // 14'h203C → 8316 (dec)
//     wait_clk_pos();  
//     wait_clk_neg();
//     vif.cs_n <= 1; 
//     vif.ca <= 14'h3FFF;
//   endtask
 
//   task read_data_burst(ddr5_dram_trans xtn);
//   send_read_cmd(xtn);
//   delay_cycles(READ_LATENCY);
//   drive_preamble(xtn.rd_pre); 
//  fork
//       begin
//         for (int i = 0; i < 8; i++) begin
//           @(posedge vif.dqs_t);
//           vif.dq= xtn.read_data[i*2] ; 
//           @(negedge vif.dqs_t);
//           vif.dq = xtn.read_data[i*2+1] ; 
//         end
//       end
//     join_none

//   drive_postamble(xtn.rd_post);  
//   vif.dqs_t <= 0; 
//   vif.dq <= 16'b0;
// endtask


//     task send_read_cmd(ddr5_dram_trans xtn);
//     wait_clk_neg();
//     wait_clk_pos();
//     vif.cs_n <= 0;
//     vif.ca <= { 3'b111,xtn.bankgroup,xtn.bankaddr,1'b1,5'b11101}; //
//     wait_clk_pos(); 
//     vif.ca <= { 1'b1,4'b0000,9'b0000_111010};
//     wait_clk_pos();  
//     vif.cs_n <= 1; 
//   endtask 
    
   
// //////////// REFRESH ALL  ///////////////
//     task refresh_all();
//       `uvm_info(get_full_name(), "Sending REFab (Refresh All) command", UVM_LOW)
//      // vif.cs_n< = 0;  vif.ca <=14'b000_0111_1100_10;
//        wait_clk_neg();
//       vif.cs_n <= 1'b0; 
//        vif.ca <= 14'b0_1100_1000_0000_0;  // 14'h1900 → 6400 (dec)
//       wait_clk_pos();
//        wait_clk_neg();
//       vif.cs_n <= 1'b1;  
//        vif.ca <= 14'h3FFF;   // 16383 (dec)
//       delay_cycles(16);  
//       endtask
    
//   task delay_cycles(int count);
//     repeat(count) @(posedge vif.ck_t);
//   endtask

//   task wait_clk_pos();
//     @(posedge vif.ck_t);
//   endtask

//   task wait_clk_neg();
//     @(negedge vif.ck_t);
//   endtask
    
//   task toggle_cs_n(bit val);
//     vif.cs_n <= val;
//     #1;
//   endtask
    
//   task drive_preamble(bit pattern[]);
//     for (int i = 0; i < pattern.size(); i += 2) begin
//       wait_clk_pos(); 
//       vif.dqs_t <= pattern[i];
//       wait_clk_neg(); 
//       vif.dqs_t <= pattern[i+1];
//     end
//   endtask
    
//   task drive_postamble(bit pattern[]);
//     wait_clk_pos(); 
//     vif.dqs_t <= pattern[0];
//     wait_clk_neg(); 
//     vif.dqs_t <= pattern[1];
//     vif.dqs_t <= 0;
//     vif.dq <= 16'b0;
//   endtask
// endclass

class ddr5_dram_driver extends uvm_driver#(ddr5_dram_trans);
  `uvm_component_utils(ddr5_dram_driver)
  
  virtual ddr5_dram_if vif;
  // Local parameters for timing delays
  localparam int POWER_ON_DELAY_VPP = 10;
  localparam int POWER_ON_DELAY_VDD = 8;
  localparam int CS_INIT_DELAY = 210;
  localparam int CS_HIGH_DELAY1 = 14;
  localparam int CS_LOW_DELAY1 = 1;
  localparam int CS_LOW_DELAY2 = 3;
  localparam int MRW_CMD_DELAY = 7;
  localparam int WRITE_LATENCY = 18;
  localparam int READ_LATENCY = 20;
  localparam int WRITE_READ_GAP = 16;
  localparam int REFRESH_INTERVAL = 4; // Refresh every 4 operations

  function new(string name = "ddr5_dram_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ddr5_dram_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_full_name(), "Virtual interface not set via config DB")
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(req);
      execute_transaction(req);
      seq_item_port.item_done();
    end
  endtask

  task execute_transaction(ddr5_dram_trans xtn);
    fork
      initialize_power();
      chipselect_n(); 
    join
    fork
      send_mode_registers(xtn);
    activate_row();
    write_data_burst(xtn); 
	read_data_burst(xtn); 
    join
  //end
// end
       // refresh_all();

  endtask

  task initialize_power();
    #POWER_ON_DELAY_VPP; vif.vpp <= 1;
    #POWER_ON_DELAY_VDD; vif.vdd <= 1;
  endtask
   
  task chipselect_n();
    vif.ca <= 14'h3FFF; 
    #CS_INIT_DELAY;  
    vif.cs_n <= 0;
    #CS_HIGH_DELAY1;
    vif.cs_n <= 1;
    vif.ca <= 14'b1;
    #CS_LOW_DELAY1;  vif.cs_n <= 0;
    vif.ca <= 14'b0000_0000_1111_11;
    #CS_LOW_DELAY2; 
    vif.ca <= 14'h3FFF;
    vif.cs_n <= 1;
    @(posedge vif.ck_t)  
    vif.cs_n <= 0;
  endtask
    
  // Mode register writes
    task send_mode_registers(ddr5_dram_trans xtn);
    send_mrw(14'b00_0000_0000_0101, xtn.m_0);
    send_mrw(14'b0_0000_0010_00101, xtn.m_2);
    send_mrw(14'b00_0000_1000_0101, xtn.m_8);
    `uvm_info(get_full_name(), "Mode Registers Configured", UVM_LOW)
  endtask
    
  task send_mrw(bit [13:0] opcode, bit [7:0] modereg);
    vif.cs_n <= 1'b0; 
    vif.ca <= opcode;
    wait_clk_pos(); 
    delay_cycles(MRW_CMD_DELAY);
    vif.cs_n <= 1;
    vif.ca <= {6'b111111, modereg};
    wait_clk_pos(); 
    vif.cs_n <= 1;
  endtask

  task activate_row(); 
    vif.cs_n <= 0; 
    vif.ca <= 14'b001_00101_0011_00;
    wait_clk_pos();
    
    wait_clk_neg(); 
    vif.cs_n <= 1;  
    vif.ca <= 14'b10000010100001;
    wait_clk_pos();  
    vif.cs_n <= 1;
  endtask
    
    //////////////////WRITE ////////////////////
    
  task write_data_burst(ddr5_dram_trans xtn);
    send_write_cmd();
    delay_cycles(WRITE_LATENCY);
    
    
    drive_preamble(xtn.wr_pre); 
    
    for (int i = 0; i < 8; i++) begin
      wait_clk_pos();  
      vif.dqs_t <= 1;
      vif.dq <= xtn.write_data[i*2]; 
      wait_clk_neg();  
      vif.dqs_t <= 0;
      vif.dq <= xtn.write_data[i*2 + 1];  
    end
   
drive_postamble(xtn.wr_post); 
    
    vif.dqs_t <= 0; 
    vif.dq <= 16'b0;
    delay_cycles(WRITE_READ_GAP);
  endtask

  task send_write_cmd();  
    wait_clk_neg();   
    vif.cs_n <= 0; 
    vif.ca <= 14'b110_00101_1_01101;
    wait_clk_pos();
    wait_clk_neg();   
    vif.cs_n <= 1; 
    vif.ca <= 14'b00010100001010;
    wait_clk_pos();   
    vif.cs_n <= 1; 
    vif.ca <= 14'h3FFF;
  endtask
 
  task read_data_burst(ddr5_dram_trans xtn);
    send_read_cmd();
    delay_cycles(READ_LATENCY);
    
  
    drive_preamble(xtn.rd_pre); 
    
    for (int i = 0; i < 8; i++) begin
      wait_clk_pos(); 
      vif.dqs_t <= 1; 
      vif.dq <= $random;
      wait_clk_neg(); 
      vif.dqs_t <= 0; 
      vif.dq <= $random;
    end
        
   
    drive_postamble(xtn.rd_post);  
        refresh_all();

    vif.dqs_t <= 0; 
    vif.dq <= 16'b0;
  endtask

  task send_read_cmd();
    wait_clk_neg();  
    vif.cs_n <= 0;
    vif.ca <= 14'b00010110111101;
    wait_clk_pos(); 
    vif.ca <= 14'b00010100001010;
    wait_clk_pos();  
    vif.cs_n <= 1; 
  endtask 
    
   
//////////// REFRESH ALL  ///////////////
    task refresh_all();
      `uvm_info(get_full_name(), "Sending REFab (Refresh All) command", UVM_LOW)
     // vif.cs_n< = 0;  vif.ca <=14'b000_0111_1100_10;
       wait_clk_neg();
      vif.cs_n <= 1'b0; 
       vif.ca <= 14'b0_1100_1000_0000_0; 
      wait_clk_pos();
       wait_clk_neg();
      vif.cs_n <= 1'b1;  
       vif.ca <= 14'h3FFF; 
      delay_cycles(16);  
      endtask
    
  task delay_cycles(int count);
    repeat(count) @(posedge vif.ck_t);
  endtask

  task wait_clk_pos();
    @(posedge vif.ck_t);
  endtask

  task wait_clk_neg();
    @(negedge vif.ck_t);
  endtask
    
  task toggle_cs_n(bit val);
    vif.cs_n <= val;
    #1;
  endtask
    
  task drive_preamble(bit pattern[]);
    for (int i = 0; i < pattern.size(); i += 2) begin
      wait_clk_pos(); 
      vif.dqs_t <= pattern[i];
      wait_clk_neg(); 
      vif.dqs_t <= pattern[i+1];
    end
  endtask
    
  task drive_postamble(bit pattern[]);
    wait_clk_pos(); 
    vif.dqs_t <= pattern[0];
    wait_clk_neg(); 
    vif.dqs_t <= pattern[1];
    vif.dqs_t <= 0;
    vif.dq <= 16'b0;
  endtask
endclass