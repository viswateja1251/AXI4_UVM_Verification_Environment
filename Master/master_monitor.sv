class master_monitor extends uvm_monitor;

  `uvm_component_utils(master_monitor)

  //---------------------------------------------
  // Virtual Interface
  //---------------------------------------------

  virtual axi_if vif;

  //---------------------------------------------
  // Config Object
  //---------------------------------------------

  master_config cfg;

  //---------------------------------------------
  // Analysis Port
  //---------------------------------------------

  uvm_analysis_port #(axi_transaction) ap;

  //---------------------------------------------
  // Constructor
  //---------------------------------------------

  function new(string name="master_monitor",
               uvm_component parent);
      super.new(name,parent);
  endfunction

  //---------------------------------------------
  // Build Phase
  //---------------------------------------------

  function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      ap = new("ap",this);

      if(!uvm_config_db #(master_config)::get(this,
                                              "",
                                              "master_config",
                                              cfg))
      begin
          `uvm_fatal(get_type_name(),
                     "Cannot get master_config")
      end

  endfunction

  //---------------------------------------------
  // Connect Phase
  //---------------------------------------------

  function void connect_phase(uvm_phase phase);

      super.connect_phase(phase);

      vif = cfg.vif;
    
//     `uvm_info(get_type_name(),
//           $sformatf("Driver vif=%p", vif),
//           UVM_LOW)

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
    
//     `uvm_info(get_type_name(), "monitor_write started", UVM_LOW)
    
    wait(vif.ARESETn);
    
//     `uvm_info(get_type_name(), "monitor_write after resetn", UVM_LOW)

      forever
      begin

          //-------------------------------------
          // Create transaction
          //-------------------------------------

          tr = axi_transaction::type_id::create("tr");

          //-------------------------------------
          // Wait for AW Handshake
          //-------------------------------------

//           do
//               @(vif.msmon);
//           while(!(vif.msmon.AWVALID == 1'b1 &&
//                   vif.msmon.AWREADY == 1'b1));
 
        
        forever begin
              @(vif.msmon);

//               `uvm_info(get_type_name(),
//                 $sformatf("AWVALID=%0b AWREADY=%0b AWADDR=%08h",
//                   vif.msmon.AWVALID,
//                   vif.msmon.AWREADY,
//                   vif.msmon.AWADDR),
//                 UVM_LOW);

          if(vif.msmon.AWVALID == 1'b1 && vif.msmon.AWREADY == 1'b1)
                break;
            end


          tr.rw     = 1;
          tr.id     = vif.msmon.AWID;
          tr.addr   = vif.msmon.AWADDR;
          tr.len    = vif.msmon.AWLEN;
          tr.size   = vif.msmon.AWSIZE;
          tr.burst  = vif.msmon.AWBURST;
        
//         //for debugging
//         `uvm_info(get_type_name(),
// $sformatf("AW HS ADDR=%08h", vif.msmon.AWADDR),
// UVM_LOW)
        
//         `uvm_info(get_type_name(),
//           "AW captured",
//           UVM_LOW)

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
                  @(vif.msmon);
              while(!(vif.msmon.WVALID == 1'b1 &&
                      vif.msmon.WREADY == 1'b1));

              tr.data[i] = vif.msmon.WDATA;
              tr.strb[i] = vif.msmon.WSTRB;
            
//             //for debugging 
//             `uvm_info(get_type_name(),
//           "W captured",
//           UVM_LOW)

              //---------------------------------
              // Check WLAST
              //---------------------------------

              if(i==tr.len)
              begin

                  if(!vif.msmon.WLAST)
                      `uvm_error(get_type_name(),
                                 "Expected WLAST")

              end
              else
              begin

                  if(vif.msmon.WLAST)
                      `uvm_error(get_type_name(),
                                 "Early WLAST")

              end

          end

          //-------------------------------------
          // Wait for B Channel
          //-------------------------------------

          do
              @(vif.msmon);
          while(!(vif.msmon.BVALID == 1'b1 &&
                  vif.msmon.BREADY == 1'b1));

          tr.bid   = vif.msmon.BID;
          tr.bresp = vif.msmon.BRESP;
                
//                 //for debugging
//                 `uvm_info(get_type_name(),
//           "B captured",
//           UVM_LOW)

          //-------------------------------------
          // Broadcast Transaction
          //-------------------------------------
//                 //for debugging
//                 `uvm_info(get_type_name(),
// $sformatf("MONITOR WRITE addr=%08h", tr.addr),
// UVM_LOW)
                
//                 `uvm_info(get_type_name(),"Before ap.write()",UVM_LOW)

          ap.write(tr);
                
//                 `uvm_info(get_type_name(),"after ap.write()",UVM_LOW)

//           `uvm_info(get_type_name(),
//                     "WRITE Transaction Captured",
//                     UVM_MEDIUM);

      end

  endtask
          
   //---------------------------------------------
  // Monitor Read Transaction
  //---------------------------------------------

  task monitor_read();

      axi_transaction tr;
    
    wait(vif.msmon.ARESETn);

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
              @(vif.msmon);
          while(!(vif.msmon.ARVALID == 1'b1 &&
                  vif.msmon.ARREADY == 1'b1));

          //-------------------------------------
          // Capture Address Channel
          //-------------------------------------

          tr.rw     = 0;

          tr.id     = vif.msmon.ARID;
          tr.addr   = vif.msmon.ARADDR;
          tr.len    = vif.msmon.ARLEN;
          tr.size   = vif.msmon.ARSIZE;
          tr.burst  = vif.msmon.ARBURST;
        
//         //for debugging
// 		`uvm_info(get_type_name(),
// $sformatf("AR HS ADDR=%08h", vif.msmon.ARADDR),
// UVM_LOW)

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
                  @(vif.msmon);
              while(!(vif.msmon.RVALID == 1'b1 &&
                      vif.msmon.RREADY == 1'b1));

              //---------------------------------
              // Capture Signals
              //---------------------------------

              tr.data[i]  = vif.msmon.RDATA;
              tr.rresp[i] = vif.msmon.RRESP;
              tr.rid      = vif.msmon.RID;

              //---------------------------------
              // Check RLAST
              //---------------------------------

              if(i==tr.len)
              begin
                  if(!vif.msmon.RLAST)
                      `uvm_error(get_type_name(),
                                 "Expected RLAST")
              end
              else
              begin
                  if(vif.msmon.RLAST)
                      `uvm_error(get_type_name(),
                                 "Early RLAST")
              end

          end

          //-------------------------------------
          // Send Transaction
          //-------------------------------------

          ap.write(tr);

//           `uvm_info(get_type_name(),
//                     "READ Transaction Captured",
//                     UVM_MEDIUM);

      end

  endtask
 endclass
                
