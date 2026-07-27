class fixed_burst_seq extends axi_base_seq;
  
  `uvm_object_utils(fixed_burst_seq)
  
  function new(string name = "fixed_burst_seq");
    
    super.new(name);
    
  endfunction
  
  task randomize_req();
    
    assert(req.randomize() with {burst == 2'b00 ; len inside {[3:15]};});
    
  endtask
  
endclass
