class single_write_seq extends axi_base_seq;
  
  `uvm_object_utils(single_write_seq)
  
  function new(string name = "single_write_seq");
    
    super.new(name);
    
  endfunction
  
  task randomize_req();
    
    assert(req.randomize() with {rw == 1 ; len == 0; });
    
  endtask
  
endclass