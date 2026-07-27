// axi_pkg.sv
package axi_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // order matters: dependencies first
  `include "axi_transaction.sv"
  `include "master_config.sv"
  `include "slave_config.sv"

  `include "axi_base_seq.sv"
  `include "single_write_seq.sv"
  `include "single_read_seq.sv"
  `include "fixed_burst_seq.sv"
  `include "incr_burst_seq.sv"
  `include "wrap_burst_seq.sv"
  `include "random_write_seq.sv"
  `include "random_read_seq.sv"

  `include "master_driver.sv"
  `include "master_monitor.sv"
  `include "master_sequencer.sv"
  `include "master_agent.sv"

  `include "slave_driver.sv"
  `include "slave_monitor.sv"
  `include "slave_agent.sv"
  `include "axi_virtual_sequencer.sv"
  `include "random_interleave_vseq.sv"
  

  `include "master_coverage.sv"
  `include "axi_scoreboard.sv"
  `include "axi_env.sv"
  `include "axi_base_test.sv"
  `include "write_read_test.sv"

endpackage
