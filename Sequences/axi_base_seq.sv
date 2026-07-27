class axi_base_seq extends uvm_sequence#(axi_transaction);
  
  `uvm_object_utils(axi_base_seq)
  
  function new(string name = "axi_base_seq");
    
    super.new(name);
    
  endfunction
  
  //body task
  
  task body();
    
    req=axi_transaction::type_id::create("req");
    
    start_item(req);
    
    randomize_req();
    
    finish_item(req);
    
  endtask
  
  virtual task randomize_req();
    
    assert(req.randomize());
    
  endtask
  
endclass
