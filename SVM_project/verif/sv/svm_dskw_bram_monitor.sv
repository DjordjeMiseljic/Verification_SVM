/*******************************************************************************
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
 |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
 +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

 FILE            svm_dskw_bram_monitor.sv

 DESCRIPTION     

 *******************************************************************************/

`ifndef SVM_DSKW_BRAM_MONITOR_SV
 `define SVM_DSKW_BRAM_MONITOR_SV

class svm_dskw_bram_monitor extends uvm_monitor;

   // control fileds
   bit checks_enable = 1;
   bit coverage_enable = 1;

   uvm_analysis_port #(bram_frame) item_collected_port;

   `uvm_component_utils_begin(svm_dskw_bram_monitor)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   `uvm_component_utils_end

   // The virtual interface used to drive and view HDL signals.
   virtual interface bram_if vif;

   // current transaction
   bram_frame current_frame;

   // coverage can go here
   // ...

   function new(string name = "svm_dskw_bram_monitor", uvm_component parent = null);
      super.new(name,parent);
      item_collected_port = new("item_collected_port", this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(virtual bram_if)::get(this, "*", "bram_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
   endfunction : connect_phase

   task run_phase(uvm_phase phase);
/*      forever begin
	 current_frame = bram_frame::type_id::create("current_frame", this);
	 // ...
	 // collect transactions
	 @(posedge vif.clk)begin
	    if(vif.en)begin
	       item_collected_port.write(current_frame);
	    end
	 end
	 // item_collected_port.write(current_frame);
      end*/
   endtask : run_phase

endclass : svm_dskw_bram_monitor

`endif

