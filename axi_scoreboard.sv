//`uvm_analysis_imp_decl(_mon)

class axi_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi_scoreboard)

  // Analysis implementation
  uvm_analysis_imp #(axi_transaction,
                         axi_scoreboard) analysis_export;

  // Reference memory
  bit [31:0] ref_mem[];

  // Statistics
  int total_txns;
  int pass_cnt;
  int fail_cnt;

  function new(string name="axi_scoreboard",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------
  // BUILD PHASE
  //---------------------------------------

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    analysis_export = new("analysis_export", this);

    ref_mem = new[1024];

    total_txns = 0;
    pass_cnt   = 0;
    fail_cnt   = 0;

  endfunction


  //---------------------------------------
  // WRITE FUNCTION
  //---------------------------------------

  function void write(axi_transaction tr);

    total_txns++;

    if(tr.rw)
      process_write(tr);
    else
      process_read(tr);

  endfunction


  //---------------------------------------
  // WRITE CHECK
  //---------------------------------------

  function void process_write(axi_transaction tr);

    foreach(tr.data[i])

      ref_mem[(tr.addr >> tr.size)+i] = tr.data[i];

    `uvm_info(get_type_name(),
              $sformatf("WRITE stored @0x%08h",
              tr.addr),
              UVM_LOW);

    pass_cnt++;

  endfunction


  //---------------------------------------
  // READ CHECK
  //---------------------------------------

  function void process_read(axi_transaction tr);

    bit pass = 1;

    foreach(tr.data[i]) begin

      if(ref_mem[(tr.addr>>tr.size)+i] != tr.data[i]) begin

        pass = 0;

        `uvm_error(get_type_name(),
          $sformatf("READ MISMATCH Addr=0x%08h Beat=%0d Exp=0x%08h Act=0x%08h",
          tr.addr+(i<<tr.size),
          i,
          ref_mem[(tr.addr>>tr.size)+i],
          tr.data[i]));

      end

    end

    if(pass) begin

      pass_cnt++;

      `uvm_info(get_type_name(),
        $sformatf("READ PASS @0x%08h",tr.addr),
        UVM_LOW);

    end
    else

      fail_cnt++;

  endfunction


  //---------------------------------------
  // REPORT
  //---------------------------------------

  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(get_type_name(),
      $sformatf("\n-----------------------------------\n\
Total Transactions : %0d\n\
Pass               : %0d\n\
Fail               : %0d\n\
-----------------------------------",
      total_txns,
      pass_cnt,
      fail_cnt),
      UVM_NONE);

  endfunction

endclass