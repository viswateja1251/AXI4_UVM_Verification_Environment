interface axi_if(input logic ACLK);
  logic ARESETn;
  
  //AXI4 specific signals
  logic [3:0] AWCACHE, ARCACHE;
  logic [2:0] AWPROT, ARPROT;
  logic [3:0] AWQOS, ARQOS;
  logic [3:0] AWREGION, ARREGION;
  
  //***************************CHANNEL 1*******************************//
  //Write address channel signals(AW)
  //Master signals
  logic [3:0] AWID;
  logic [31:0] AWADDR;
  logic[7:0] AWLEN;
  logic[2:0] AWSIZE;
  logic[1:0] AWBURST;
  logic AWVALID;
  //Slave Signal
  logic AWREADY;
  
  //****************************CHANNEL 2******************************//
  //Write data channel signals(W)
  //Master Signals
  //logic[3:0]  WID; //not present in AXI4
  logic[31:0] WDATA;
  logic[3:0] WSTRB;
  logic WLAST;
  logic WVALID;
  //Slave Signal
  logic WREADY;
  
  //***************************CHANNEL 3*******************************//
  //Write response channel signals(B)
  //Master Signal
  logic BREADY;
  //Slave signals
  logic[3:0] BID;
  logic[1:0] BRESP;
  logic BVALID;
  
  //*****************************CHANNEL 4*****************************//
  //Read Address channel signals(AR)
  //Master Signals
  logic[3:0] ARID;
  logic[31:0] ARADDR;
  logic[7:0] ARLEN;
  logic[2:0] ARSIZE;
  logic[1:0] ARBURST;
  logic ARVALID;
  //Slave Signal
  logic ARREADY;
  
  
  //*****************************CHANNEL 5*****************************//
  //Read data channel signals(R)
  //Master Signal
  logic RREADY;
  logic RVALID;
  //Slave Signal
  logic[3:0] RID;
  logic[31:0] RDATA;
  logic[31:0] RRESP;
  logic RLAST;
  
  //*****************************(CLOCKING BLOCKS)*****************************//
  clocking msdr@(posedge ACLK);
  default input #0 output #0; 
  output AWADDR,AWVALID,AWID,AWLEN,AWBURST,AWSIZE;
  output WDATA,WVALID,WSTRB, WLAST;
  output BREADY;
  output ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
  output RREADY;
  input ARESETn;
  output AWCACHE, AWPROT, AWQOS, AWREGION;
  output ARCACHE, ARPROT, ARQOS, ARREGION;
  input AWREADY;
  input WREADY;
  input BRESP,BID;
  input BVALID;
  input ARREADY;
  input RID,RDATA,RRESP,RLAST,RVALID;
  endclocking

  clocking sldr@(posedge ACLK);
  default input #0 output #0; 
  input AWADDR,AWVALID,AWID,AWLEN,AWBURST,AWSIZE;
  input WDATA,WVALID,WSTRB, WLAST;
  input BREADY;
  input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID;
  input RREADY;
  input ARESETn;
  input AWCACHE, AWPROT, AWQOS, AWREGION;
  input ARCACHE, ARPROT, ARQOS, ARREGION;
  output AWREADY;
  output WREADY;
  output BRESP;
  output BVALID,BID;
  output ARREADY;
  output RID,RDATA,RRESP,RLAST,RVALID;
  endclocking

  clocking slmon@(posedge ACLK);
  default input #0 output #0; 
  input ARESETn,AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID,AWREADY;
  input WDATA,WSTRB,WLAST,WVALID,WREADY;
  input BREADY,BID,BRESP,BVALID;
  input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,ARREADY;
  input RREADY,RID,RDATA,RRESP,RLAST,RVALID;
  input AWCACHE, AWPROT, AWQOS, AWREGION;
  input ARCACHE, ARPROT, ARQOS, ARREGION;
  endclocking

  clocking msmon@(posedge ACLK);
  default input #0 output #0; 
  input ARESETn,AWID,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID,AWREADY;
  input WDATA,WSTRB,WLAST,WVALID,WREADY;
  input BREADY,BID,BRESP,BVALID;
  input ARID,ARADDR,ARLEN,ARSIZE,ARBURST,ARVALID,ARREADY;
  input RREADY,RID,RDATA,RRESP,RLAST,RVALID;
  input AWCACHE, AWPROT, AWQOS, AWREGION;
  input ARCACHE, ARPROT, ARQOS, ARREGION;
  endclocking


  //*****************************(MODPORT)************************************//
  modport m1(clocking msdr);
  modport m2(clocking sldr);
  modport m3(clocking msmon);
  modport m4(clocking slmon);
  endinterface
