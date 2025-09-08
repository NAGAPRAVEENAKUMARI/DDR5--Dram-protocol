interface ddr5_dram_if (input ck_t, ck_c);
  logic vpp;
  logic vdd;
  logic cs_n;
  logic [13:0] ca;
  logic [15:0] dq;
  logic dqs_t=0;
  logic dqs_c;
  
  
endinterface 