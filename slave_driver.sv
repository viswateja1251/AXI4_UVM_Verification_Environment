class slave_driver extends uvm_driver #(axi_transaction);

  `uvm_component_utils(slave_driver)

  virtual axi_if.m2 vif;
  slave_config cfg;

  // Internal memory
  bit [31:0] memory[];

  function new(string name="slave_driver",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------
  // BUILD PHASE
  //---------------------------------------

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(slave_config)::get(this,"","slave_config",cfg))
      `uvm_fatal(get_type_name(),"Cannot get slave_config");
  endfunction


  //---------------------------------------
  // CONNECT PHASE
  //---------------------------------------

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    vif = cfg.vif;
    memory = new[cfg.mem_depth];
    
    `uvm_info(get_type_name(),
          $sformatf("Driver vif=%p", vif),
          UVM_LOW)
    
  endfunction


  //---------------------------------------
  // RUN PHASE
  //---------------------------------------

  task run_phase(uvm_phase phase);

    // Default outputs
    vif.sldr.AWREADY <= 0;
    vif.sldr.WREADY  <= 0;
    vif.sldr.BVALID  <= 0;
    vif.sldr.BRESP   <= 0;
    vif.sldr.BID     <= 0;

    vif.sldr.ARREADY <= 0;
    vif.sldr.RVALID  <= 0;
    vif.sldr.RLAST   <= 0;
    vif.sldr.RDATA   <= 0;
    vif.sldr.RRESP   <= 0;
    vif.sldr.RID     <= 0;

    fork
      handle_write();
      handle_read();
    join

  endtask


  //---------------------------------------
  // READY DELAY
  //---------------------------------------

  task automatic ready_delay();

    int delay;

    if(cfg.enable_ready_delay)
      delay = $urandom_range(0,cfg.max_ready_delay);
    else
      delay = 0;

    repeat(delay)
      @(vif.sldr);

  endtask


  //---------------------------------------
  // HANDLE WRITE
  //---------------------------------------

  task handle_write();

    axi_transaction tr;
    
   // wait(vif.sldr.ARESETn);

    forever begin

      tr = axi_transaction::type_id::create("tr");

      //---------------- AW ----------------

      ready_delay();
      

      vif.sldr.AWREADY <= 1;

      do
        @(vif.sldr);
      while(!vif.sldr.AWVALID);

      tr.rw    = 1;
      tr.id    = vif.sldr.AWID;
      tr.addr  = vif.sldr.AWADDR;
      tr.len   = vif.sldr.AWLEN;
      tr.size  = vif.sldr.AWSIZE;
      tr.burst = vif.sldr.AWBURST;
      
      `uvm_info(get_type_name(),
          $sformatf("SLAVE AW captured: AWLEN=%0d AWADDR=%h",
                    tr.len, tr.addr),
          UVM_LOW)

      tr.data = new[tr.len+1];
      tr.strb = new[tr.len+1];
      
//       //for debugging
//       `uvm_info(get_type_name(),
//                 $sformatf("AW addr=%h size=%0d len=%0d",
//                 tr.addr,tr.size,tr.len),
//                 UVM_LOW)

      vif.sldr.AWREADY <= 0;

      //---------------- W ----------------

      for(int i=0;i<=tr.len;i++) begin
        
        int unsigned index;

        ready_delay();

        vif.sldr.WREADY <= 1;

        do
          @(vif.sldr);
        while(!vif.sldr.WVALID);

        tr.data[i] = vif.sldr.WDATA;
        tr.strb[i] = vif.sldr.WSTRB;
        
        index = (tr.addr>>tr.size)+i;
        
//         // for debugging
//         `uvm_info(get_type_name(),
// $sformatf("Index=%0d Data=%h",
// index,tr.data[i]),
// UVM_LOW)

        memory[index] = tr.data[i];

        if(i<tr.len && vif.sldr.WLAST)
          `uvm_error(get_type_name(),"Early WLAST")

        if(i==tr.len && !vif.sldr.WLAST)
          `uvm_error(get_type_name(),"Expected WLAST")

        vif.sldr.WREADY <= 0;

      end

      send_bresp(tr);

    end

  endtask
  
    //---------------------------------------
  // HANDLE READ
  //---------------------------------------

  task handle_read();

    axi_transaction tr;
    
  //  wait(vif.sldr.ARESETn);

    forever begin

      tr = axi_transaction::type_id::create("rd_tr");

      //---------------- AR ----------------

      ready_delay();

      vif.sldr.ARREADY <= 1;

      do
        @(vif.sldr);
      while(!vif.sldr.ARVALID);

      tr.rw    = 0;
      tr.id    = vif.sldr.ARID;
      tr.addr  = vif.sldr.ARADDR;
      tr.len   = vif.sldr.ARLEN;
      tr.size  = vif.sldr.ARSIZE;
      tr.burst = vif.sldr.ARBURST;

      tr.data  = new[tr.len+1];
      tr.rresp = new[tr.len+1];

      vif.sldr.ARREADY <= 0;

      send_rdata(tr);

    end

  endtask


  //---------------------------------------
  // WRITE RESPONSE
  //---------------------------------------

  task send_bresp(axi_transaction tr);

    @(vif.sldr);

    vif.sldr.BID    <= tr.id;
    vif.sldr.BRESP  <= 2'b00;      // OKAY
    vif.sldr.BVALID <= 1;

    do
      @(vif.sldr);
    while(!vif.sldr.BREADY);

    vif.sldr.BVALID <= 0;

  endtask


  //---------------------------------------
  // READ DATA
  //---------------------------------------

  task send_rdata(axi_transaction tr);

    for(int i=0;i<=tr.len;i++) begin

    //  @(vif.sldr);

      tr.data[i]  = memory[(tr.addr>>tr.size)+i];
      tr.rresp[i] = 32'h00000000;

      vif.sldr.RID   <= tr.id;
      vif.sldr.RDATA <= tr.data[i];
      vif.sldr.RRESP <= tr.rresp[i];
      vif.sldr.RLAST <= (i==tr.len);
      vif.sldr.RVALID<= 1;

      do
        @(vif.sldr);
      while(!vif.sldr.RREADY);

    end

    vif.sldr.RVALID <= 0;
    vif.sldr.RLAST  <= 0;

  endtask
  
endclass
