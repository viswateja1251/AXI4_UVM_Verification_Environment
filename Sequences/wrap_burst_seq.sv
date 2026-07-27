class wrap_burst_seq extends axi_base_seq;
  
  `uvm_object_utils(wrap_burst_seq)
  
  function new(string name = "wrap_burst_seq");
    
    super.new(name);
    
  endfunction
  
  task randomize_req();
    
    assert(req.randomize() with {burst == 2'b10 ; len inside {1,3,7,15};});
    
         //because AXI4 allows wrap lengths of 2, 4, 8, or 16 beats (len+1).
                                 
  endtask
  
endclass
