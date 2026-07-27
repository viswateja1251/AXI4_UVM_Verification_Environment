class master_config extends uvm_object;

  `uvm_object_utils(master_config)

  //------------------------------------------
  // Virtual Interface
  //------------------------------------------

  virtual axi_if vif;

  //------------------------------------------
  // Agent Mode
  //------------------------------------------

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  //------------------------------------------
  // Enable Functional Coverage
  //------------------------------------------

  bit has_coverage = 1;

  //------------------------------------------
  // Enable Scoreboard Checking
  //------------------------------------------

  bit has_checks = 1;

  //------------------------------------------
  // Constructor
  //------------------------------------------

  function new(string name = "master_config");
    super.new(name);
  endfunction

endclass