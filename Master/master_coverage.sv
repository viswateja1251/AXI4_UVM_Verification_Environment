class master_coverage extends uvm_subscriber #(axi_transaction);

  `uvm_component_utils(master_coverage)

  // Handle used by the covergroup
  axi_transaction tr;

  //------------------------------------------------------------
  // Functional Coverage
  //------------------------------------------------------------
  covergroup axi_cg;

    option.per_instance = 1;

    //--------------------------------------------------------
    // Burst Type
    //--------------------------------------------------------
    cp_burst_type : coverpoint tr.burst
    {
      bins FIXED = {0};
      bins INCR  = {1};
      bins WRAP  = {2};
    }

    //--------------------------------------------------------
    // Burst Length
    //--------------------------------------------------------
    cp_burst_len : coverpoint tr.len
    {
      bins single = {0};

      bins short[] =
      {
        [1:3]
      };

      bins med[] =
      {
        [4:7]
      };

      bins long[] =
      {
        [8:15]
      };
    }

    //--------------------------------------------------------
    // Transfer Size
    //--------------------------------------------------------
    cp_size : coverpoint tr.size
    {
      bins byte1   = {0};
      bins byte2   = {1};
      bins byte4   = {2};
      bins byte8   = {3};
      bins byte16  = {4};
      bins byte32  = {5};
      bins byte64  = {6};
      bins byte128 = {7};
    }

    //--------------------------------------------------------
    // Transaction ID
    //--------------------------------------------------------
    cp_id : coverpoint tr.id;

    //--------------------------------------------------------
    // Direction
    //--------------------------------------------------------
    cp_direction : coverpoint tr.rw
    {
      bins READ  = {0};
      bins WRITE = {1};
    }

    //--------------------------------------------------------
    // Cross Coverage
    //--------------------------------------------------------
    burst_type_x_len : cross cp_burst_type, cp_burst_len;

  endgroup

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new(string name = "master_coverage",
               uvm_component parent = null);

    super.new(name, parent);

    axi_cg = new();

  endfunction

  //------------------------------------------------------------
  // Called automatically by analysis port
  //------------------------------------------------------------
  virtual function void write(axi_transaction t);

    tr = t;

    axi_cg.sample();

  endfunction
  
  // Report phase
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info(get_type_name(), 
              $sformatf("Functional coverage = %0.2f%%", axi_cg.get_coverage()), 
      UVM_LOW)
    
  endfunction

endclass
