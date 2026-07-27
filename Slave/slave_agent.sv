class slave_agent extends uvm_agent;

  `uvm_component_utils(slave_agent)

  slave_driver  drv;
  slave_monitor mon;

  slave_config cfg;

  function new(string name="slave_agent",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------
  // BUILD PHASE
  //---------------------------------------

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if(!uvm_config_db#(slave_config)::get(this,"","slave_config",cfg))
      `uvm_fatal(get_type_name(),"Cannot get slave_config")

    if(cfg.is_active == UVM_ACTIVE)
      drv = slave_driver::type_id::create("drv",this);

    mon = slave_monitor::type_id::create("mon",this);

    uvm_config_db#(slave_config)::set(this,
                                     "drv",
                                     "slave_config",
                                     cfg);

    uvm_config_db#(slave_config)::set(this,
                                     "mon",
                                     "slave_config",
                                     cfg);

  endfunction


  //---------------------------------------
  // CONNECT PHASE
  //---------------------------------------

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

  endfunction

endclass
