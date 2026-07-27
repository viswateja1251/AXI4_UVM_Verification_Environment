class master_agent extends uvm_agent;

  `uvm_component_utils(master_agent)

  //------------------------------------------
  // Components
  //------------------------------------------

  master_driver      drv;
  master_sequencer   seqr;
  master_monitor     mon;

  //------------------------------------------
  // Configuration
  //------------------------------------------

  master_config cfg;

  //------------------------------------------
  // Analysis Port
  //------------------------------------------

  // Environment/scoreboard connects here.
  // Internally this forwards monitor transactions.
  uvm_analysis_port #(axi_transaction) ap;

  //------------------------------------------
  // Constructor
  //------------------------------------------

  function new(string name = "master_agent",
               uvm_component parent);
    super.new(name, parent);
  endfunction


  //------------------------------------------
  // Build Phase
  //------------------------------------------

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db#(master_config)::get(
            this,
            "",
            "master_config",
            cfg))
      `uvm_fatal(get_type_name(),
                 "Failed to get master_config")

    //--------------------------------------
    // Analysis Port
    //--------------------------------------

    ap = new("ap", this);

    //--------------------------------------
    // Monitor always exists
    //--------------------------------------

    mon = master_monitor::type_id::create(
                    "mon", this);

    //--------------------------------------
    // Driver & Sequencer only in ACTIVE mode
    //--------------------------------------

    if(cfg.is_active == UVM_ACTIVE)
    begin

      drv  = master_driver::type_id::create(
                    "drv", this);

      seqr = master_sequencer::type_id::create(
                    "seqr", this);

    end

  endfunction


  //------------------------------------------
  // Connect Phase
  //------------------------------------------

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    //--------------------------------------
    // Driver <-> Sequencer
    //--------------------------------------

    if(cfg.is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(
            seqr.seq_item_export);

    //--------------------------------------
    // Export Monitor Analysis Port
    //--------------------------------------

    mon.ap.connect(ap);

  endfunction

endclass