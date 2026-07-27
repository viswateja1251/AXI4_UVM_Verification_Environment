class single_read_seq extends axi_base_seq;
  
  `uvm_object_utils(single_read_seq)
  
  function new(string name = "single_read_seq");
    
    super.new(name);
    
  endfunction
  
  task randomize_req();
    
    assert(req.randomize() with {rw == 0 ; len == 0;});
    
  endtask
  
endclass