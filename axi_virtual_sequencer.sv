class axi_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(axi_virtual_sequencer)

  master_sequencer m_seqr;

  function new(string name="axi_virtual_sequencer",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

endclass