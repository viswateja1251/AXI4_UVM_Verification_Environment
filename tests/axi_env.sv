class axi_env extends uvm_env;

  `uvm_component_utils(axi_env)

  master_agent    m_agent;
  slave_agent     s_agent;
  axi_scoreboard  sb;
  master_coverage cov;
  axi_virtual_sequencer vseqr;

  function new(string name="axi_env",
               uvm_component parent);
    super.new(name,parent);
  endfunction


  //---------------------------------------
  // BUILD PHASE
  //---------------------------------------

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    m_agent = master_agent::type_id::create("m_agent", this);
    s_agent = slave_agent::type_id::create("s_agent", this);
    sb      = axi_scoreboard::type_id::create("sb", this);
    cov     = master_coverage::type_id::create("cov",this);
    vseqr   = axi_virtual_sequencer::type_id::create("vseqr",this);

  endfunction


  //---------------------------------------
  // CONNECT PHASE
  //---------------------------------------

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    // Master monitor -> Scoreboard
    m_agent.mon.ap.connect(sb.analysis_export);
    m_agent.mon.ap.connect(cov.analysis_export);
    vseqr.m_seqr = m_agent.seqr;

  endfunction

endclass
