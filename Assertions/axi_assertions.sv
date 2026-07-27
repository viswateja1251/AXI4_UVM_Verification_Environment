module axi_assertions(axi_if vif);
  
  initial
  $display("[%0t] AXI assertions instantiated", $time);

  //=========================================================
  // VALID must remain asserted until READY
  //=========================================================

  property awvalid_until_ready;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      $rose(vif.AWVALID)
      |-> vif.AWVALID until_with vif.AWREADY;
  endproperty

  assert property(awvalid_until_ready)
    else $error("[%0t] AWVALID deasserted before AWREADY",$time);


  property wvalid_until_ready;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      $rose(vif.WVALID)
      |-> vif.WVALID until_with vif.WREADY;
  endproperty

  assert property(wvalid_until_ready)
    else $error("[%0t] WVALID deasserted before WREADY",$time);


  property bvalid_until_ready;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      $rose(vif.BVALID)
      |-> vif.BVALID until_with vif.BREADY;
  endproperty

  assert property(bvalid_until_ready)
    else $error("[%0t] BVALID deasserted before BREADY",$time);


  property arvalid_until_ready;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      $rose(vif.ARVALID)
      |-> vif.ARVALID until_with vif.ARREADY;
  endproperty

  assert property(arvalid_until_ready)
    else $error("[%0t] ARVALID deasserted before ARREADY",$time);


  property rvalid_until_ready;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      $rose(vif.RVALID)
      |-> vif.RVALID until_with vif.RREADY;
  endproperty

  assert property(rvalid_until_ready)
    else $error("[%0t] RVALID deasserted before RREADY",$time);


  //=========================================================
  // WLAST checking
  //=========================================================

  int beat_count;
  int burst_length;

  always @(posedge vif.ACLK)
  begin
    if(!vif.ARESETn)
    begin
      beat_count   <= 0;
      burst_length <= 0;
    end
    else
    begin

      // Capture burst length
      if(vif.AWVALID && vif.AWREADY)
      begin
        burst_length <= vif.AWLEN;
        beat_count   <= 0;
      end

      // Count write beats
      if(vif.WVALID && vif.WREADY)
      begin

        if(vif.WLAST)
          beat_count <= 0;
        else
          beat_count <= beat_count + 1;

      end

    end
  end


  // WLAST only on final beat

  property wlast_on_last_beat;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)

    (vif.WVALID && vif.WREADY && vif.WLAST)
      |->
    (beat_count == burst_length);

  endproperty

  assert property(wlast_on_last_beat)
    else $error("[%0t] WLAST asserted before final beat",$time);


  // Never assert WLAST before last beat

  property no_early_wlast;

    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)

    (vif.WVALID &&
     vif.WREADY &&
     (beat_count < burst_length))

     |->
     !vif.WLAST;

  endproperty

  assert property(no_early_wlast)
    else $error("[%0t] Early WLAST detected",$time);



  //=========================================================
  // BRESP must not contain X/Z
  //=========================================================

  property bresp_known;

    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)

      vif.BVALID
      |->
      !$isunknown(vif.BRESP);

  endproperty

  assert property(bresp_known)
    else $error("[%0t] BRESP contains X/Z",$time);



  //=========================================================
  // No X/Z on VALID & READY signals
  //=========================================================

  property aw_known;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      (vif.AWVALID || vif.AWREADY)
      |->
      (!$isunknown(vif.AWVALID) &&
       !$isunknown(vif.AWREADY));
  endproperty

  assert property(aw_known)
    else $error("[%0t] AWVALID/AWREADY has X/Z",$time);


  property w_known;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      (vif.WVALID || vif.WREADY)
      |->
      (!$isunknown(vif.WVALID) &&
       !$isunknown(vif.WREADY));
  endproperty

  assert property(w_known)
    else $error("[%0t] WVALID/WREADY has X/Z",$time);


  property b_known;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      (vif.BVALID || vif.BREADY)
      |->
      (!$isunknown(vif.BVALID) &&
       !$isunknown(vif.BREADY));
  endproperty

  assert property(b_known)
    else $error("[%0t] BVALID/BREADY has X/Z",$time);


  property ar_known;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      (vif.ARVALID || vif.ARREADY)
      |->
      (!$isunknown(vif.ARVALID) &&
       !$isunknown(vif.ARREADY));
  endproperty

  assert property(ar_known)
    else $error("[%0t] ARVALID/ARREADY has X/Z",$time);


  property r_known;
    @(posedge vif.ACLK)
    disable iff(!vif.ARESETn)
      (vif.RVALID || vif.RREADY)
      |->
      (!$isunknown(vif.RVALID) &&
       !$isunknown(vif.RREADY));
  endproperty

  assert property(r_known)
    else $error("[%0t] RVALID/RREADY has X/Z",$time);


endmodule
