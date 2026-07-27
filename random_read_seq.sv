class random_read_seq extends axi_base_seq;

  `uvm_object_utils(random_read_seq)

  function new(string name = "random_read_seq");
    super.new(name);
  endfunction

  virtual task body();

    req = axi_transaction::type_id::create("req");

    start_item(req);

    assert(req.randomize() with {
      rw == 0;
      len inside {[0:15]};
    });

    finish_item(req);

  endtask

endclass