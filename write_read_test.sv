class write_read_test extends axi_base_test;

  `uvm_component_utils(write_read_test)

  function new(string name="write_read_test",
               uvm_component parent);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);

//     single_write_seq wr_seq;
//     single_read_seq  rd_seq;
//     fixed_burst_seq  fb_seq;
//     incr_burst_seq   ib_seq;
//     wrap_burst_seq   wb_seq;
    random_interleave_vseq vseq;

    phase.raise_objection(this);

//     wr_seq = single_write_seq::type_id::create("wr_seq");
//     rd_seq = single_read_seq::type_id::create("rd_seq");
//     fb_seq = fixed_burst_seq::type_id::create("fb_seq");
//     ib_seq = incr_burst_seq::type_id::create("ib_seq");
//     wb_seq = wrap_burst_seq::type_id::create("wb_seq");

//     wr_seq.start(env.m_agent.seqr);

//     #20;

//     rd_seq.start(env.m_agent.seqr);
    
//     #20;
    
//     fb_seq.start(env.m_agent.seqr);
    
//     #20;
    
//     ib_seq.start(env.m_agent.seqr);
    
//     #20;
    
//     wb_seq.start(env.m_agent.seqr);
    
    vseq = random_interleave_vseq::type_id::create("vseq");
 	vseq.start(env.vseqr);

    phase.drop_objection(this);

  endtask

endclass