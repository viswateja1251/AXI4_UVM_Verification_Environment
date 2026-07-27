`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi_if.sv"
`include "axi_assertions.sv"
`include "axi_pkg.sv"

import axi_pkg::*;


`timescale 1ns/1ps

module tb_top;

  //---------------------------------------
  // CLOCK
  //---------------------------------------

  logic ACLK;

  initial begin
    ACLK = 0;
    forever #5 ACLK = ~ACLK;
  end


  //---------------------------------------
  // INTERFACE
  //---------------------------------------

  axi_if axi_if_inst(ACLK);

  axi_assertions axi_assertions_inst(.vif(axi_if_inst));

  //---------------------------------------
  // RESET
  //---------------------------------------

  initial begin
    axi_if_inst.ARESETn = 0;
    repeat(20) @(posedge ACLK);
    axi_if_inst.ARESETn = 1;
  end


  //---------------------------------------
  // CONFIG DB
  //---------------------------------------

  initial begin

    uvm_config_db#(virtual axi_if)::set(null,
                                        "*",
                                        "vif",
                                        axi_if_inst);

    run_test("write_read_test");

  end


  //---------------------------------------
  // DUMP WAVEFORM
  //---------------------------------------

//   initial begin
//     $dumpfile("dump.vcd");
//     $dumpvars(0,tb_top);
//   end

endmodule