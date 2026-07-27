class random_interleave_vseq extends uvm_sequence;

  `uvm_object_utils(random_interleave_vseq)
  `uvm_declare_p_sequencer(axi_virtual_sequencer)
  
  random_write_seq wseq;
  random_read_seq rseq;
  rand int unsigned iterations;
  
  function new(string name = "random_interleave_vseq");
    super.new(name);
  endfunction
  
  //constraints
  constraint c_iterations{
    iterations inside {[100:400]};
  }

  virtual task body();
    
     assert(this.randomize());

  `uvm_info(get_type_name(),
            $sformatf("Running %0d iterations", iterations),
            UVM_LOW)
    
    repeat(iterations)
      
      begin

        wseq = random_write_seq::type_id::create("wseq");
        rseq = random_read_seq::type_id::create("rseq");

        wseq.start(p_sequencer.m_seqr);
        rseq.start(p_sequencer.m_seqr);
        
      end

  endtask

endclass