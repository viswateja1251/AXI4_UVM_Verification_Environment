class slave_monitor extends uvm_monitor;

  `uvm_component_utils(slave_monitor)

  //---------------------------------------------
  // Virtual Interface
  //---------------------------------------------

  virtual axi_if.m4 vif;

  //---------------------------------------------
  // Config Object
  //---------------------------------------------

  slave_config cfg;

  //---------------------------------------------
  // Analysis Port
  //---------------------------------------------

  uvm_analysis_port #(axi_transaction) ap;

  //---------------------------------------------
  // Constructor
  //---------------------------------------------

  function new(string name="slave_monitor",
               uvm_component parent);
      super.new(name,parent);
  endfunction

  //---------------------------------------------
  // Build Phase
  //---------------------------------------------

  function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      ap = new("ap",this);

    if(!uvm_config_db #(slave_config)::get(this,
                                              "",
                                              "slave_config",
                                              cfg))
      begin
          `uvm_fatal(get_type_name(),
                     "Cannot get slave_config")
      end

  endfunction

  //---------------------------------------------
  // Connect Phase
  //---------------------------------------------

  function void connect_phase(uvm_phase phase);

      super.connect_phase(phase);

      vif = cfg.vif;

  endfunction
  
    //---------------------------------------------
  // Run Phase
  //---------------------------------------------

  task run_phase(uvm_phase phase);

      fork

          monitor_write();

          monitor_read();

      join

  endtask
  
  
    //---------------------------------------------
  // Monitor Write Transaction
  //---------------------------------------------

  task monitor_write();

      axi_transaction tr;
    
    do
  @(vif.slmon);
while (!vif.slmon.ARESETn);

      forever
      begin

          //-------------------------------------
          // Create transaction
          //-------------------------------------

          tr = axi_transaction::type_id::create("tr");

          //-------------------------------------
          // Wait for AW Handshake
          //-------------------------------------

          do
            @(vif.slmon);
          while(!(vif.slmon.AWVALID == 1'b1 &&
                  vif.slmon.AWREADY == 1'b1));

          tr.rw     = 1;
          tr.id     = vif.slmon.AWID;
          tr.addr   = vif.slmon.AWADDR;
          tr.len    = vif.slmon.AWLEN;
        
//         `uvm_info(get_type_name(),
//           $sformatf("MONITOR AW captured: AWLEN=%0d AWADDR=%h",
//                     tr.len, tr.addr),
//           UVM_LOW)
          tr.size   = vif.slmon.AWSIZE;
          tr.burst  = vif.slmon.AWBURST;

          //-------------------------------------
          // Allocate Dynamic Arrays
          //-------------------------------------

          tr.data = new[tr.len+1];
          tr.strb = new[tr.len+1];

          //-------------------------------------
          // Capture WDATA
          //-------------------------------------

          for(int i=0;i<=tr.len;i++)
          begin

              do
                @(vif.slmon);
              while(!(vif.slmon.WVALID == 1'b1 &&
                      vif.slmon.WREADY == 1'b1));

            tr.data[i] = vif.slmon.WDATA;
            tr.strb[i] = vif.slmon.WSTRB;
//             `uvm_info(get_type_name(),
//           $sformatf("Beat=%0d Len=%0d WLAST=%0b",
//                     i, tr.len, vif.slmon.WLAST),
//           UVM_LOW)

              //---------------------------------
              // Check WLAST
              //---------------------------------

              if(i==tr.len)
              begin

                if(!vif.slmon.WLAST)
                      `uvm_error(get_type_name(),
                                 "Expected WLAST")

              end
              else
              begin

                if(vif.slmon.WLAST)
                      `uvm_error(get_type_name(),
                                 "Early WLAST")

              end

          end

          //-------------------------------------
          // Wait for B Channel
          //-------------------------------------

          do
            @(vif.slmon);
          while(!(vif.slmon.BVALID == 1'b1 &&
                  vif.slmon.BREADY == 1'b1));

          tr.bid   = vif.slmon.BID;
          tr.bresp = vif.slmon.BRESP;

          //-------------------------------------
          // Broadcast Transaction
          //-------------------------------------

          ap.write(tr);

          `uvm_info(get_type_name(),
                    "WRITE Transaction Captured",
                    UVM_MEDIUM);

      end

  endtask
          
   //---------------------------------------------
  // Monitor Read Transaction
  //---------------------------------------------

  task monitor_read();

      axi_transaction tr;
    
    do
  @(vif.slmon);
while (!vif.slmon.ARESETn);

      forever
      begin

          //-------------------------------------
          // Create Transaction
          //-------------------------------------

          tr = axi_transaction::type_id::create("tr");

          //-------------------------------------
          // Wait for AR Handshake
          //-------------------------------------

          do
            @(vif.slmon);
          while(!(vif.slmon.ARVALID == 1'b1 &&
                  vif.slmon.ARREADY == 1'b1));

          //-------------------------------------
          // Capture Address Channel
          //-------------------------------------

          tr.rw     = 0;

          tr.id     = vif.slmon.ARID;
          tr.addr   = vif.slmon.ARADDR;
          tr.len    = vif.slmon.ARLEN;
          tr.size   = vif.slmon.ARSIZE;
          tr.burst  = vif.slmon.ARBURST;

          //-------------------------------------
          // Allocate Arrays
          //-------------------------------------

          tr.data  = new[tr.len+1];
          tr.strb  = new[tr.len+1];      // optional
          tr.rresp = new[tr.len+1];

          //-------------------------------------
          // Capture Read Data
          //-------------------------------------

          for(int i=0;i<=tr.len;i++)
          begin

              do
                @(vif.slmon);
              while(!(vif.slmon.RVALID == 1'b1 &&
                      vif.slmon.RREADY == 1'b1));

              //---------------------------------
              // Capture Signals
              //---------------------------------

            tr.data[i]  = vif.slmon.RDATA;
            tr.rresp[i] = vif.slmon.RRESP;
              tr.rid      = vif.slmon.RID;

              //---------------------------------
              // Check RLAST
              //---------------------------------

              if(i==tr.len)
              begin
                if(!vif.slmon.RLAST)
                      `uvm_error(get_type_name(),
                                 "Expected RLAST")
              end
              else
              begin
                if(vif.slmon.RLAST)
                      `uvm_error(get_type_name(),
                                 "Early RLAST")
              end

          end

          //-------------------------------------
          // Send Transaction
          //-------------------------------------

          ap.write(tr);

          `uvm_info(get_type_name(),
                    "READ Transaction Captured",
                    UVM_MEDIUM);

      end

  endtask
 endclass
                
