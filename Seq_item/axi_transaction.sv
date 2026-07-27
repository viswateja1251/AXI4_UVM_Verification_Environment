class axi_transaction extends uvm_sequence_item;

  `uvm_object_utils(axi_transaction)
  
  // in your axi_transaction class
  localparam int MEM_DEPTH = 1024;

  
  rand bit        rw;        //0=read,1=write

  rand bit [3:0]  id;
  rand bit [31:0] addr;
  rand bit [7:0]  len;
  rand bit [2:0]  size;
  rand bit [1:0]  burst;

  rand bit [31:0] data[];
  rand bit [3:0]  strb[];
  
  // Write response
  bit [1:0] bresp;

  // Read response
  bit [31:0] rresp[];

  // Optional IDs
  bit [3:0] rid;
  bit [3:0] bid;
  
  function new(string name="axi_transaction");
    super.new(name);
  endfunction
  
  //Constraints
  //Address alignment as per size
  constraint c_align
  {
      addr % (1<<size) == 0;
  }
  
  //Legal burst modes
  constraint c_burst
  {
      burst inside {2'b00,2'b01,2'b10};
  }
  
  //Legal Size
  constraint c_size
  {
      size inside {[0:3]};
  }
  
  //Legal Length
  constraint c_len
  {
      len inside {[0:255]};
  }
  
  //Dynamic array size
  constraint c_array
  {
      data.size()==len+1;
      strb.size()==len+1;
  }
  
  
  // addr 
  constraint addr_c {
    addr < MEM_DEPTH;                          // stay in-bounds
    addr + ((len+1) << size) <= MEM_DEPTH;     // whole burst stays in-bounds
  }

  
  function string convert2string();
    
    `uvm_info(get_type_name(),$sformatf(" rw = %0d, id = %0d , addr = %0d, len = %0d, size = %0d, burst =%0d, data_size = %0d, strb_size = %0d", rw, id  , addr , len, size, burst, data.size(), strb.size()),UVM_LOW);
    
  endfunction
                                        
    
endclass
