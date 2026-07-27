class incr_burst_seq extends axi_base_seq;
  
  `uvm_object_utils(incr_burst_seq)
  
  function new(string name = "incr_burst_seq");
    
    super.new(name);
    
  endfunction
  
  task randomize_req();
    
    assert(req.randomize() with {burst == 2'b01;});
    
  endtask
  
endclass