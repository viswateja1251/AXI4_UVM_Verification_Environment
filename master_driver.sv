class master_driver extends uvm_driver #(axi_transaction);

  `uvm_component_utils(master_driver)

  virtual axi_if.m1 vif;
  
  master_config cfg;

  function new(string name="master_driver",uvm_component parent);
    
    super.new(name,parent);
    
  endfunction


  //---------------------------------------
  // BUILD PHASE
  //---------------------------------------

  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    if(!uvm_config_db #(master_config)::get(this,"","master_config",cfg))
      
      `uvm_fatal(get_type_name(),"Cannot get master_config")
      
  endfunction


  //---------------------------------------
  // CONNECT PHASE
  //---------------------------------------

  function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);

    vif = cfg.vif;
    
//     `uvm_info(get_type_name(),
//           $sformatf("Driver vif=%p", vif),
//           UVM_LOW)
    
  endfunction


  //---------------------------------------
  // RUN PHASE
  //---------------------------------------

  task run_phase(uvm_phase phase);
    
      vif.msdr.AWVALID <= 0;
      vif.msdr.WVALID  <= 0;
      vif.msdr.BREADY  <= 0;
      vif.msdr.ARVALID <= 0;
      vif.msdr.RREADY  <= 0;
      vif.msdr.WLAST   <= 0;
    
    wait(vif.msdr.ARESETn);

    forever begin

      seq_item_port.get_next_item(req);

      req.print();

      if(req.rw)
        
        drive_write(req);
      
      else
        
        drive_read(req);

      seq_item_port.item_done();

    end

  endtask


  //---------------------------------------
  // WRITE
  //---------------------------------------

  task drive_write(axi_transaction tr);

    drive_aw(tr);

    drive_w(tr);

    drive_b();

  endtask


  //---------------------------------------
  // AW CHANNEL
  //---------------------------------------

  task drive_aw(axi_transaction tr);

    @(vif.msdr);

    vif.msdr.AWID     <= tr.id;
    vif.msdr.AWADDR   <= tr.addr;
    vif.msdr.AWLEN    <= tr.len;
    vif.msdr.AWSIZE   <= tr.size;
    vif.msdr.AWBURST  <= tr.burst;

    vif.msdr.AWVALID  <= 1;
    
    
//     //for debugging
//     `uvm_info(get_type_name(),
// $sformatf("DRIVER AW addr=%08h", tr.addr),
// UVM_LOW)

    do
      @(vif.msdr);
    while(!vif.msdr.AWREADY); // wait for AWREADY to go high
    
    //After AWVALID == 1 and AWREADY ==1 , Handshake is done
    //repeat(2) @(vif.msdr);   // don't wait for awready

    vif.msdr.AWVALID <= 0;
    
   // vif.msdr.AWVALID <= 1;

//     @(vif.msdr);

//       // Force protocol violation
//       vif.msdr.AWVALID <= 0;

//       // Wait until slave becomes ready
//       wait(vif.msdr.AWREADY);

  endtask


  //---------------------------------------
  // W CHANNEL
  //---------------------------------------

  task drive_w(axi_transaction tr);

    foreach(tr.data[i]) begin

      vif.msdr.WDATA  <= tr.data[i];
      vif.msdr.WSTRB  <= tr.strb[i];

      vif.msdr.WLAST  <= (i == tr.len);

      vif.msdr.WVALID <= 1;

      do
        @(vif.msdr);
      while(!vif.msdr.WREADY);
      
//       `uvm_info(get_type_name(),
//           $sformatf("Beat=%0d Len=%0d WLAST=%0b",
//                     i, tr.len, vif.msdr.WLAST),
//           UVM_LOW)

    end
    
    
    
    // After all beats
    
      vif.msdr.WVALID <= 0;
      vif.msdr.WLAST  <= 0;

  endtask


  //---------------------------------------
  // B CHANNEL
  //---------------------------------------

  task drive_b();

    vif.msdr.BREADY <= 1;

    do
      @(vif.msdr);
    while(!vif.msdr.BVALID);

    vif.msdr.BREADY <= 0;

  endtask


  //---------------------------------------
  // READ
  //---------------------------------------

  task drive_read(axi_transaction tr);

    drive_ar(tr);

    drive_r(tr);

  endtask


  //---------------------------------------
  // AR CHANNEL
  //---------------------------------------

  task drive_ar(axi_transaction tr);

    @(vif.msdr);

    vif.msdr.ARID     <= tr.id;
    vif.msdr.ARADDR   <= tr.addr;
    vif.msdr.ARLEN    <= tr.len;
    vif.msdr.ARSIZE   <= tr.size;
    vif.msdr.ARBURST  <= tr.burst;

    vif.msdr.ARVALID  <= 1;

    do
      @(vif.msdr);
    while(!vif.msdr.ARREADY);

    vif.msdr.ARVALID <= 0;

  endtask


  //---------------------------------------
  // R CHANNEL
  //---------------------------------------

  task drive_r(axi_transaction tr);

    tr.data = new[tr.len+1];

    for(int i=0;i<=tr.len;i++) begin

      vif.msdr.RREADY <= 1;

      do
        @(vif.msdr);
      while(!vif.msdr.RVALID);

      tr.data[i] = vif.msdr.RDATA;

      if(i == tr.len && !vif.msdr.RLAST)
        `uvm_error(get_type_name(),
                   "Expected RLAST")

      if(i < tr.len && vif.msdr.RLAST)
        `uvm_error(get_type_name(),
                   "Early RLAST")

    end

    vif.msdr.RREADY <= 0;

  endtask

endclass