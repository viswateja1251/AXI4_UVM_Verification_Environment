class axi_base_test extends uvm_test;

  `uvm_component_utils(axi_base_test)

  axi_env env;

  master_config m_cfg;
  slave_config  s_cfg;

  virtual axi_if vif;

  function new(string name="axi_base_test",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------
  // BUILD PHASE
  //---------------------------------------

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Get virtual interface
    if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(),"Cannot get virtual interface")

    // Create configs
    m_cfg = master_config::type_id::create("m_cfg");
    s_cfg = slave_config::type_id::create("s_cfg");

    // Assign interface
    m_cfg.vif = vif;
    s_cfg.vif = vif;

    // Pass configs to agents
    uvm_config_db#(master_config)::set(this,
                                       "env.*",
                                       "master_config",
                                       m_cfg);

    uvm_config_db#(slave_config)::set(this,
                                      "env.*",
                                      "slave_config",
                                      s_cfg);

    // Create environment
    env = axi_env::type_id::create("env", this);

  endfunction


  //---------------------------------------
  // RUN PHASE
  //---------------------------------------

  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    // Child tests will start sequences here

    #100;

    phase.drop_objection(this);

  endtask

endclass