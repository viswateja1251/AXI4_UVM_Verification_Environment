class slave_config extends uvm_object;

  `uvm_object_utils(slave_config)

  // Virtual interface
  virtual axi_if vif;

  // Memory configuration
  int unsigned mem_depth = 1024;

  // READY delay configuration
  bit enable_ready_delay = 1;
  int unsigned max_ready_delay = 3;

  // Active/Passive agent
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name = "slave_config");
    super.new(name);
  endfunction

endclass